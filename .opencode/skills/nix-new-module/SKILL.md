---
name: nix-new-module
description: Step-by-step workflow for adding a new feature-gated NixOS or Home Manager module to this flake, including option declaration, module structure, barrel imports, and host enablement
---

## Adding a New Feature Module

### Steps

1. Add `custom.<namespace>.enable = lib.mkEnableOption "...";` to `options/default.nix`.
2. Create the module in the appropriate `extra/` directory.
3. Wrap config in `config = lib.mkIf config.custom.<namespace>.enable { ... };`.
4. Import the new file from the parent `extra/default.nix`.
5. Set the flag to `true` in the relevant host's `globalOptions`.
6. Run `nix fmt` and verify with `nix build`.

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

### Feature-Gated Module Pattern

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

### Custom Option Namespaces

- `custom.nixos.*` -- NixOS-only (secureboot, nvidia, display managers, sunshine).
- `custom.linux.desktop.*` -- shared across NixOS and Home Manager (niri, walker, waybar).

### Host Configuration

NixOS hosts use a `mkHost` factory in `hosts/nixos/default.nix`. Each host directory
has `default.nix` (host record: username, modules, homeModules, globalOptions),
`configuration.nix`, `hardware-configuration.nix` (auto-generated), `home.nix`.

Standalone Home Manager hosts use a `mkHome` factory in `hosts/home/default.nix`.
Each host directory has a single `default.nix` (host record: hostname, username,
fullName, email, homeModules). These produce `homeConfigurations` flake outputs
for use on non-NixOS machines.

### Module Placement Guide

- NixOS system modules: `modules/system/nixos/` (or `desktop/extra/` for desktop features)
- Cross-platform system modules: `modules/system/share/`
- CLI Home Manager modules: `modules/home/share/`
- Desktop Home Manager modules: `modules/home/gui/linux/` (or `extra/` for feature-gated)
