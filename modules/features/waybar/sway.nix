{
  den.aspects.waybar.homeManager = {
    lib,
    config,
    ...
  }: {
    options.waybar = {
      window = {
        background = lib.mkOption {
          default = "#222222";
        };

        color = lib.mkOption {
          default = "#dddddd";
        };
      };

      workspaces-button = {
        background = lib.mkOption {
          default = "#222222";
        };

        color = lib.mkOption {
          default = "#888888";
        };

        hover = {
          background = lib.mkOption {
            default = "rgba(0, 0, 0, 0)";
          };

          color = lib.mkOption {
            default = config.stylix.base16Scheme.base07;
          };
        };

        focused = {
          background = lib.mkOption {
            default = config.stylix.base16Scheme.base00;
          };

          color = lib.mkOption {
            default = config.stylix.base16Scheme.base07;
          };
        };
      };
    };

    config = lib.mkIf config.wayland.windowManager.sway.enable {
      programs.waybar = {
        settings.bar.modules-left = lib.mkDefault [
          "sway/workspaces"
          "sway/mode"
        ];

        style = lib.mkAfter ''
          #workspaces button {
            padding: 0 6px;
            margin: 0;
            color: #1c1b22;
            font-weight: normal;
            border: none;
            box-shadow: none;
            margin-top: 4px;
          }

          #workspaces button:hover {
            background: ${config.waybar.workspaces-button.hover.background};
            color: ${config.waybar.workspaces-button.hover.color};
            font-weight: bold;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
          }

          #workspaces button.focused {
            background: ${config.waybar.workspaces-button.focused.background};
            color: ${config.waybar.workspaces-button.focused.color};
            font-weight: bold;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
            margin-top: 2px;
          }

          #workspaces button.active {
            background: ${config.stylix.base16Scheme.base07};
            color: ${config.stylix.base16Scheme.base00};
            font-weight: bold;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
            margin-top: 2px;
          }

          #workspaces button.urgent {
            background: ${config.stylix.base16Scheme.base08};
            color: ${config.stylix.base16Scheme.base00};
            font-weight: bold;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
            margin-top: 2px;
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
        '';
      };
    };
  };
}
