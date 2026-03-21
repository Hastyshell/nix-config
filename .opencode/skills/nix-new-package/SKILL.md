---
name: nix-new-package
description: Workflow and patterns for creating a new custom package derivation in pkgs/, including writeShellApplication, stdenvNoCC, and appimageTools patterns
---

## Custom Packages (`pkgs/`)

### Overview

`pkgs/default.nix` is a registry using `callPackage` for each derivation.
Exposed as `pkgs.mypkgs.*` via the overlay in `flake.nix`.

### Steps to Add a New Package

1. Create a new directory under `pkgs/<package-name>/` with a `default.nix`.
2. Register it in `pkgs/default.nix` using `callPackage`.
3. Access it as `pkgs.mypkgs.<package-name>` in any module.
4. Include `meta` with at least `description`.
5. Run `nix fmt` and verify with `nix build`.

### Pattern: Shell Script Wrapper

Use `writeShellApplication` for shell script wrappers:

```nix
{
  writeShellApplication,
  coreutils,
  jq,
  ...
}:
writeShellApplication {
  name = "my-script";
  runtimeInputs = [
    coreutils
    jq
  ];
  text = builtins.readFile ./my-script.sh;
  meta = {
    description = "A helpful script";
  };
}
```

### Pattern: Non-Compiled Package

Use `stdenvNoCC.mkDerivation` with the `finalAttrs` pattern:

```nix
{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "my-package";
  version = "1.0.0";
  src = fetchurl {
    url = "https://example.com/my-package-${finalAttrs.version}.tar.gz";
    hash = "sha256-AAAA...";
  };
  installPhase = ''
    runHook preInstall
    # install commands
    runHook postInstall
  '';
  meta = {
    description = "My package description";
  };
})
```

### Pattern: AppImage Repackaging

Use `appimageTools.wrapAppImage`:

```nix
{
  lib,
  appimageTools,
  fetchurl,
  ...
}:
let
  pname = "my-app";
  version = "1.0.0";
  src = fetchurl {
    url = "https://example.com/${pname}-${version}.AppImage";
    hash = "sha256-AAAA...";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    # desktop file, icons, etc.
  '';
  meta = {
    description = "My AppImage application";
  };
}
```

### Conventions

- Use **kebab-case** for package directory names.
- All packages must include `meta.description`.
- For packages with shell scripts, keep the script in a separate `.sh` file and
  use `builtins.readFile` to inline it.
