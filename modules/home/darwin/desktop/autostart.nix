{ config, ... }:
let
  homeManagerApps = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}";

  openAppPathWithArgs = openArgs: appPath: {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/open" ] ++ openArgs ++ [ appPath ];
      RunAtLoad = true;
    };
  };
  openAppPath = openAppPathWithArgs [ "-gj" ];
  openHomeManagerApp = name: openAppPath "${homeManagerApps}/${name}.app";
  openForegroundHomeManagerApp = name: openAppPathWithArgs [ ] "${homeManagerApps}/${name}.app";
in
{
  launchd.agents = {
    clash-verge = openAppPath "/Applications/Clash Verge.app";
    maccy = openForegroundHomeManagerApp "Maccy";
    stats = openHomeManagerApp "Stats";
    tailscale = openAppPath "/Applications/Tailscale.app";
  };
}
