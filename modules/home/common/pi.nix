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
  piExtensionsDir = piConfig + "/extensions";

  localExtensions =
    let
      entries = builtins.readDir piExtensionsDir;
      names = builtins.filter (name: entries.${name} == "regular" && lib.hasSuffix ".ts" name) (
        builtins.attrNames entries
      );
    in
    map (name: "${piExtensionsDir}/${name}") names;

  piMultiEdit = pkgs.buildNpmPackage {
    pname = "pi-multi-edit";
    version = "0.0.0";

    src = "${piExtensionsDir}/multi-edit";

    npmDepsHash = "sha256-ob6mYY8+0GCWp+1zMp3m7qs1WYP+qZ0YunA3Bk5W/oc=";
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp index.ts $out/
      cp -r node_modules $out/
      runHook postInstall
    '';
  };

  piWebAccess = pkgs.buildNpmPackage {
    pname = "pi-web-access";
    version = "0.10.6";

    src = "${piConfig}/extensions/pi-web-access";

    npmDepsHash = "sha256-zau3eaJoa8pE3A5COXwyTLSesoePgYqrnRCg3SMSarw=";
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      cp -r node_modules $out/
      runHook postInstall
    '';
  };

  piFilesWidget = pkgs.stdenvNoCC.mkDerivation {
    pname = "pi-files-widget";
    version = "0.1.20";

    src = "${piConfig}/extensions/files-widget";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      runHook postInstall
    '';
  };

  managedSettings =
    lib.recursiveUpdate (builtins.fromJSON (builtins.readFile "${piConfig}/settings.json"))
      {
        skills = [ "${piConfig}/skills" ];
        prompts = [ "${piConfig}/prompts" ];
        extensions = localExtensions ++ [
          "${piMultiEdit}"
          "${piWebAccess}"
          "${piFilesWidget}"
        ];
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
