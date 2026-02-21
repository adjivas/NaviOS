{ pkgs, lib, config, ... }: {
  options = {
    sway.enable = lib.mkEnableOption "enable sway";
    sway.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sway;
    };
    sway.modifier = lib.mkOption {
      type = lib.types.str;
      default = "Mod1";
      description = "The modifier key used in the configuration.";
    };
    sway.window = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "Windows list";
    };
    sway.output = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Output display";
    };
    sway.terminal = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.kitty}/bin/kitty";
      description = "The terminal";
    };
    sway.startup = lib.mkOption {
      type = with lib.types; listOf (submodule {
        options.command = lib.mkOption {
          type = str;
          description = "Command to run at startup.";
        };
      });
      default = builtins.map (cmd: { command = cmd; }) [
        "${pkgs.kitty}/bin/kitty"
      ];
      description = "Launch common Apps on start";
    };
  };
  config = lib.mkIf config.sway.enable {
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;
      package = config.sway.package;
      config = {
        bars = [];
        floating.border = 0;
        defaultWorkspace = "workspace number 1";
        modifier = "${config.sway.modifier}";
        terminal = config.sway.terminal;
        startup = config.sway.startup;
        output = config.sway.output;
        assigns = {
          "1" = [
            {app_id = "firefox";}
          ];
        };
        input = {
          "type:touchpad" = {
            natural_scroll = "enabled";
            tap = "enabled";
          };
        };
        window = {
          titlebar = false;
          border = 0;
          commands = config.sway.window ++ [
            {
              criteria = { floating = true; };
              command = "border none";
            }
            {
              criteria = { app_id = "kitty-in-space"; };
              command = "floating enable, resize set 700 800, sticky enable";
            }
            {
              criteria = { title = "Picture-in-Picture"; };
              command = "floating enable, resize set 700 800, sticky enable, opacity 0.8";
            }
            {
              criteria = { app_id = "ch.proton.bridge-gui"; };
              command = "move to workspace 8";
            }
            {
              criteria = { app_id = "thunderbird"; };
              command = "move to workspace 8";
            }
            {
              criteria = { app_id = "org.telegram.desktop"; };
              command = "move to workspace 9";
            }
            {
              criteria = { app_id = "crashreporter"; };
              command = "kill";
            }
          ];
        };
        keybindings = lib.mkOptionDefault {
          # Kitty in Space!
          "${config.sway.modifier}+Shift+Return" = ''exec ${config.sway.terminal} --class "kitty-in-space"'';
          # Take screenshot
          "${config.sway.modifier}+p" = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';
          # Recording
          "${config.sway.modifier}+Shift+p mode \"recording\";" = ''exec ${pkgs.wf-recorder}/bin/wf-recorder --codec libvpx --geometry "$(${pkgs.slurp}/bin/slurp)" --file=/tmp/$(date +recorder_%Y-%m-%d-%H%M%S.webm)'';
        };
        modes = lib.mkOptionDefault {
          recording = {
            Escape = "exec ${pkgs.killall}/bin/killall -s SIGINT wf-recorder; mode default";
          };
        };
        fonts = {
          names = [ config.stylix.fonts.monospace.name ];
          style = "Regular";
          size = config.stylix.fonts.sizes.desktop * 0.75;
        };
        colors = {
          focused = {
            border      = config.stylix.base16Scheme.base01;
            background  = config.stylix.base16Scheme.base05;
            text        = config.stylix.base16Scheme.base00;
            indicator   = config.stylix.base16Scheme.base01;
            childBorder = config.stylix.base16Scheme.base01;
          };
          unfocused = {
            border      = config.stylix.base16Scheme.base01;
            background  = config.stylix.base16Scheme.base00;
            text        = config.stylix.base16Scheme.base0C;
            indicator   = config.stylix.base16Scheme.base01;
            childBorder = config.stylix.base16Scheme.base01;
          };
        };
      };
    }; 
  }; 
} 
