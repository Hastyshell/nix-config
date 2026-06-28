{ config, ... }:
let
  homeManagerApps = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}";

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
  openHomeManagerApp = name: openAppPath "${homeManagerApps}/${name}.app";
in
{
  launchd.agents = {
    clash-verge = openAppPath "/Applications/Clash Verge.app";
    maccy = openHomeManagerApp "Maccy";
    stats = openHomeManagerApp "Stats";
    tailscale = openAppPath "/Applications/Tailscale.app";
  };
}
