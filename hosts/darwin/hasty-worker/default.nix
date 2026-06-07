{ self, ... }:
{
  hostname = "hasty-worker";
  username = "tangsiyang";
  fullName = "Siyang Tang";
  email = "tangsiyang@xiaohongshu.com";

  modules = [
    self.customOptions
    ./configuration.nix
    self.darwinModules.default
  ];

  homeModules = [
    self.customOptions
    ./home.nix
    self.homeModules.default
    self.homeModules.darwin.desktop
  ];

  globalOptions = { };
}
