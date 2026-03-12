{ pkgs, lib, ... }: {
  sway.startup = builtins.map (cmd: { command = cmd; }) [
    "${pkgs.firefox}/bin/firefox"
    "${pkgs.kitty}/bin/kitty"
  ];
  sway.modifier = "Super";

  wayland.windowManager.sway = {
    checkConfig = false;
    config = {
      menu = ''${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu="${pkgs.rofi}/bin/rofi -i -dmenu" --no-generic'';
      input = {
        "type:keyboard" = {
          xkb_file = "/etc/lafayette/qwerty-l.xkb_keymap";
        };
        "36b0:3006:*" = {
          xkb_numlock = "enabled";
        };
      };
    };
    # swaymsg -t get_inputs
    extraConfig = ''
      bindgesture swipe:left workspace next
      bindgesture swipe:right workspace prev

      seat "seat0" {
        hide_cursor 5000
        xcursor_theme yellowAdwaita 12
        attach 65261:0:Bregoli_Swiss
        fallback true
      }
    '';
  };
}
