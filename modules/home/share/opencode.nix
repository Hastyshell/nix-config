{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    settings = {
      theme = "tokyonight";
      server = {
        port = 8964;
        hostname = "0.0.0.0";
        mdns = true;
        mdnsDomain = "opencode.local";
      };
    };
  };
}
