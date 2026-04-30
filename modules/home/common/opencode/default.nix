{ pkgs, ... }:
let
  inherit (pkgs.unstable) opencode;
  serveHost = "0.0.0.0";
  servePort = 8964;
in
{
  programs.opencode = {
    enable = true;
    package = opencode;
    settings = {
      theme = "tokyonight";
    };
  };

  # Persistent OpenCode server for the Web UI.
  systemd.user.services.opencode-serve = {
    Unit = {
      Description = "OpenCode server (Web UI)";
    };

    Service = {
      ExecStart = "${opencode}/bin/opencode serve --port ${toString servePort} --hostname ${serveHost}";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "%h";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
