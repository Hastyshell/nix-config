---
name: nix-code-style
description: Complete Nix code style guide for this flake including formatting, naming conventions, function arguments, expressions, comments, error handling, and flake input patterns
---

## Code Style

### Formatter

**`nixfmt-rfc-style`** (declared in `flake.nix:87`). Always run `nix fmt`
before committing.

### Naming Conventions

- 2 spaces indentation, no tabs. Lines under ~120 chars.
- **kebab-case** for `.nix` files and directories.
- **camelCase** for attributes, following upstream NixOS/home-manager conventions.
- Custom options: `custom.*` namespace with camelCase segments.
  - `custom.nixos.*` -- NixOS-only (secureboot, nvidia, display managers, sunshine).
  - `custom.linux.desktop.*` -- shared across NixOS and Home Manager (niri, walker, waybar).

### Function Arguments

Multi-parameter: one per line with `...`, closing brace on own line:

```nix
{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
```

Single/few parameters may stay on one line: `{ lib, ... }:`

### Expressions and Scope

- `let ... in` for module-scoped constants at the top of a file.
- `with pkgs;` for package list blocks.
- `inherit` to pass through arguments: `specialArgs = { inherit inputs; };`
- Short lists inline: `[ "kvm-amd" ]`. Longer lists one-item-per-line.

### Comments

- `#` line comments for explanations and TODOs.
- `# ====...====` banner blocks for major section headers.
- Include URL references to relevant documentation.
- Preserve commented-out alternative configurations with explanatory comments.

### Error Handling

- `lib.mkIf` for conditional config blocks (feature flags).
- `if-then-else` for value-level conditionals (platform checks, etc.).
- `throw` for truly impossible/unsupported states.
- `lib.mkForce` sparingly. `lib.mkDefault` in hardware-configuration files.
- Do not use `assert` -- it is not used in this codebase.

### Flake Input Patterns

- Inputs passed via `specialArgs = { inherit inputs; };` and
  `extraSpecialArgs = { inherit inputs; };`.
- External modules: `imports = [ inputs.foo.nixosModules.bar ];`
- Internal modules: `self.nixosModules.default`, `self.customOptions`.
- `pkgs.unstable.*` via overlay, `pkgs.mypkgs.*` via overlay, and custom flake
  packages exported as flat `packages.<system>.<name>` entries.
