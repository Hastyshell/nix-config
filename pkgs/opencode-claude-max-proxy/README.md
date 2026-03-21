# opencode-claude-max-proxy

Nix packaging and local workflow notes for `pkgs.mypkgs.opencode-claude-max-proxy`.

## What this package contains

This package installs three commands:

- `claude-max-proxy` - the upstream proxy server itself
- `ocproxyctl` - a small controller for the shared user service
- `oc` - a launcher that starts OpenCode with a dedicated per-session proxy

## How it is packaged

The package does not run `bun install` at runtime.

- `default.nix` fetches the upstream npm tarball for `opencode-claude-max-proxy`
- it installs the prebuilt `dist/` output into `$out/share/opencode-claude-max-proxy`
- it vendors `@anthropic-ai/claude-agent-sdk` into the package's local `node_modules`
- it fetches the OpenCode plugin file `src/plugin/claude-max-headers.ts`
- the final `claude-max-proxy` binary is a Node wrapper around the upstream `dist/cli.js`

This keeps startup deterministic and avoids the older first-run behavior where a writable copy of the source tree had to be created under the user's XDG data directory.

## Commands

### `claude-max-proxy`

Runs the upstream proxy server directly.

Important environment variables:

- `CLAUDE_PROXY_HOST`
- `CLAUDE_PROXY_PORT`
- `CLAUDE_PROXY_PASSTHROUGH`
- `CLAUDE_PROXY_WORKDIR`

`CLAUDE_PROXY_WORKDIR` controls the Claude/OpenCode session working directory. It is not the proxy's own state directory.

### `ocproxyctl`

Controls the shared `systemd --user` service `claude-max-proxy.service`.

Supported commands:

- `ocproxyctl status`
- `ocproxyctl restart`
- `ocproxyctl logs`

This command is intended for the long-running shared proxy used by the persistent OpenCode Web UI service.

### `oc`

Starts a dedicated local proxy for a single OpenCode TUI session, then launches `opencode` against that proxy.

Behavior:

- picks a free local port
- starts a loopback-only `claude-max-proxy`
- sets `CLAUDE_PROXY_WORKDIR` to the current directory by default
- waits for the proxy to become ready
- launches `opencode` with `ANTHROPIC_BASE_URL` pointed at that temporary proxy
- cleans up the proxy process when OpenCode exits

If startup fails, `oc` keeps the temporary proxy log and prints its path.

## Intended usage model

There are two separate modes:

- shared mode: `claude-max-proxy.service` + `ocproxyctl`, used by the persistent OpenCode Web UI / `opencode serve`
- session mode: `oc`, used for one proxy per TUI session

This split avoids port collisions and keeps TUI sessions isolated while still allowing a fixed-port shared server for the Web UI.
