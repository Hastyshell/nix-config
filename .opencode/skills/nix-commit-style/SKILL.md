---
name: nix-commit-style
description: Conventional Commits rules for this flake, including preferred types, scopes, subject style, and examples
---

## Commit Messages

Use **Conventional Commits** (v1.0.0) for all new commits:

```text
type(scope): subject

[optional body]

[optional footer(s)]
```

### Types

| Type       | When to use                                              |
|------------|----------------------------------------------------------|
| `feat`     | new packages, modules, integrations, user-visible config |
| `fix`      | bug fixes, compatibility fixes, broken runtime behavior  |
| `docs`     | documentation changes (README, AGENTS.md, etc.)          |
| `style`    | formatting only (nix fmt, whitespace, semicolons)        |
| `refactor` | structure changes without meaningful behavior change     |
| `perf`     | performance improvements (build speed, caching)          |
| `test`     | adding or updating test cases                            |
| `build`    | build system changes (flake inputs, overlays)            |
| `ci`       | CI/CD workflow and pipeline changes                      |
| `chore`    | maintenance, cleanup, version bumps, removals            |

### Breaking Changes

Append `!` before the colon to flag a breaking change:

```text
feat(module)!: redesign option interface
```

A `BREAKING CHANGE:` footer can optionally provide more detail.

### Scopes

Use the affected component/module as the scope when possible:

```text
alacritty, zellij, opencode, readme, flake.lock, home, overlays, workflows
```

### Subject Style

- Lowercase and action-oriented
- Prefer `docs(readme): ...` over bare `readme: ...`
- Prefer `chore(flake.lock): update` for lockfile updates

### Examples

```text
feat(alacritty): use Nerd Font instead of Nerd Font Mono
fix(opencode): add node and bun to claude-max-proxy runtime PATH
ci(workflows): add selective manual build triggers
docs(agents): add AGENTS.md for coding agents
chore(flake.lock): update
refactor(modules): split networking into per-host files
feat(hyprland)!: replace sway keybindings with hyprland native
```

### Enforcement

Optional local hook:

```bash
ln -sf ../../.githooks/commit-msg .git/hooks/commit-msg
```

The hook accepts `Merge`, `Revert`, `fixup!`, and `squash!` commits unchanged.
