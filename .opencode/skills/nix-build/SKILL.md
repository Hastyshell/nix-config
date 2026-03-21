---
name: nix-build
description: Build, apply, test, and lint commands for this NixOS flake — nh, nix build, nix eval, nix fmt, statix, deadnix
---

## Build / Apply

```bash
nh os switch . #hostname          # apply configuration to current host
nh os test . #hostname            # test without making it the boot default
nix fmt                           # format all Nix files (nixfmt-rfc-style)
statix check .                    # lint and suggestions
deadnix .                         # find unused bindings
nix flake update                  # update all flake inputs
nix flake update <input-name>     # update a single input
```

## Verify Changes

No automated tests or flake checks. Verify by building:

```bash
# Quick evaluation check (no download/build)
nix eval .#nixosConfigurations.hasty-desktop.config.system.build.toplevel --no-build
# Full build check (dry-run)
nix build .#nixosConfigurations.hasty-desktop.config.system.build.toplevel --dry-run
# Build without applying
nix build .#nixosConfigurations.hasty-desktop.config.system.build.toplevel
```

Replace `hasty-desktop` with `vmware-desktop` to check the other host.
