{ pkgs, ... }:
{
  imports = [
    ./peripherals.nix
    ./stylix.nix
    ./extra
  ];

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
      options = "ctrl:nocaps";
    };
  };

  console.useXkbConfig = true;

  xdg.terminal-exec = {
    enable = true;
    package = pkgs.xdg-terminal-exec-mkhl;
    settings =
      let
        terminals = [
          # NOTE: We have add these packages at user level
          "Alacritty.desktop"
        ];
      in
      {
        niri = terminals;
        default = terminals;
      };
  };

  security.pam.services.swaylock = { };
}
