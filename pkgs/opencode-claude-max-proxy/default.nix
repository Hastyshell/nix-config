{ lib, stdenvNoCC, fetchFromGitHub, makeBinaryWrapper, bun, nodejs, ... }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-claude-max-proxy";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "rynfar";
    repo = "opencode-claude-max-proxy";
    rev = "18e10dbe13b01792258766ff04dc7848ff0c8287";
    hash = "sha256-7vEW2JpNXgTW8Aly5WLYZSDB/f1MRURXBHuU3CyFmto=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  patches = [
    # Skip re-sending the system prompt on session resume to reduce redundant
    # token usage and improve prompt caching at the API level.
    ./skip-system-context-on-resume.patch
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install source tree; bun will use it as the basis for the work directory.
    # Copy only the files needed for bun to install and run the proxy.
    mkdir -p "$out/share/opencode-claude-max-proxy/"{bin,src}
    cp package.json bun.lock tsconfig.json "$out/share/opencode-claude-max-proxy/"
    cp -r bin/. "$out/share/opencode-claude-max-proxy/bin/"
    cp -r src/. "$out/share/opencode-claude-max-proxy/src/"

    mkdir -p "$out/bin"

    # claude-max-proxy: copies sources to a writable user directory on first
    # run (or after an upgrade), installs bun deps, then starts the proxy.
    sed \
      -e "s|@bunPath@|${bun}/bin/bun|g" \
      -e "s|@shareDir@|$out/share/opencode-claude-max-proxy|g" \
      -e "s|@version@|${finalAttrs.version}|g" \
      ${./claude-max-proxy.sh} > "$out/bin/.claude-max-proxy-unwrapped"
    chmod +x "$out/bin/.claude-max-proxy-unwrapped"

    # The Claude Agent SDK spawns cli.js (needs node) and internally
    # requires bun in PATH for the subprocess to function correctly.
    makeBinaryWrapper "$out/bin/.claude-max-proxy-unwrapped" "$out/bin/claude-max-proxy" \
      --prefix PATH : "${lib.makeBinPath [ nodejs bun ]}"

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
