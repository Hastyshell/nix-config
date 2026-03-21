#!/usr/bin/env bash
set -euo pipefail

DEFAULT_HOST="127.0.0.1"
DEFAULT_PASSTHROUGH="1"
MAX_STARTUP_ATTEMPTS=600
STARTUP_POLL_INTERVAL="0.1"
STARTUP_NOTICE_DELAY="1.5"

PROXY_PID=""
PROXY_LOG_FILE=""
KEEP_PROXY_LOG=0
STARTUP_NOTICE_PID=""

pick_port() {
  python3 - <<'PY'
import socket

s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
}

cleanup() {
  local exit_code=$?

  trap - EXIT INT TERM

  if [ -n "$STARTUP_NOTICE_PID" ] && kill -0 "$STARTUP_NOTICE_PID" 2>/dev/null; then
    kill "$STARTUP_NOTICE_PID" 2>/dev/null || true
    wait "$STARTUP_NOTICE_PID" 2>/dev/null || true
  fi

  if [ -n "$PROXY_PID" ] && kill -0 "$PROXY_PID" 2>/dev/null; then
    kill "$PROXY_PID" 2>/dev/null || true
    wait "$PROXY_PID" 2>/dev/null || true
  fi

  if [ -n "$PROXY_LOG_FILE" ] && [ "$KEEP_PROXY_LOG" -ne 1 ]; then
    rm -f "$PROXY_LOG_FILE"
  fi

  exit "$exit_code"
}

show_proxy_failure() {
  local message="$1"
  local health_body="${2:-}"

  KEEP_PROXY_LOG=1

  printf 'error: %s\n' "$message" >&2

  if [ -n "$health_body" ] && jq -e '.error? != null' >/dev/null 2>&1 <<<"$health_body"; then
    printf '%s\n' "$(jq -r '.error' <<<"$health_body")" >&2
  fi

  if [ -n "$PROXY_LOG_FILE" ] && [ -f "$PROXY_LOG_FILE" ]; then
    printf 'proxy log: %s\n' "$PROXY_LOG_FILE" >&2
    printf 'recent proxy output:\n' >&2
    head -n 40 "$PROXY_LOG_FILE" >&2 || true
  fi

  return 1
}

start_startup_notice() {
  (
    sleep "$STARTUP_NOTICE_DELAY"

    if [ -n "$PROXY_PID" ] && kill -0 "$PROXY_PID" 2>/dev/null; then
      printf 'starting dedicated Claude Max proxy for this OpenCode session...\n' >&2
      printf 'waiting for the proxy health check before launching OpenCode\n' >&2
      printf 'startup log: %s\n' "$PROXY_LOG_FILE" >&2
    fi
  ) &
  STARTUP_NOTICE_PID=$!
}

stop_startup_notice() {
  if [ -n "$STARTUP_NOTICE_PID" ] && kill -0 "$STARTUP_NOTICE_PID" 2>/dev/null; then
    kill "$STARTUP_NOTICE_PID" 2>/dev/null || true
    wait "$STARTUP_NOTICE_PID" 2>/dev/null || true
  fi

  STARTUP_NOTICE_PID=""
}

# Treat the root endpoint as readiness. It flips to 200 as soon as the HTTP
# server is listening, even before health/auth checks succeed.
wait_for_proxy() {
  local base_url="$1"

  for _ in $(seq 1 "$MAX_STARTUP_ATTEMPTS"); do
    if curl --silent --output /dev/null --connect-timeout 1 --max-time 2 "$base_url/" 2>/dev/null; then
      return 0
    fi

    if ! kill -0 "$PROXY_PID" 2>/dev/null; then
      show_proxy_failure "claude-max-proxy exited before becoming ready"
    fi

    sleep "$STARTUP_POLL_INTERVAL"
  done

  show_proxy_failure "claude-max-proxy did not become ready in time"
}

# After the server is up, require /health to succeed before handing control to
# OpenCode so the user gets a clear error if Claude auth has expired.
check_proxy_health() {
  local base_url="$1"
  local response
  local http_code
  local body
  local status
  local error_message

  for _ in $(seq 1 "$MAX_STARTUP_ATTEMPTS"); do
    response="$({
      curl --silent --connect-timeout 1 --max-time 7 --write-out $'\n%{http_code}' "$base_url/health"
    } 2>/dev/null || true)"

    if [ -n "$response" ]; then
      http_code="${response##*$'\n'}"
      body="${response%$'\n'*}"
      status="$(jq -r '.status // ""' <<<"$body" 2>/dev/null || printf '')"
      error_message="$(jq -r '.error // ""' <<<"$body" 2>/dev/null || printf '')"

      if [ "$http_code" = "200" ]; then
        return 0
      fi

      if [ "$status" = "unhealthy" ] || [ -n "$error_message" ]; then
        show_proxy_failure "proxy health check failed${status:+ (status: $status)}" "$body"
      fi
    fi

    if ! kill -0 "$PROXY_PID" 2>/dev/null; then
      show_proxy_failure "claude-max-proxy exited before passing health checks" "$body"
    fi

    sleep "$STARTUP_POLL_INTERVAL"
  done

  if [ -z "$response" ]; then
    show_proxy_failure "could not reach the proxy health endpoint"
  fi

  status="$(jq -r '.status // "unknown"' <<<"$body" 2>/dev/null || printf 'unknown')"
  show_proxy_failure "proxy health check failed (status: $status)" "$body"
}

main() {
  local proxy_port
  local project_cwd
  local base_url

  proxy_port="${CLAUDE_PROXY_PORT:-$(pick_port)}"
  # Despite the env var name, CLAUDE_PROXY_WORKDIR controls the Claude/OpenCode
  # session cwd. The proxy's own runtime files live under XDG state dirs.
  project_cwd="${CLAUDE_PROXY_WORKDIR:-$PWD}"
  base_url="http://${DEFAULT_HOST}:${proxy_port}"
  PROXY_LOG_FILE="$(mktemp "${TMPDIR:-/tmp}/oc-proxy.XXXXXX.log")"

  trap cleanup EXIT INT TERM

  # Each oc invocation gets its own loopback-only proxy so the TUI's OpenCode
  # server talks to a matching Claude proxy with the current project as cwd.
  CLAUDE_PROXY_HOST="$DEFAULT_HOST" \
    CLAUDE_PROXY_PORT="$proxy_port" \
    CLAUDE_PROXY_WORKDIR="$project_cwd" \
    CLAUDE_PROXY_PASSTHROUGH="${CLAUDE_PROXY_PASSTHROUGH:-$DEFAULT_PASSTHROUGH}" \
    claude-max-proxy >"$PROXY_LOG_FILE" 2>&1 &
  PROXY_PID=$!
  start_startup_notice

  wait_for_proxy "$base_url"
  check_proxy_health "$base_url"
  stop_startup_notice

  ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-dummy}" \
    ANTHROPIC_BASE_URL="$base_url" \
    opencode "$@"
}

main "$@"
