#!/usr/bin/env bash
set -euo pipefail

PROXY_UNIT="claude-max-proxy.service"
SERVE_UNIT="opencode-serve.service"

DEFAULT_PROXY_HOST="@proxyHost@"
DEFAULT_PROXY_PORT="@proxyPort@"
DEFAULT_SERVE_HOST="127.0.0.1"
DEFAULT_SERVE_PORT="@servePort@"

FETCH_BODY=""
FETCH_CODE=""

usage() {
  cat <<'EOF'
Usage: occtl <command> [args]

Commands:
  status              Show proxy and serve status
  restart [target]    Restart services (proxy, serve, or all; default: all)
  logs [target] ...   Show service logs (proxy, serve, or all; default: all)
EOF
}

usage_status() {
  cat <<'EOF'
Usage: occtl status

Show the combined status of both the Claude Max proxy and the OpenCode
server, including systemd state, HTTP reachability, health, and auth.
EOF
}

usage_restart() {
  cat <<'EOF'
Usage: occtl restart [target]

Restart one or both services, then show status.

Targets:
  proxy   Restart claude-max-proxy only
  serve   Restart opencode-serve only
  all     Restart both (default)
EOF
}

usage_logs() {
  cat <<'EOF'
Usage: occtl logs [target] [journalctl args]

Show service logs.

Targets:
  proxy   claude-max-proxy logs
  serve   opencode-serve logs
  all     Both services interleaved (default)

Examples:
  occtl logs
  occtl logs proxy -f
  occtl logs serve --since '10 minutes ago'
EOF
}

usage_error() {
  local message="$1"

  printf 'error: %s\n\n' "$message" >&2
  usage >&2
}

unit_property() {
  local unit="$1"
  local property="$2"

  systemctl --user show "$unit" --property "$property" --value 2>/dev/null || true
}

unit_installed() {
  local unit="$1"

  [ "$(unit_property "$unit" LoadState)" = "loaded" ]
}

print_unit_status() {
  local label="$1"
  local unit="$2"
  local active_state
  local sub_state
  local unit_file_state
  local pid
  local result

  if ! unit_installed "$unit"; then
    printf '%s: not installed in user systemd\n' "$label"
    return 1
  fi

  active_state="$(unit_property "$unit" ActiveState)"
  sub_state="$(unit_property "$unit" SubState)"
  unit_file_state="$(unit_property "$unit" UnitFileState)"
  pid="$(unit_property "$unit" MainPID)"
  result="$(unit_property "$unit" Result)"

  printf '%s: %s (%s), enabled=%s' "$label" "${active_state:-unknown}" "${sub_state:-unknown}" "${unit_file_state:-unknown}"
  if [ -n "$pid" ] && [ "$pid" != "0" ]; then
    printf ', pid=%s' "$pid"
  fi
  if [ -n "$result" ] && [ "$result" != "success" ]; then
    printf ', result=%s' "$result"
  fi
  printf '\n'

  [ "$active_state" = "active" ]
}

proxy_base_url() {
  local host="${CLAUDE_PROXY_HOST:-}"
  local port="${CLAUDE_PROXY_PORT:-}"
  local entry

  if unit_installed "$PROXY_UNIT"; then
    for entry in $(unit_property "$PROXY_UNIT" Environment); do
      case "$entry" in
        CLAUDE_PROXY_HOST=*)
          [ -z "$host" ] && host="${entry#CLAUDE_PROXY_HOST=}"
          ;;
        CLAUDE_PROXY_PORT=*)
          [ -z "$port" ] && port="${entry#CLAUDE_PROXY_PORT=}"
          ;;
      esac
    done
  fi

  printf 'http://%s:%s' "${host:-$DEFAULT_PROXY_HOST}" "${port:-$DEFAULT_PROXY_PORT}"
}

serve_base_url() {
  printf 'http://%s:%s' "$DEFAULT_SERVE_HOST" "$DEFAULT_SERVE_PORT"
}

fetch_json() {
  local url="$1"
  local response

  FETCH_BODY=""
  FETCH_CODE=""
  response="$({
    curl --silent --show-error --connect-timeout 1 --max-time 2 \
      --write-out $'\n%{http_code}' "$url"
  } 2>/dev/null || true)"

  if [ -z "$response" ]; then
    return 1
  fi

  FETCH_CODE="${response##*$'\n'}"
  FETCH_BODY="${response%$'\n'*}"

  [[ "$FETCH_CODE" =~ ^[0-9]{3}$ ]]
}

print_proxy_details() {
  local base_url="$1"
  local exit_code=0
  local health_auth_state="unavailable"
  local claude_email=""
  local claude_subscription=""

  if fetch_json "$base_url/"; then
    printf 'proxy-api: status=%s, service=%s, format=%s' \
      "$(jq -r '.status // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')" \
      "$(jq -r '.service // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')" \
      "$(jq -r '.format // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')"

    if jq -e '.version? != null' >/dev/null 2>&1 <<<"$FETCH_BODY"; then
      printf ', version=%s' "$(jq -r '.version' <<<"$FETCH_BODY")"
    fi
    printf '\n'

    if jq -e '.endpoints? | length > 0' >/dev/null 2>&1 <<<"$FETCH_BODY"; then
      printf 'proxy-endpoints: %s\n' "$(jq -r '.endpoints | join(", ")' <<<"$FETCH_BODY")"
    fi
  else
    printf 'proxy-api: unreachable at %s\n' "$base_url"
    exit_code=1
  fi

  if fetch_json "$base_url/health"; then
    local health_status mode logged_in email subscription

    health_status="$(jq -r '.status // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')"
    mode="$(jq -r '.mode // "unknown"' <<<"$FETCH_BODY" 2>/dev/null || printf 'unknown')"
    logged_in="$(jq -r '.auth.loggedIn // empty' <<<"$FETCH_BODY" 2>/dev/null || true)"
    email="$(jq -r '.auth.email // empty' <<<"$FETCH_BODY" 2>/dev/null || true)"
    subscription="$(jq -r '.auth.subscriptionType // empty' <<<"$FETCH_BODY" 2>/dev/null || true)"

    printf 'proxy-health: %s, mode=%s' "$health_status" "$mode"
    if [ "$logged_in" = "true" ]; then
      health_auth_state="logged_in"
      claude_email="$email"
      claude_subscription="$subscription"
      printf ', auth=logged in'
      [ -n "$email" ] && printf ' as %s' "$email"
      [ -n "$subscription" ] && printf ' (%s)' "$subscription"
    elif [ "$logged_in" = "false" ]; then
      health_auth_state="not_logged_in"
      printf ', auth=not logged in'
    fi
    printf '\n'

    [ "$health_status" != "healthy" ] && exit_code=1
  else
    printf 'proxy-health: unavailable\n'
    exit_code=1
  fi

  case "$health_auth_state" in
    logged_in)
      printf 'claude: logged in'
      [ -n "$claude_email" ] && printf ' as %s' "$claude_email"
      [ -n "$claude_subscription" ] && printf ' (%s)' "$claude_subscription"
      printf '\n'
      ;;
    not_logged_in)
      printf 'claude: not logged in\n'
      printf "hint: run \`claude login\` then \`occtl restart proxy\`\n"
      exit_code=1
      ;;
    *)
      printf "claude: status unavailable (check proxy health or run \`claude auth status\`)\n"
      ;;
  esac

  return "$exit_code"
}

print_serve_details() {
  local base_url="$1"
  local exit_code=0

  if curl --silent --output /dev/null --connect-timeout 1 --max-time 2 "$base_url/" 2>/dev/null; then
    printf 'serve-http: reachable at %s\n' "$base_url"
  else
    printf 'serve-http: unreachable at %s\n' "$base_url"
    exit_code=1
  fi

  return "$exit_code"
}

status_cmd() {
  local exit_code=0
  local proxy_url
  local serve_url

  proxy_url="$(proxy_base_url)"
  serve_url="$(serve_base_url)"

  printf '=== Claude Max Proxy ===\n'
  print_unit_status "proxy" "$PROXY_UNIT" || exit_code=1
  print_proxy_details "$proxy_url" || exit_code=1

  printf '\n=== OpenCode Server ===\n'
  print_unit_status "serve" "$SERVE_UNIT" || exit_code=1
  print_serve_details "$serve_url" || exit_code=1

  return "$exit_code"
}

restart_units() {
  local unit

  for unit in "$@"; do
    if ! unit_installed "$unit"; then
      printf 'error: %s is not installed in the user systemd manager\n' "$unit" >&2
      return 1
    fi
    systemctl --user reset-failed "$unit" >/dev/null 2>&1 || true
    systemctl --user restart "$unit"
  done
}

restart_cmd() {
  local target="${1:-all}"
  local units

  case "$target" in
    proxy)
      restart_units "$PROXY_UNIT"
      ;;
    serve)
      restart_units "$SERVE_UNIT"
      ;;
    all)
      units=("$PROXY_UNIT")
      if unit_installed "$SERVE_UNIT"; then
        units+=("$SERVE_UNIT")
      else
        printf 'serve: not installed in user systemd, skipping restart\n' >&2
      fi
      restart_units "${units[@]}"
      ;;
    *)
      usage_error "unknown restart target: $target"
      exit 1
      ;;
  esac

  sleep 1
  status_cmd
}

logs_cmd() {
  local target="all"

  if [ "$#" -gt 0 ]; then
    case "$1" in
      proxy|serve|all)
        target="$1"
        shift
        ;;
    esac
  fi

  case "$target" in
    proxy)
      if [ "$#" -eq 0 ]; then
        exec journalctl --user -u "$PROXY_UNIT" -n 100 --no-pager
      fi
      exec journalctl --user -u "$PROXY_UNIT" "$@"
      ;;
    serve)
      if [ "$#" -eq 0 ]; then
        exec journalctl --user -u "$SERVE_UNIT" -n 100 --no-pager
      fi
      exec journalctl --user -u "$SERVE_UNIT" "$@"
      ;;
    all)
      if [ "$#" -eq 0 ]; then
        exec journalctl --user -u "$PROXY_UNIT" -u "$SERVE_UNIT" -n 100 --no-pager
      fi
      exec journalctl --user -u "$PROXY_UNIT" -u "$SERVE_UNIT" "$@"
      ;;
  esac
}

main() {
  if [ "$#" -eq 0 ]; then
    usage_error "missing command"
    exit 1
  fi

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
      if [ "$#" -gt 1 ]; then
        usage_error "restart accepts at most one target"
        exit 1
      fi
      restart_cmd "${1:-all}"
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
        "")      usage ;;
        status)  usage_status ;;
        restart) usage_restart ;;
        logs)    usage_logs ;;
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
