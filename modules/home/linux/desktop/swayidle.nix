{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.custom.linux.desktop.swayidle.enable {
    services.swayidle =
      let
        # Lock command
        lock = "${config.programs.swaylock.package}/bin/swaylock -f";
        wm = config.custom.linux.desktop.wm;
        # Sway
        # display = status: "swaymsg 'output * power ${status}'"; \
        # Hyprland
        # display = status: "hyprctl dispatch dpms ${status}";
        # Niri
        display =
          if wm.niri.enable then
            (status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors")
          else
            (status: "echo 'No WM configured, ignoring'");
      in
      {
        enable = true;
        timeouts = [
          {
            timeout = 295; # in seconds
            command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
          }
          {
            timeout = 300;
            command = lock;
          }
          {
            timeout = 360;
            command = display "off";
            resumeCommand = display "on";
          }
          {
            timeout = 600;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            # adding duplicated entries for the same event may not work
            command = (display "off") + "; " + lock;
          }
          {
            event = "after-resume";
            command = display "on";
          }
          {
            event = "lock";
            command = (display "off") + "; " + lock;
          }
          {
            event = "unlock";
            command = display "on";
          }
        ];
      };

  };
}
