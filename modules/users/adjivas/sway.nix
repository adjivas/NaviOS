{
  den.aspects.adjivas.homeManager = {
    lib,
    pkgs,
    ...
  }: let
    modifier = "Mod1";
  in {
    sway.startup = builtins.map (cmd: {command = cmd;}) [
      "${pkgs.gnome-settings-daemon}/libexec/gsd-rfkill" # BlueTooth
      # "${config.firefox.package}/bin/firefox"
      # "${config.firefox.package}/bin/firefox-nightly"
      "${pkgs.kitty}/bin/kitty"
      # "${pkgs.thunderbird}/bin/thunderbird"
      # "${pkgs.protonmail-bridge-gui}/bin/protonmail-bridge-gui --no-window"
      "${pkgs.gajim}/bin/gajim"
      # "${pkgs.dino}/bin/dino"
      # "${pkgs.signal-desktop}/bin/signal"
      "${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray --enable-webrtc-pipewire-capturer"
      "${pkgs.telegram-desktop}/bin/Telegram"
      # "${pkgs.input-remapper}/bin/input-remapper-control --command autoload"
    ];
    sway.output = {
      "DP-2" = {
        disable = "";
      };
    };

    wayland.windowManager.sway = {
      checkConfig = false;
      config = {
        assigns = {
          "1" = [
            {app_id = "firefox";}
          ];
        };
        menu = ''${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu="${pkgs.rofi}/bin/rofi -i -dmenu" --no-generic'';
        input = {
          "type:keyboard" = {
            xkb_file = "/etc/lafayette/qwerty-l.xkb_keymap";
          };
          "1356:2508:Sony_Interactive_Entertainment_Wireless_Controller_Touchpad" = {
            events = "disabled";
          };
          "9011:26214:ydotoold_virtual_device" = {
            accel_profile = "flat";
            pointer_accel = "0";
          };
          "14000:12294:*" = {
            xkb_numlock = "enabled";
          };
        };
        keybindings = lib.mkOptionDefault {
          "${modifier}+m" = lib.mkForce "exec wl-kbptr-ydotool";
          "${modifier}+Shift+m" = lib.mkForce "exec wl-kbptr-ydotool-sway";
          # Toggle the waybar
          "${modifier}+b" = lib.mkForce "exec ${pkgs.procps}/bin/pkill -SIGUSR1 waybar";
        };
      };
      # swaymsg -t get_inputs
      extraConfig = ''
        bindgesture swipe:left workspace next
        bindgesture swipe:right workspace prev

        seat "seat0" {
          hide_cursor 5000
          xcursor_theme cyanAdwaita 12
          attach 65261:4871:Ergodox_EZ_Ergodox_EZ
          attach 1452:613:Apple_Inc._Magic_Trackpad_2
          fallback true
        }

        seat "seat1" {
          hide_cursor 5000
          xcursor_theme yellowAdwaita 12
          attach 12538:1024:USB_Optical_Mouse
        }

        seat "seat2" {
          hide_cursor 30000
          xcursor_theme magentaAdwaita 12
          attach 1386:782:Wacom_Intuos_S_Pen
        }
      '';
    };
  };
}
