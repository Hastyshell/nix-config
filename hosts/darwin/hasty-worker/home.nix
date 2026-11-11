{ pkgs, ... }:
{
  home.packages = [
    pkgs.bun
  ];

  # codex-acp 0.13 rejects this host's service_tier = "priority" spelling.
  # Use its equivalent spelling only for Zed, leaving the global Codex config alone.
  # https://developers.openai.com/api/docs/guides/fast-mode
  programs.zed-editor.userSettings.agent_servers.Codex.args = [
    "-c"
    ''service_tier="fast"''
  ];
}
