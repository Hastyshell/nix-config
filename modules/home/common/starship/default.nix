{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # home-manager does not support `presets` opt
    # https://github.com/nix-community/home-manager/issues/7297
    # presets = [ "tokyo-night" ];
    # use presets in this way
    settings = lib.mkMerge [
      (fromTOML (builtins.readFile ./tokyo-night.toml))
      {
        format = lib.mkForce ''
          [░▒▓](#a3aed2)$os[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)
          $character'';
        os = {
          disabled = false;
          style = "bg:#a3aed2 fg:#090c0c";
          symbols = {
            NixOS = "  ";
            Macos = "  ";
            CentOS = "  ";
          };
        };
      }
    ];
    # override this preset in other modules by reading another TOML file
    # into `programs.starship.settings`.
  };
}
