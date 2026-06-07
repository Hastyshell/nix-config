{
  config,
  inputs,
  ...
}:
let
  username = config.system.primaryUser;
  commonCasks = [
    "codex-app"
    "google-chrome"
    "intellij-idea-ce"
    "iterm2"
    "maccy"
    "stats"
    "visual-studio-code"
  ];
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };
    brews = [
      "brew-cask-completion"
      "mas"
    ];
    casks = commonCasks;
    masApps = { };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    autoMigrate = true;
    mutableTaps = false;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };
}
