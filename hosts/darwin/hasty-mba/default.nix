{ self, ... }:
{
  hostname = "hasty-mba";
  username = "hastyshell";
  fullName = "Hastyshell";
  email = "tangsiyang2001@gmail.com";

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
