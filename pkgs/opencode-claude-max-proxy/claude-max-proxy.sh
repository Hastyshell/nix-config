#!/usr/bin/env bash
set -euo pipefail

# User-local working directory where bun dependencies are installed.
# The Nix store is read-only, so we keep a writable copy here.
PROXY_WORK="${XDG_DATA_HOME:-$HOME/.local/share}/opencode-claude-max-proxy"
PROXY_VER_FILE="$PROXY_WORK/.nix-pkg-version"
PROXY_STORE_VERSION="@version@"

# Validate PROXY_WORK is within the user's home directory to prevent accidental
# data loss from rm -rf if XDG_DATA_HOME is misconfigured.
case "$PROXY_WORK" in
  "$HOME"/*) ;;
  *)
    echo "[claude-max-proxy] ERROR: PROXY_WORK ($PROXY_WORK) is outside \$HOME. Refusing to continue." >&2
    exit 1
    ;;
esac

# On first run or after a package upgrade, copy sources and install deps.
if [ ! -f "$PROXY_VER_FILE" ] || [ "$(cat "$PROXY_VER_FILE")" != "$PROXY_STORE_VERSION" ]; then
  echo "[claude-max-proxy] Installing dependencies into $PROXY_WORK ..." >&2
  rm -rf "$PROXY_WORK"
  mkdir -p "$PROXY_WORK"
  cp -rL "@shareDir@/." "$PROXY_WORK/"
  chmod -R u+w "$PROXY_WORK"
  cd "$PROXY_WORK"
  if ! @bunPath@ install --frozen-lockfile; then
    echo "[claude-max-proxy] ERROR: 'bun install --frozen-lockfile' failed." >&2
    echo "[claude-max-proxy] Ensure you have internet access on first run." >&2
    rm -rf "$PROXY_WORK"
    exit 1
  fi
  printf '%s' "$PROXY_STORE_VERSION" > "$PROXY_VER_FILE"
fi

export CLAUDE_PROXY_PASSTHROUGH="${CLAUDE_PROXY_PASSTHROUGH:-1}"
exec @bunPath@ run "$PROXY_WORK/bin/claude-proxy.ts" "$@"
