# AGENTS.md

Instructions for AI coding agents operating in this repository.

## Project Overview

Personal NixOS + Home Manager configuration managed as a Nix flake, structured
with **flake-parts**. Targets two hosts (`hasty-desktop`, `vmware-desktop`) on
`x86_64-linux`. Home Manager is integrated as a NixOS module (not standalone).

## Repository Layout

```
flake.nix          # Entrypoint: inputs, perSystem config, formatter
hosts/nixos/       # Per-machine host definitions (<hostname>/)
modules/
  system/          # NixOS modules (share/ = cross-platform, nixos/ = NixOS-specific)
  home/            # Home Manager modules (share/ = CLI, gui/linux/ = desktop)
options/           # Centralized custom option declarations (options/default.nix)
overlays/          # Nixpkgs overlays (unstable, niri, NUR)
pkgs/              # Custom package derivations (accessed as pkgs.mypkgs.*)
```

Module exports: `flake.nixosModules.{default, desktop}` from `modules/system/`,
`flake.homeModules.{default, gui.linux}` from `modules/home/`.

## Build / Apply Commands

No Makefiles, justfiles, or CI. All operations use Nix tooling directly.

```bash
nh os switch . #hostname          # apply configuration to current host
nh os test . #hostname            # test without making it the boot default
nix fmt                           # format all Nix files (nixfmt-rfc-style)
statix check .                    # lint and suggestions
deadnix .                         # find unused bindings
nix flake update                  # update all flake inputs
nix flake update <input-name>     # update a single input
```

## Testing

No automated tests or flake checks. Verify changes by building:

```bash
# Quick evaluation check (no download/build)
nix eval .#nixosConfigurations.hasty-desktop.config.system.build.toplevel --no-build
# Full build check (dry-run)
nix build .#nixosConfigurations.hasty-desktop.config.system.build.toplevel --dry-run
# Build without applying
nix build .#nixosConfigurations.hasty-desktop.config.system.build.toplevel
```

Replace `hasty-desktop` with `vmware-desktop` to check the other host.

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

### Module Directory Convention

Every directory has a `default.nix` barrel file importing children. Within each
module area, **always-on modules** live at the directory level, while
**feature-gated modules** live under an `extra/` subdirectory:

```
modules/system/nixos/desktop/
  default.nix          # barrel + always-on config (xserver, xkb, swaylock PAM)
  peripherals.nix      # always-on
  stylix.nix           # always-on
  extra/
    default.nix        # barrel importing feature-gated children
    niri.nix           # feature-gated
    nvidia.nix         # feature-gated
    sunshine.nix       # feature-gated
```

Feature-gated modules use:

```nix
{ config, lib, ... }:
{
  config = lib.mkIf config.custom.<path>.enable {
    # configuration here
  };
}
```

When a feature-gated module imports an external flake module, the `imports`
must be **outside** the `lib.mkIf` block (imports are always unconditional):

```nix
{
  imports = [ inputs.niri.nixosModules.niri ];   # unconditional
  config = lib.mkIf config.custom.<path>.enable { ... };  # conditional
}
```

### Directory-Style Modules

When a module needs non-Nix assets (CSS, XML, KDL), use a directory with
`default.nix` instead of a single `.nix` file. Inline assets with
`builtins.readFile`:

```
extra/walker/
  default.nix       # module code, uses builtins.readFile ./style.css
  style.css
  layout.xml
```

### Custom Options

All custom options are declared centrally in `options/default.nix` as
`flake.customOptions` using `lib.mkEnableOption`. Never declare custom options
in individual modules. Referenced as `self.customOptions` in host definitions.
The `globalOptions` attrset in each host is applied to both NixOS and Home
Manager modules, so `custom.linux.desktop.*` flags work across both layers.

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
- `pkgs.unstable.*` via overlay, `pkgs.mypkgs.*` via overlay.

### Custom Packages (`pkgs/`)

`pkgs/default.nix` is a registry using `callPackage` for each derivation.
Exposed as `pkgs.mypkgs.*` via the overlay in `flake.nix`. Patterns used:

- **`writeShellApplication`** for shell script wrappers with `runtimeInputs`.
- **`stdenvNoCC.mkDerivation`** with `finalAttrs` pattern for non-compiled packages.
- **`appimageTools.wrapAppImage`** for AppImage repackaging.
- All packages include `meta` with at least `description`.

### Host Configuration

Hosts use a `mkHost` factory in `hosts/nixos/default.nix`. Each host directory
has `default.nix` (host record: username, modules, homeModules, globalOptions),
`configuration.nix`, `hardware-configuration.nix` (auto-generated), `home.nix`.

### Adding a New Feature Module

1. Add `custom.<namespace>.enable = lib.mkEnableOption "...";` to `options/default.nix`.
2. Create the module in the appropriate `extra/` directory.
3. Wrap config in `config = lib.mkIf config.custom.<namespace>.enable { ... };`.
4. Import the new file from the parent `extra/default.nix`.
5. Set the flag to `true` in the relevant host's `globalOptions`.
6. Run `nix fmt` and verify with `nix build`.
