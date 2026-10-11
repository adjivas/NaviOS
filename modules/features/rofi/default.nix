{
  den.aspects.rofi.homeManager = {
    config,
    pkgs,
    lib,
    wrappers,
    niri,
    ...
  }: let
    mkL = config.lib.formats.rasi.mkLiteral;

    rofi-sticker-send = pkgs.writeShellApplication {
      name = "rofi-sticker-send";

      runtimeInputs = [
        niri
        pkgs.wl-clipboard
        pkgs.wtype
      ];

      text = builtins.readFile ./rofi-sticker-send.sh;
    };
    rofi-sticker-list = pkgs.writeShellApplication {
      name = "rofi-sticker-list";

      runtimeInputs = with pkgs; [
        coreutils
        findutils
        util-linux
      ];

      text = ''
        ROFI_STICKER_SEND=${lib.escapeShellArg (lib.getExe rofi-sticker-send)}
        ${builtins.readFile ./rofi-sticker-list.sh}
      '';
    };
  in {
    options.rofi = {
      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;

        default = wrappers {
          inherit pkgs;

          package = config.programs.rofi.finalPackage;

          exePath = pkgs.writeShellScript "rofi" ''
            if [ "$#" -eq 0 ]; then
              exec ${lib.getExe config.programs.rofi.finalPackage} -show combi
            else
              exec ${lib.getExe config.programs.rofi.finalPackage} "$@"
            fi
          '';

          binName = "rofi";
        };
      };

      selectorBackgroundColor = lib.mkOption {
        type = lib.types.str;
        default = "#00ffff";
      };

      selectorColor = lib.mkOption {
        type = lib.types.str;
        default = "#000000";
      };

      inputTextColor = lib.mkOption {
        type = lib.types.str;
        default = "#0dcdcd";
      };
    };

    config = {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi;

        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
        ];

        modes = [
          "combi"
          "drun"
          "calc"
          "emoji"
        ];

        extraConfig = {
          combi-modes = "drun,calc,emoji,sticker:${lib.getExe rofi-sticker-list}";
          combi-hide-mode-prefix = true;

          show-icons = true;

          drun-display-format = "{name}  <span alpha='55%' size='smaller'>{comment}</span>";

          calc = {
            hint-result = "";
            hint-welcome = "";
          };
        };

        theme = lib.mkForce {
          "*" = {
            background-color = mkL "transparent";
            text-color = mkL config.stylix.base16Scheme.base05;

            font = "${config.stylix.fonts.sansSerif.name} ${toString config.stylix.fonts.sizes.desktop}";

            margin = 0;
            padding = 0;
            spacing = 0;
          };

          window = {
            location = mkL "center";
            anchor = mkL "center";

            width = mkL "760px";

            # Deliberately translucent:
            # Niri-glass provides the blur behind it.
            background-color = mkL "rgba(24, 24, 30, 0.72)";

            border = mkL "0px";
            border-radius = mkL "18px";

            padding = mkL "12px";

            children = map mkL [
              "mainbox"
            ];
          };

          mainbox = {
            spacing = mkL "0px";

            children = map mkL [
              "inputbar"
              "message"
              "listview"
            ];
          };

          inputbar = {
            orientation = mkL "horizontal";

            padding = mkL "16px 18px";

            background-color = mkL "rgb(45, 45, 50)";

            border = mkL "0px";
            border-radius = mkL "12px";

            spacing = mkL "12px";

            children = map mkL [
              "entry"
            ];
          };

          entry = {
            expand = true;

            margin = mkL "0px";
            padding = mkL "0px";

            background-color = mkL "transparent";
            text-color = mkL config.rofi.inputTextColor;

            placeholder = "Search";
            placeholder-color = mkL config.stylix.base16Scheme.base03;

            horizontal-align = mkL "0.0";
            vertical-align = mkL "0.5";

            cursor = mkL "text";
          };

          /*
          * Used notably by rofi-calc to display its result.
          */
          message = {
            background-color = mkL "transparent";

            border = mkL "0px 0px 1px 0px";
            border-color = mkL "rgba(255, 255, 255, 0.16)";

            padding = mkL "0px";
            margin = mkL "12px 0px 0px 0px";
          };

          textbox = {
            background-color = mkL "transparent";
            text-color = mkL config.stylix.base16Scheme.base05;

            padding = mkL "10px 12px";

            horizontal-align = mkL "0.0";
            vertical-align = mkL "0.5";
          };

          listview = {
            layout = mkL "vertical";

            lines = 7;
            columns = 1;

            spacing = mkL "4px";

            fixed-height = false;
            dynamic = true;

            scrollbar = false;

            background-color = mkL "transparent";

            # Separator between search and results.
            border = mkL "1px 0px 0px 0px";
            border-color = mkL "rgba(255, 255, 255, 0.16)";

            padding = mkL "12px 0px 0px 0px";
            margin = mkL "12px 0px 0px 0px";
          };

          element = {
            orientation = mkL "horizontal";

            padding = mkL "12px";
            spacing = mkL "14px";

            border = mkL "0px";
            border-radius = mkL "10px";

            background-color = mkL "transparent";

            children = map mkL [
              "element-icon"
              "element-text"
            ];
          };

          "element selected normal" = {
            background-color = mkL config.rofi.selectorBackgroundColor;
            text-color = mkL config.rofi.selectorColor;
          };

          "element selected active" = {
            background-color = mkL config.rofi.selectorBackgroundColor;
            text-color = mkL config.rofi.selectorColor;
          };

          element-icon = {
            size = mkL "42px";

            background-color = mkL "transparent";

            vertical-align = mkL "0.5";
          };

          element-text = {
            expand = true;

            background-color = mkL "transparent";
            text-color = mkL "inherit";

            markup = true;

            vertical-align = mkL "0.5";
          };
        };
      };
    };
  };
}
