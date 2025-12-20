{
  imports = [
    ./pkgs.nix
    ./zsh.nix
    ./starship.nix
    ./zellij
    ./neovim.nix
    ./fzf.nix
    ./git.nix
    ./direnv.nix
    ./opencode.nix
  ];

  xresources.properties = {
    "Xcursor.size" = 32;
    "Xft.dpi" = 192;
  };
}
