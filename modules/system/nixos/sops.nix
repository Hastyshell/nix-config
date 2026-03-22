{
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config = lib.mkIf config.custom.nixos.sops.enable {
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
  };
}
