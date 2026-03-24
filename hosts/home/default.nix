{
  self,
  inputs,
  withSystem,
  ...
}:
let
  stateVersion = "25.11";
  mkHome =
    {
      hostname,
      username,
      fullName,
      email,
      system ? "x86_64-linux",
      homeModules,
      ...
    }:
    {
      ${hostname} = withSystem system (
        { pkgs, ... }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = homeModules ++ [
            {
              home = {
                inherit username stateVersion;
                homeDirectory = "/mnt/disk1/${username}";
              };
              programs.git.settings.user = {
                name = fullName;
                inherit email;
              };
            }
          ];
        }
      );
    };
  homes = [
    (import ./hasty-earningd { inherit self; })
  ];
in
{
  flake.homeConfigurations = builtins.foldl' (x: y: x // y) { } (map mkHome homes);
}
