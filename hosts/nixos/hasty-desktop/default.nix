{ self, ... }:
{
  hostname = "hasty-desktop";
  username = "hastyshell";
  fullName = "Hastyshell";
  email = "tangsiyang2001@foxmail.com";
  modules = [
    self.customOptions
    ./configuration.nix
    self.nixosModules.default
    self.nixosModules.desktop
  ];
  homeModules = [
    self.customOptions
    ./home.nix
    self.homeModules.default
    self.homeModules.gui.linux
  ];
  globalOptions = {
    custom.nixos.secureBoot.lanzaboote.enable = true;
    custom.linux.desktop.wm.niri.enable = true;
    custom.linux.desktop.launcher.walker.enable = true;
    custom.nixos.desktop.displayManager.greetd.enable = true;
    custom.linux.desktop.fileManager.thunar.enable = true;
    # custom.linux.desktop.swayidle.enable = true;
    custom.nixos.desktop.remoteDesktop.sunshine.enable = true;
    custom.nixos.graphics.nvidia.enable = true;
    custom.linux.desktop.bar.waybar.enable = true;
  };
}
