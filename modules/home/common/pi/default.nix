{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  piConfig = inputs.pi-config;
  piAgentDir = "${config.home.homeDirectory}/.pi/agent";

  piExtensions = pkgs.buildNpmPackage {
    pname = "pi-config-extensions";
    version = "0.0.0";

    src = piConfig;

    postPatch = ''
      cp ${./extensions-runtime/package-lock.json} package-lock.json
      cp ${./extensions-runtime/package.json} package.json
    '';

    npmDepsHash = "sha256-QQ7H/1bqTCJolZgCVLd1OXj0FWecAL8373244m4gtpo=";
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r extensions/. $out/
      cp -r node_modules $out/
      runHook postInstall
    '';
  };

  managedSettings =
    lib.recursiveUpdate (builtins.fromJSON (builtins.readFile "${piConfig}/settings.json"))
      {
        skills = [ "${piConfig}/skills" ];
        prompts = [ "${piConfig}/prompts" ];
        extensions = [ "${piExtensions}" ];
        themes = [ "${piConfig}/themes" ];
      };
in
{
  home.packages = with pkgs; [
    pi
    bat
    delta
    glow
  ];

  home.file = {
    ".pi/agent/settings.json" = {
      text = builtins.toJSON managedSettings;
      force = true;
    };
    ".pi/agent/AGENTS.md" = {
      source = "${piConfig}/AGENTS.md";
      force = true;
    };
    ".pi/agent/models.json" = {
      source = "${piConfig}/models.json";
      force = true;
    };
  };

  home.activation.removeMutablePiAgentResources = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    run rm -rf \
      "${piAgentDir}/skills" \
      "${piAgentDir}/prompts" \
      "${piAgentDir}/extensions" \
      "${piAgentDir}/themes"
  '';

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
  };
}
