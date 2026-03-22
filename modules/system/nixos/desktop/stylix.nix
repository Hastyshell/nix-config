{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/tokyo-night-dark.yaml";
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
