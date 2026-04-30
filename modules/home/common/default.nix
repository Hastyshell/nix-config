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
    ./pi
    ./opencode
    ./claude.nix
  ];

  xresources.properties = {
    "Xcursor.size" = 32;
    "Xft.dpi" = 192;
  };
}
