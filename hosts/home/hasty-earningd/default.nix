{ self, ... }:
{
  hostname = "hasty-earningd";
  username = "tangsiyang";
  fullName = "Siyang Tang";
  email = "tangsiyang@selectdb.com";
  system = "x86_64-linux";
  homeModules = [
    self.homeModules.default
  ];
}
