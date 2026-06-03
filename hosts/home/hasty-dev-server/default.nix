{ self, ... }:
{
  hostname = "hasty-dev-server";
  username = "hastyshell";
  fullName = "Hastyshell";
  email = "tangsiyang2001@gmail";
  system = "x86_64-linux";
  homeModules = [
    self.homeModules.default
  ];
}
