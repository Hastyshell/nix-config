---
name: nix-build
description: Build, apply, test, and lint commands for this NixOS flake — nh, nix build, nix eval, nix fmt, statix, deadnix
---

## Build / Apply

```bash
# NixOS hosts
nh os switch . #hostname          # apply configuration to current host
nh os test . #hostname            # test without making it the boot default

# Standalone Home Manager hosts (non-NixOS)
nh home switch . #hostname        # apply home configuration

nix fmt                           # format all Nix files (nixfmt-rfc-style)
statix check .                    # lint and suggestions
deadnix .                         # find unused bindings
nix flake update                  # update all flake inputs
nix flake update <input-name>     # update a single input
```

## Verify Changes

No automated tests or flake checks. Verify by building:

```bash
# NixOS hosts — quick evaluation check (no download/build)
nix eval .#nixosConfigurations.hasty-desktop.config.system.build.toplevel --no-build
# NixOS hosts — full build check (dry-run)
nix build .#nixosConfigurations.hasty-desktop.config.system.build.toplevel --dry-run
# NixOS hosts — build without applying
nix build .#nixosConfigurations.hasty-desktop.config.system.build.toplevel
```

Replace `hasty-desktop` with `vmware-desktop` to check the other NixOS host.

```bash
# Standalone Home Manager hosts — evaluation check
nix eval .#homeConfigurations.hasty-earningd.activationPackage --no-build
# Standalone Home Manager hosts — build check
nix build .#homeConfigurations.hasty-earningd.activationPackage
```

## Troubleshooting

### Home Manager activation fails

If `nh os switch` or `nh os test` fails with `home-manager-<user>.service`, inspect:

```bash
systemctl status home-manager-<user>.service --no-pager
journalctl -u home-manager-<user>.service -n 200 --no-pager
```

Common failure pattern:

- `Existing file '...' would be clobbered`

This means Home Manager wants to manage a file, but a normal file already
exists at that path. Fix it by moving or removing the conflicting file, then
retry the switch/test. Example:

```bash
mv ~/.claude/settings.json ~/.claude/settings.json.bak
nh os switch .#hasty-desktop
```

If you want this to be automatic in the future, consider configuring
`home-manager.backupFileExtension` or `home-manager.backupCommand`.
