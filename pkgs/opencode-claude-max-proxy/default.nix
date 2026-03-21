{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchzip,
  makeBinaryWrapper,
  writeShellApplication,
  symlinkJoin,
  nodejs,
  python3,
  curl,
  jq,
  coreutils,
  systemd,
  unstable,
  ...
}:
let
  pname = "opencode-claude-max-proxy";
  version = "1.12.0";

  proxyDist = fetchzip {
    url = "https://registry.npmjs.org/opencode-claude-max-proxy/-/opencode-claude-max-proxy-${version}.tgz";
    hash = "sha256-hjshG1wdOcsQgUVnuTsfMtLn/gLuscGKlDAMePJCt0k=";
  };

  claudeAgentSdk = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-agent-sdk/-/claude-agent-sdk-0.2.81.tgz";
    hash = "sha256-E3y3fHH4qwrQfoGl+41kceyy/GwuwamGr6lrXLurT20=";
  };

  sessionHeaderPlugin = fetchurl {
    url = "https://raw.githubusercontent.com/rynfar/opencode-claude-max-proxy/ae36db536c16985c95c1fb6078ea3ea71bfbce19/src/plugin/claude-max-headers.ts";
    hash = "sha256-gntShAD/kXb5vc/AanbCS08Qw1EJN9nDvTp/xMPfK3s=";
  };

  proxyServer = stdenvNoCC.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [ makeBinaryWrapper ];

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/opencode-claude-max-proxy/"{dist,node_modules/@anthropic-ai,src/plugin}
      cp "${proxyDist}/package.json" "$out/share/opencode-claude-max-proxy/"
      cp -r "${proxyDist}/dist/." "$out/share/opencode-claude-max-proxy/dist/"
      cp -r "${claudeAgentSdk}" "$out/share/opencode-claude-max-proxy/node_modules/@anthropic-ai/claude-agent-sdk"
      cp "${sessionHeaderPlugin}" "$out/share/opencode-claude-max-proxy/src/plugin/claude-max-headers.ts"

      mkdir -p "$out/bin"

      # Run the prebuilt Node dist directly so startup does not need a writable
      # work directory or a first-run `bun install`.
      makeBinaryWrapper "${nodejs}/bin/node" "$out/bin/claude-max-proxy" \
        --add-flags "$out/share/opencode-claude-max-proxy/dist/cli.js" \
        --prefix PATH : "${
          lib.makeBinPath [
            unstable.claude-code
            nodejs
          ]
        }"

      runHook postInstall
    '';

    meta = {
      description = "Use Claude subscription with OpenCode via local proxy server";
      homepage = "https://github.com/rynfar/opencode-claude-max-proxy";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "claude-max-proxy";
    };
  };

  proxyControlCli = writeShellApplication {
    name = "ocproxyctl";

    runtimeInputs = [
      coreutils
      curl
      jq
      systemd
    ];

    text = builtins.readFile ./ocproxyctl.sh;

    meta = {
      description = "Status and log helper for claude-max-proxy";
      homepage = proxyServer.meta.homepage;
      license = proxyServer.meta.license;
      platforms = proxyServer.meta.platforms;
    };
  };

  proxyTuiLauncher = writeShellApplication {
    name = "oc";

    runtimeInputs = [
      coreutils
      curl
      jq
      python3
      proxyServer
      unstable.opencode
    ];

    text = builtins.readFile ./oc.sh;

    meta = {
      description = "Launch OpenCode with a dedicated Claude Max proxy";
      homepage = proxyServer.meta.homepage;
      license = proxyServer.meta.license;
      platforms = proxyServer.meta.platforms;
    };
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    proxyServer
    proxyControlCli
    proxyTuiLauncher
  ];

  meta = proxyServer.meta;
}
