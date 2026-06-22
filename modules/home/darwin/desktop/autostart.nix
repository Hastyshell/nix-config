{ pkgs, ... }:
let
  openAppPath = appPath: {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-gj"
        appPath
      ];
      RunAtLoad = true;
    };
  };
  openApp =
    app:
    let
      appPath = "${app.package}/Applications/${app.name}.app";
    in
    openAppPath appPath;
in
{
  launchd.agents = {
    clash-verge = openAppPath "/Applications/Clash Verge.app";
    maccy = openApp {
      package = pkgs.maccy;
      name = "Maccy";
    };
    stats = openApp {
      package = pkgs.stats;
      name = "Stats";
    };
    tailscale = openAppPath "/Applications/Tailscale.app";
  };
}
