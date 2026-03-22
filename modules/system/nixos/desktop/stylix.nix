{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    # Keep the scheme in-repo so flake checks do not depend on realizing
    # pkgs.base16-schemes during CI evaluation.
    base16Scheme = ./tokyo-night-dark.yaml;
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
    };
  };

  stylix.targets.chromium.enable = false;
}
