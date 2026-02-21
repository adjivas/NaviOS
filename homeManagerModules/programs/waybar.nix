{ pkgs, lib, config, ... }: let
  hexColor = lib.types.strMatching "^#([0-9a-fA-F]{6}|[0-9a-fA-F]{3}|[0-9a-fA-F]{8})$";
in {
  options = {
    waybar.enable = lib.mkEnableOption "enable waybar";

    waybar.bar = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };

    waybar.modules-right = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    waybar.window = {
      background = lib.mkOption { type = hexColor; default = "#222222"; };
      color = lib.mkOption { type = hexColor; default = "#dddddd"; };
    };

    waybar.workspaces-button = {
      background = lib.mkOption { type = hexColor; default = "#222222"; };
      color = lib.mkOption { type = hexColor; default = "#888888"; };
      hover = {
        background = lib.mkOption { type = hexColor; default = "#2a2a2a"; };
        color = lib.mkOption { type = hexColor; default = "#dddddd"; };
      };
      focused = {
        background = lib.mkOption { type = hexColor; default = "#285577"; };
        color = lib.mkOption { type = hexColor; default = "#ffffff"; };
      };
    };
  };
  config = lib.mkIf config.waybar.enable {
    systemd.user.services.waybar = {
      Unit = {
        PartOf = [ "sway-session.target" ];
        After = [ "sway-session.target" ];
      };
      Service = {
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "sway-session.target" ];
    };
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "tray.target";
      };
      settings.main."tray" = {
        icon-size = 21;
        spacing = 10;
      };
      settings.bar = config.waybar.bar // {
        position = "bottom";
        layer = "top";
        height = 30;
        margin = null;

        "custom/time" = {
          interval = 5;
          exec = ''${pkgs.coreutils}/bin/date "+%a %d/%m %R:%S"'';
          tooltip = false;
        };
        "custom/volume" = let
          getVolume = pkgs.writeShellScriptBin "get-volume.sh" ''
           set -euo pipefail

           source=''$(${pkgs.wireplumber}/bin/wpctl inspect @DEFAULT_AUDIO_SOURCE@ | ${pkgs.gawk}/bin/awk -F'"' '/node.description/ { print $2 }')
           volume=''$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | ${pkgs.gawk}/bin/awk '{print int($2 * 100)}')

           echo "''${source}, ''${volume}%"
         '';
        in {
          format = "Vol({})";
          exec = "${getVolume}/bin/get-volume.sh";
          on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
          interval = 2;
          tooltip = false;
        };
        modules-left = [
          "sway/workspaces" "sway/mode"
        ];
        modules-center = [
          "tray"
        ];
        modules-right = config.waybar.modules-right ++ [
          "custom/volume"
          "custom/time"
        ];
      };
      style = ''
        * {
          font-family: ${config.stylix.fonts.monospace.name};
          font-size: ${(builtins.toString config.stylix.fonts.sizes.desktop) + "px"};
        }

        window#waybar {
          background: ${config.stylix.base16Scheme.base0C};
          color: ${config.stylix.base16Scheme.base00};
          border: none;
        }

        #clock, #pulseaudio, #network, #battery, #tray { padding: 0 6px; }
        #clock label,
        #custom-time {
          font-weight: bold;
          padding-left: 6px;
          padding-right: 6px;
        }

        #workspaces button {
          padding: 0 6px;
          margin: 0;
          background: ${config.stylix.base16Scheme.base0C};
          color: ${config.stylix.base16Scheme.base01};
          border: none;
          box-shadow: none;
        }

        #workspaces button:hover {
          background: ${config.stylix.base16Scheme.base00};
          color: ${config.stylix.base16Scheme.base05};
        }

        #workspaces button.focused {
          background: ${config.stylix.base16Scheme.base05};
          color: ${config.stylix.base16Scheme.base00};
        }

        #workspaces button.active {
          background: ${config.stylix.base16Scheme.base09};
          color: ${config.stylix.base16Scheme.base07};
        }

        #workspaces button.urgent {
          background: ${config.stylix.base16Scheme.base08};
          color: ${config.stylix.base16Scheme.base07};
        }

        .modules-left #workspaces button,
        .modules-left #workspaces button.focused,
        .modules-left #workspaces button.active,
        .modules-center #workspaces button,
        .modules-center #workspaces button.focused,
        .modules-center #workspaces button.active,
        .modules-right #workspaces button,
        .modules-right #workspaces button.focused,
        .modules-right #workspaces button.active {
          border-bottom-width: 0px;
        }

        #workspaces button, tooltip, * {
          border-radius: 0;
        }
      '';
    };
  };
}
