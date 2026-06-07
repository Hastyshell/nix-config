{
  self,
  inputs,
  withSystem,
  ...
}:
let
  systemStateVersion = 6;
  homeStateVersion = "25.11";

  mkHost =
    {
      hostname,
      username,
      fullName,
      email,
      system ? "aarch64-darwin",
      modules,
      homeModules,
      globalOptions ? { },
      ...
    }:
    {
      ${hostname} = inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = modules ++ [
          globalOptions

          (
            { ... }:
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
            }
          )

          inputs.mac-app-util.darwinModules.default
          inputs.home-manager.darwinModules.home-manager

          {
            nix.settings.trusted-users = [
              "root"
              username
            ];

            networking.hostName = hostname;
            networking.localHostName = hostname;

            system = {
              primaryUser = username;
              stateVersion = systemStateVersion;
            };

            users.users.${username}.home = "/Users/${username}";

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              sharedModules = [
                inputs.mac-app-util.homeManagerModules.default
              ];
              extraSpecialArgs = { inherit inputs; };
              users.${username} = {
                imports = homeModules ++ [ globalOptions ];

                home = {
                  inherit username;
                  stateVersion = homeStateVersion;
                  homeDirectory = "/Users/${username}";
                };

                programs.git.settings.user = {
                  name = fullName;
                  inherit email;
                };
              };
            };
          }
        ];
      };
    };

  hosts = [
    (import ./hasty-mba { inherit self; })
    (import ./hasty-worker { inherit self; })
  ];
in
{
  flake.darwinConfigurations = builtins.foldl' (x: y: x // y) { } (map mkHost hosts);
}
