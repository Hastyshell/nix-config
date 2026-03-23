# AGENTS.md

Personal NixOS + Home Manager flake config (**flake-parts**, `x86_64-linux`).
Two hosts: `hasty-desktop`, `vmware-desktop`. Home Manager as NixOS module.

## Repository Layout

```
flake.nix          # Entrypoint: inputs, perSystem config, formatter
hosts/nixos/       # Per-machine host definitions (<hostname>/)
modules/
  home/            # Home Manager modules
    common/        #   Cross-platform CLI/shell tools (included in homeModules.default)
    linux/         #   Linux-specific HM modules
      desktop/     #     Desktop environment (homeModules.linux.desktop)
  system/          # NixOS / system modules
    common/        #   Cross-platform system config (included in nixosModules.default)
    nixos/         #   NixOS-specific modules
      common/      #     Base NixOS config (included in nixosModules.default)
      desktop/     #     Desktop system config (nixosModules.desktop)
options/           # Centralized custom option declarations (options/default.nix)
overlays/          # Nixpkgs overlays (unstable, niri, NUR)
pkgs/              # Custom package derivations (internal pkgs.mypkgs.*, flat flake packages.* outputs)
```

## Conventions

- If a module depends on companion files (TOML, CSS, scripts, templates, etc.), put it in its own directory with `default.nix` and colocate those files there.

## Skills

Load these on-demand skills when performing related tasks:

- **`nix-build`** — build, apply, test, lint commands
- **`nix-code-style`** — formatting, naming, expressions, error handling
- **`nix-commit-style`** — conventional commit rules and examples
- **`nix-new-module`** — adding a new feature-gated module
- **`nix-new-package`** — creating a custom package derivation
