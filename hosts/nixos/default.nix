{
  self,
  inputs,
  withSystem,
  ...
}:
let
  stateVersion = "25.11";
  mkHost =
    {
      hostname,
      username,
      fullName,
      email,
      modules,
      homeModules,
      globalOptions,
      ...
    }:
    {
      ${hostname} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };

        modules = modules ++ [
          globalOptions

          # since https://github.com/nixos/nixpkgs/issues/454884
          # could not enable read only currently
          # inputs.nixpkgs.nixosModules.readOnlyPkgs
          (
            { config, ... }:
            {
              # Use the configured pkgs from perSystem
              nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
                { pkgs, ... }: # perSystem module arguments
                pkgs
              );
            }
          )

          inputs.home-manager.nixosModules.home-manager

          {
            nix.settings.trusted-users = [
              "root"
              username
            ];

            system.stateVersion = stateVersion;
            networking.hostName = hostname;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.${username} = {
                imports = homeModules ++ [ globalOptions ];

                home = {
                  inherit username;
                  inherit stateVersion;
                  homeDirectory = "/home/${username}";
                };

                programs.git.settings.user = {
                  name = fullName;
                  email = email;
                };
              };
            };
          }

        ];
      };
    };

  hosts = [
    (import ./hasty-desktop { inherit self; })
    (import ./vmware-desktop { inherit self; })
  ];
in
{
  flake.nixosConfigurations = builtins.foldl' (x: y: x // y) { } (map mkHost hosts);
}
