{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) codex;
  cfg = config.custom.home.codex.proxy;
  noProxy = lib.concatStringsSep "," cfg.noProxy;
  codexPackage =
    if cfg.enable then
      pkgs.writeShellApplication {
        name = "codex";
        text = ''
          export http_proxy=${lib.escapeShellArg cfg.url}
          export https_proxy=${lib.escapeShellArg cfg.url}
          export HTTP_PROXY=${lib.escapeShellArg cfg.url}
          export HTTPS_PROXY=${lib.escapeShellArg cfg.url}
          export no_proxy=${lib.escapeShellArg noProxy}
          export NO_PROXY=${lib.escapeShellArg noProxy}

          exec ${lib.getExe codex} "$@"
        '';
      }
    else
      codex;
in
{
  options.custom.home.codex.proxy = {
    enable = lib.mkEnableOption "Codex HTTP proxy wrapper";

    url = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:7890";
      description = "HTTP proxy URL used by the Codex command wrapper.";
    };

    noProxy = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "127.0.0.1"
        "localhost"
        "::1"
      ];
      description = "Hosts that Codex should reach without the HTTP proxy.";
    };
  };

  config = {
    home.packages = [
      codexPackage
    ];

    home.sessionVariables = {
      CODEX_CLI_PATH = lib.getExe codexPackage;
    };
  };
}
