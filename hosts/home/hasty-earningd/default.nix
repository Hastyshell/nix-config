{ self, ... }:
{
  hostname = "hasty-earningd";
  username = "hastyshell";
  homeDirectory = "/home/hastyshell";
  fullName = "Siyang Tang";
  email = "tangsiyang@xiaohongshu.com";
  system = "aarch64-linux";
  homeModules = [
    self.homeModules.default
    (
      { lib, ... }:
      {
        targets.genericLinux = {
          enable = true;
          gpu.enable = false;
        };
        programs = {
          home-manager.enable = true;
          direnv.stdlib = builtins.readFile ./build-cache.sh;
          zsh = {
            envExtra = ''
              if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
                . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
              fi
            '';

            initContent = lib.mkBefore ''
              ZSH_DISABLE_COMPFIX="true"
            '';
          };
        };
      }
    )
  ];
}
