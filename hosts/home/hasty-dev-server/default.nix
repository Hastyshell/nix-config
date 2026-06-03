{ self, ... }:
{
  hostname = "hasty-dev-server";
  username = "hastyshell";
  homeDirectory = "/mnt/data/hastyshell";
  fullName = "Hastyshell";
  email = "tangsiyang2001@gmail";
  system = "x86_64-linux";
  homeModules = [
    self.homeModules.default
    {
      programs.zsh.envExtra = ''
        if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
      '';
    }
  ];
}
