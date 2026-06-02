{ config, ... }:
let
  username = config.system.primaryUser;
  homeDirectory = "/Users/${username}";
in
{
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      NewWindowTarget = "Home";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXSortFoldersFirst = true;
    };

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      _HIHideMenuBar = false;
      "com.apple.swipescrolldirection" = false;
    };

    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };

    screencapture = {
      location = "${homeDirectory}/Pictures";
    };

    trackpad = {
      Clicking = true;
    };
  };

  system.activationScripts.postActivation.text = ''
    chflags nohidden "${homeDirectory}/Library" || true
  '';
}
