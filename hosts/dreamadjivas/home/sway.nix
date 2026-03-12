{ config, lib, pkgs, ... }: let
  modifier = "Mod1";
in {
  sway.startup = builtins.map (cmd: { command = cmd; }) [
    "${pkgs.gnome-settings-daemon}/libexec/gsd-rfkill" # BlueTooth
    "${config.firefox.package}/bin/firefox"
    # "${config.firefox.package}/bin/firefox-nightly"
    "${pkgs.kitty}/bin/kitty"
    "${pkgs.thunderbird}/bin/thunderbird"
    # "${pkgs.protonmail-bridge-gui}/bin/protonmail-bridge-gui --no-window"
    # "${pkgs.telegram-desktop}/bin/telegram-desktop"
    "${pkgs.dino}/bin/dino"
    "${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray --enable-webrtc-pipewire-capturer"
    "${pkgs.input-remapper}/bin/input-remapper-control --command autoload"
  ];
  sway.output = {
    "DP-2" = {
      disable = "";
    };
  };

  wayland.windowManager.sway = {
    checkConfig = false;
    config = {
      menu = ''${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu="${pkgs.rofi}/bin/rofi -i -dmenu" --no-generic'';
      input = {
        "type:keyboard" = {
          xkb_file = "/etc/lafayette/qwerty-l.xkb_keymap";
        };
        "1356:2508:Sony_Interactive_Entertainment_Wireless_Controller_Touchpad" = {
          events = "disabled";
        };
        "14000:12294:*" = {
          xkb_numlock = "enabled";
        };
      };
      keybindings = lib.mkOptionDefault {
        "${modifier}+n" = lib.mkForce "exec wl-kbptr-sway -o modes=floating,click -o mode_floating.source=detect";
        # Toggle the waybar
        "${modifier}+b" = lib.mkForce "exec ${pkgs.procps}/bin/pkill -SIGUSR1 waybar";
        # Switch between workspaces
        "${config.sway.modifier}+Tab" = ''exec ${config.sway.package}/bin/swaymsg workspace back_and_forth'';
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

      seat "seat3" {
        hide_cursor 5000
        xcursor_theme blueAdwaita 12
        attach 0:0:Dualshock_(evsieve)_Mouse_blue
      }
      seat "seat4" {
        hide_cursor 5000
        xcursor_theme orangeAdwaita 12
        attach 0:0:Dualshock_(evsieve)_Mouse_orange
      }
      seat "seat5" {
        hide_cursor 5000
        xcursor_theme purpleAdwaita 12
        attach 0:0:Dualshock_(evsieve)_Mouse_purple
      }
    '';
  };
}
