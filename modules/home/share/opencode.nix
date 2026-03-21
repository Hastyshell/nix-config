{ pkgs, ... }:
let
  claude-max-proxy = pkgs.mypkgs.opencode-claude-max-proxy;
in
{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    settings = {
      theme = "tokyonight";
      plugin = [
        "${claude-max-proxy}/share/opencode-claude-max-proxy/src/plugin/claude-max-headers.ts"
      ];
      server = {
        port = 8964;
        hostname = "0.0.0.0";
        mdns = true;
        mdnsDomain = "opencode.local";
      };
    };
  };
}
