{ pkgs, ... }:
let
  opencode = pkgs.unstable.opencode;
  claude-max-proxy = pkgs.mypkgs.opencode-claude-max-proxy;
  serveHost = "0.0.0.0";
  servePort = 8964;
  proxyHost = "127.0.0.1";
  proxyPort = 3456;
  proxyBaseUrl = "http://${proxyHost}:${toString proxyPort}";
  occtl = pkgs.writeShellApplication {
    name = "occtl";

    runtimeInputs = with pkgs; [
      coreutils
      curl
      jq
      systemd
    ];

    text =
      builtins.replaceStrings
        [
          "@proxyHost@"
          "@proxyPort@"
          "@servePort@"
        ]
        [
          proxyHost
          (toString proxyPort)
          (toString servePort)
        ]
        (builtins.readFile ./occtl.sh);
  };
in
{
  # Stack-level control CLI for the persistent proxy + opencode-serve services.
  home.packages = [
    occtl
    claude-max-proxy
  ];

  programs.opencode = {
    enable = true;
    package = opencode;
    settings = {
      theme = "tokyonight";
      plugin = [
        "${claude-max-proxy}/share/opencode-claude-max-proxy/src/plugin/claude-max-headers.ts"
      ];
    };
  };

  # Persistent OpenCode server for the Web UI.
  # Depends on claude-max-proxy so the proxy is always up before opencode serve starts.
  systemd.user.services.opencode-serve = {
    Unit = {
      Description = "OpenCode server (Web UI)";
      After = [ "claude-max-proxy.service" ];
      Requires = [ "claude-max-proxy.service" ];
    };

    Service = {
      ExecStart = "${opencode}/bin/opencode serve --port ${toString servePort} --hostname ${serveHost}";
      Environment = [
        "ANTHROPIC_API_KEY=dummy"
        "ANTHROPIC_BASE_URL=${proxyBaseUrl}"
      ];
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "%h";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Shared background proxy for the persistent Web UI / `opencode serve` flow.
  # This is separate from the temporary per-session proxy started by `oc`.
  systemd.user.services.claude-max-proxy = {
    Unit = {
      Description = "Claude Max proxy for OpenCode";
    };

    Service = {
      ExecStart = "${claude-max-proxy}/bin/claude-max-proxy";
      Environment = [
        "CLAUDE_PROXY_PASSTHROUGH=1"
        "CLAUDE_PROXY_HOST=${proxyHost}"
        "CLAUDE_PROXY_PORT=${toString proxyPort}"
      ];
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "%h";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
