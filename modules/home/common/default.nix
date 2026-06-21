{ lib, pkgs, ... }:
{
  imports = [
    ./pkgs.nix
    ./zsh.nix
    ./starship
    ./zellij
    ./neovim.nix
    ./fzf.nix
    ./git.nix
    ./direnv.nix
    ./codex.nix
  ];

  xresources.properties = lib.mkIf pkgs.stdenv.isLinux {
    "Xcursor.size" = 32;
    "Xft.dpi" = 192;
  };
}
