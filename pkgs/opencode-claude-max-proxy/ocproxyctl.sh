#!/usr/bin/env bash
set -euo pipefail

UNIT="claude-max-proxy.service"
DEFAULT_HOST="127.0.0.1"
DEFAULT_PORT="3456"

# Shared response buffers populated by fetch_json.
FETCH_BODY=""
FETCH_CODE=""

usage() {
  cat <<'EOF'
Usage: ocproxyctl <command> [args]

Commands:
  status   Show service, API, health, and auth status
  restart  Restart the user service, then show status
  logs     Show user-service logs (pass extra args to journalctl)
EOF
}

usage_status() {
  cat <<'EOF'
Usage: ocproxyctl status

Show service, API, health, and Claude auth status.
EOF
}

usage_restart() {
  cat <<'EOF'
Usage: ocproxyctl restart

Restart the user service, then show status.
EOF
}

usage_logs() {
  cat <<'EOF'
Usage: ocproxyctl logs [journalctl args]

Show user-service logs.

Examples:
  ocproxyctl logs
  ocproxyctl logs -f
  ocproxyctl logs --since '10 minutes ago'
EOF
}

usage_error() {
  local message="$1"

  printf 'error: %s\n\n' "$message" >&2
  usage >&2
}

service_property() {
  local property="$1"

  systemctl --user show "$UNIT" --property "$property" --value 2>/dev/null || true
}

service_installed() {
  [ "$(service_property LoadState)" = "loaded" ]
}

# Prefer explicit environment overrides, otherwise mirror the service settings so
# the helper talks to the same proxy instance that systemd manages.
service_base_url() {
  local host="${CLAUDE_PROXY_HOST:-}"
  local port="${CLAUDE_PROXY_PORT:-}"
  local entry

  if service_installed; then
    for entry in $(service_property Environment); do
      case "$entry" in
        CLAUDE_PROXY_HOST=*)
          if [ -z "$host" ]; then
            host="${entry#CLAUDE_PROXY_HOST=}"
          fi
          ;;
        CLAUDE_PROXY_PORT=*)
          if [ -z "$port" ]; then
            port="${entry#CLAUDE_PROXY_PORT=}"
          fi
          ;;
      esac
    done
  fi

  host="${host:-$DEFAULT_HOST}"
  port="${port:-$DEFAULT_PORT}"

  printf 'http://%s:%s' "$host" "$port"
}

# Curl writes the response body and HTTP code together; split them once here so
# the status command can reuse the parsed values for multiple endpoints.
fetch_json() {
  local url="$1"
  local response

  FETCH_BODY=""
  FETCH_CODE=""
  response="$({ curl --silent --show-error --connect-timeout 1 --max-time 2 --write-out $'\n%{http_code}' "$url"; } 2>/dev/null || true)"

  if [ -z "$response" ]; then
    return 1
  fi

  FETCH_CODE="${response##*$'\n'}"
  FETCH_BODY="${response%$'\n'*}"

  [[ "$FETCH_CODE" =~ ^[0-9]{3}$ ]]
}

status_cmd() {
  local exit_code=0
  local base_url
  local active_state
  local sub_state
  local unit_file_state
  local pid
  local result
  local health_auth_state="unavailable"
  local claude_email=""
  local claude_subscription=""

  base_url="$(service_base_url)"
  active_state="$(service_property ActiveState)"
  sub_state="$(service_property SubState)"
  unit_file_state="$(service_property UnitFileState)"
  pid="$(service_property MainPID)"
  result="$(service_property Result)"

  if service_installed; then
    printf 'service: %s (%s), enabled=%s' "${active_state:-unknown}" "${sub_state:-unknown}" "${unit_file_state:-unknown}"
    if [ -n "$pid" ] && [ "$pid" != "0" ]; then
      printf ', pid=%s' "$pid"
    fi
    if [ -n "$result" ] && [ "$result" != "success" ]; then
      printf ', result=%s' "$result"
    fi
    printf '\n'

    if [ "$active_state" != "active" ]; then
      exit_code=1
    fi
  else
    printf 'service: %s\n' "not installed in user systemd"
    exit_code=1
  fi

  # Root endpoint exposes lightweight service metadata such as version and
  # supported API paths.
  if fetch_json "$base_url/"; then
    printf 'proxy: reachable at %s\n' "$base_url"
    printf 'api: status=%s, service=%s, format=%s' \
      "$(jq -r '.status // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')" \
      "$(jq -r '.service // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')" \
      "$(jq -r '.format // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')"

    if jq -e '.version? != null' >/dev/null 2>&1 <<<"$FETCH_BODY"; then
      printf ', version=%s' "$(jq -r '.version' <<<"$FETCH_BODY")"
    fi
    printf '\n'

    if jq -e '.endpoints? | length > 0' >/dev/null 2>&1 <<<"$FETCH_BODY"; then
      printf 'endpoints: %s\n' "$(jq -r '.endpoints | join(", ")' <<<"$FETCH_BODY")"
    fi
  else
    printf 'proxy: unreachable at %s\n' "$base_url"
    exit_code=1
  fi

  # Use the proxy's health endpoint as the source of truth for auth state.
  # Calling `claude auth status` directly from this helper can leave the tty in
  # a bad state on some systems.
  if fetch_json "$base_url/health"; then
    local health_status
    local mode
    local logged_in
    local email
    local subscription

    health_status="$(jq -r '.status // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')"
    mode="$(jq -r '.mode // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')"
    logged_in="$(jq -r '.auth.loggedIn // empty' <<<"$FETCH_BODY" 2>/dev/null || true)"
    email="$(jq -r '.auth.email // empty' <<<"$FETCH_BODY" 2>/dev/null || true)"
    subscription="$(jq -r '.auth.subscriptionType // empty' <<<"$FETCH_BODY" 2>/dev/null || true)"

    printf 'health: %s, mode=%s' "$health_status" "$mode"
    if [ "$logged_in" = "true" ]; then
      health_auth_state="logged_in"
      claude_email="$email"
      claude_subscription="$subscription"
      printf ', auth=logged in'
      if [ -n "$email" ]; then
        printf ' as %s' "$email"
      fi
      if [ -n "$subscription" ]; then
        printf ' (%s)' "$subscription"
      fi
    elif [ "$logged_in" = "false" ]; then
      health_auth_state="not_logged_in"
      printf ', auth=not logged in'
    fi
    printf '\n'

    if [ "$health_status" != "healthy" ]; then
      exit_code=1
    fi
  else
    printf 'health: unavailable\n'
    exit_code=1
  fi

  case "$health_auth_state" in
    logged_in)
      printf 'claude: logged in'
      if [ -n "$claude_email" ]; then
        printf ' as %s' "$claude_email"
      fi
      if [ -n "$claude_subscription" ]; then
        printf ' (%s)' "$claude_subscription"
      fi
      printf '\n'
      ;;
    not_logged_in)
      printf 'claude: not logged in\n'
      exit_code=1
      printf "hint: run \`claude login\` then \`ocproxyctl restart\`\n"
      ;;
    *)
      printf "claude: status unavailable (check proxy health or run \`claude auth status\`)\n"
      ;;
  esac

  if [ "$health_auth_state" = "unavailable" ] && [ "$active_state" = "active" ]; then
    printf "hint: check \`ocproxyctl logs\` or run \`claude auth status\` manually\n"
  fi

  return "$exit_code"
}

restart_cmd() {
  if ! service_installed; then
    printf 'error: %s is not installed in the user systemd manager\n' "$UNIT" >&2
    exit 1
  fi

  # Reset failed first so a previously crashed service can be restarted in one
  # command.
  systemctl --user reset-failed "$UNIT" >/dev/null 2>&1 || true
  systemctl --user restart "$UNIT"
  sleep 1
  status_cmd
}

logs_cmd() {
  if [ "$#" -eq 0 ]; then
    exec journalctl --user -u "$UNIT" -n 100 --no-pager
  fi

  exec journalctl --user -u "$UNIT" "$@"
}

main() {
  if [ "$#" -eq 0 ]; then
    usage_error "missing command"
    exit 1
  fi

  # Keep dispatch intentionally small: ocproxyctl is meant to be a thin wrapper
  # around systemd, journald, and the proxy's own HTTP endpoints.
  case "$1" in
    status)
      shift
      if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "help" ]; then
        usage_status
        exit 0
      fi
      if [ "$#" -ne 0 ]; then
        usage_error "status does not accept arguments"
        exit 1
      fi
      status_cmd
      ;;
    restart)
      shift
      if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "help" ]; then
        usage_restart
        exit 0
      fi
      if [ "$#" -ne 0 ]; then
        usage_error "restart does not accept arguments"
        exit 1
      fi
      restart_cmd
      ;;
    logs)
      shift
      if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "help" ]; then
        usage_logs
        exit 0
      fi
      logs_cmd "$@"
      ;;
    -h|--help|help)
      shift
      case "${1:-}" in
        "")
          usage
          ;;
        status)
          usage_status
          ;;
        restart)
          usage_restart
          ;;
        logs)
          usage_logs
          ;;
        *)
          usage_error "unknown command: $1"
          exit 1
          ;;
      esac
      ;;
    *)
      usage_error "unknown command: $1"
      exit 1
      ;;
  esac
}

main "$@"
