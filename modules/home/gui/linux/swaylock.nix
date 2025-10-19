{ pkgs, ... }:
{
  programs.swaylock.enable = true;
  programs.swaylock.package = pkgs.swaylock-effects;
  programs.swaylock.settings = {
    image = "${pkgs.mypkgs.assets}/share/wallpapers/nord.png";
    # screenshots = true;
    font = "source-han-serif";
    clock = true;
    timestr = "%H:%M";
    datestr = "%Y-%m-%d";
    indicator = true;
    indicator-radius = 100;
    indicator-thickness = 7;
    indicator-idle-visible = false;
    effect-blur = "7x5";
    effect-vignette = "0.5:0.5";
    grace = 2;
    fade-in = 0.2;

    color = "1a1b26";
    inside-caps-lock-color = "1a1b26";
    inside-clear-color = "1a1b26";
    # inside-color = "1a1b26";
    inside-ver-color = "1a1b26";
    inside-wrong-color = "1a1b26";
    key-hl-color = "9ece6a";
    # layout-bg-color = "1a1b26";
    layout-border-color = "16161e";
    layout-text-color = "a9b1d6";
    ring-caps-lock-color = "16161e";
    ring-clear-color = "c0caf5";
    ring-color = "1616e";
    ring-ver-color = "9ece6a";
    ring-wrong-color = "c0caf5";
    separator-color = "00000000";
    text-caps-lock-color = "a9b1d6";
    text-clear-color = "a9b1d6";
    text-color = "a9b1d6";
    text-ver-color = "a9b1d6";
    text-wrong-color = "a9b1d6";
  };
}
