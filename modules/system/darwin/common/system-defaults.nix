{ config, ... }:
let
  username = config.system.primaryUser;
  homeDirectory = "/Users/${username}";
  dockApps = [
    "/System/Applications/Apps.app"
    "${homeDirectory}/Applications/Home Manager Apps/Google Chrome.app"
    "/Applications/iTerm.app"
    "/Applications/Codex.app"
    "/Applications/Clash Verge.app"
    "${homeDirectory}/Applications/Home Manager Apps/Visual Studio Code.app"
    "/Applications/WeChat.app"
    "/System/Applications/Messages.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Maps.app"
    "/System/Applications/Calendar.app"
    "/System/Applications/Phone.app"
    "/System/Applications/iPhone Mirroring.app"
    "/System/Applications/System Settings.app"
  ];
in
{
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    dock = {
      autohide = true;
      largesize = 64;
      magnification = true;
      orientation = "bottom";
      persistent-apps = map (app: { inherit app; }) dockApps;
      persistent-others = [ ];
      show-recents = false;
      tilesize = 56;
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
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      InitialKeyRepeat = 10;
      KeyRepeat = 1;
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
