---
name: nix-commit-style
description: Conventional Commits rules for this flake, including preferred types, scopes, subject style, and examples
---

## Commit Messages

Use **Conventional Commits** for all new commits:

```text
type(scope): subject
```

### Types

- `feat` -- installs, new integrations, user-visible config additions
- `fix` -- bug fixes, compatibility fixes, broken runtime behavior
- `docs` -- documentation changes
- `chore` -- maintenance, cleanup, package source swaps, removals, version bumps
- `refactor` -- structure changes without meaningful behavior change (rare in this repo)

### Scopes

Use the affected component/module as the scope when possible:

```text
alacritty, zellij, opencode, readme, flake.lock, home, overlays
```

### Subject Style

- Lowercase and action-oriented
- Prefer `docs(readme): ...` over bare `readme: ...`
- Prefer `chore(flake.lock): update` for lockfile updates

### Examples

```text
feat(alacritty): use Nerd Font instead of Nerd Font Mono
fix(opencode): add node and bun to claude-max-proxy runtime PATH
docs(agents): add AGENTS.md for coding agents
chore(flake.lock): update
```

### Enforcement

Optional local hook:

```bash
ln -sf ../../.githooks/commit-msg .git/hooks/commit-msg
```

The hook accepts `Merge`, `Revert`, `fixup!`, and `squash!` commits unchanged.
