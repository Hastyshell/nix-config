{ lib, stdenvNoCC, fetchFromGitHub, bun, ... }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-claude-max-proxy";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "rynfar";
    repo = "opencode-claude-max-proxy";
    rev = "18e10dbe13b01792258766ff04dc7848ff0c8287";
    hash = "sha256-7vEW2JpNXgTW8Aly5WLYZSDB/f1MRURXBHuU3CyFmto=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install source tree; bun will use it as the basis for the work directory.
    # Copy only the files needed for bun to install and run the proxy.
    mkdir -p "$out/share/opencode-claude-max-proxy/"{bin,src}
    cp package.json bun.lock tsconfig.json "$out/share/opencode-claude-max-proxy/"
    cp -r bin/. "$out/share/opencode-claude-max-proxy/bin/"
    cp -r src/. "$out/share/opencode-claude-max-proxy/src/"

    # Expose the OpenCode session-tracking plugin at a stable, well-known path.
    mkdir -p "$out/share/opencode-plugins"
    cp src/plugin/claude-max-headers.ts "$out/share/opencode-plugins/"

    mkdir -p "$out/bin"

    # claude-max-proxy: copies sources to a writable user directory on first
    # run (or after an upgrade), installs bun deps, then starts the proxy.
    sed \
      -e "s|@bunPath@|${bun}/bin/bun|g" \
      -e "s|@shareDir@|$out/share/opencode-claude-max-proxy|g" \
      -e "s|@version@|${finalAttrs.version}|g" \
      ${./claude-max-proxy.sh} > "$out/bin/claude-max-proxy"
    chmod +x "$out/bin/claude-max-proxy"

    runHook postInstall
  '';

  meta = {
    description = "Use Claude subscription with OpenCode via local proxy server";
    homepage = "https://github.com/rynfar/opencode-claude-max-proxy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "claude-max-proxy";
  };
})
