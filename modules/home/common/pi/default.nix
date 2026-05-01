{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    pi
    bat
    delta
    glow
  ];

  home.file = {
    ".pi/agent/settings.json".source = "${inputs.pi-config}/settings.json";
    ".pi/agent/AGENTS.md".source = "${inputs.pi-config}/AGENTS.md";
    ".pi/agent/skills".source = "${inputs.pi-config}/skills";
    ".pi/agent/prompts".source = "${inputs.pi-config}/prompts";
    ".pi/agent/extensions".source = "${inputs.pi-config}/extensions";
    ".pi/agent/themes".source = "${inputs.pi-config}/themes";
  };

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
  };
}
