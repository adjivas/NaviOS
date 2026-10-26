{
  den.aspects.sway.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.sway = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.sway;
        example = pkgs.swayfx;
      };
      modifier = lib.mkOption {
        type = lib.types.str;
        default = "Super";
        description = "The modifier key used in the configuration.";
      };
      background = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      window = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [];
        description = "Windows list";
        example = [
          {
            criteria = {app_id = "ch.proton.bridge-gui";};
            command = "move to workspace 8";
          }
          {
            criteria = {app_id = "thunderbird";};
            command = "move to workspace 8";
          }
          {
            criteria = {app_id = "org.ajim.Gajim";};
            command = "move to workspace 9";
          }
          {
            criteria = {app_id = "im.dino.Dino";};
            command = "move to workspace 9";
          }
          {
            criteria = {app_id = "signal";};
            command = "move to workspace 9";
          }
          {
            criteria = {app_id = "org.telegram.desktop";};
            command = "move to workspace 9";
          }
        ];
      };
      output = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Output display";
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "${pkgs.kitty}/bin/kitty";
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = config.stylix.fonts.sizes.terminal;
      };
      colors = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
      radius = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
      };
      startup = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options.command = lib.mkOption {
            type = lib.types.str;
          };
        });
        default = [{command = config.sway.terminal;}];
      };
      unsupportedGpu = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Start Sway with --unsupported-gpu.";
      };
    };
    config = {
      stylix.targets.sway.enable = false;

      home.file.".xsession" = {
        executable = true;
        text = ''
          exec ${config.sway.package}/bin/sway${
            lib.optionalString config.sway.unsupportedGpu " --unsupported-gpu"
          }
        '';
      };
      wayland.windowManager.sway = {
        enable = true;
        systemd.enable = true;
        package = config.sway.package;
        wrapperFeatures.gtk = true;
        config = {
          bars = [];
          floating.border = 0;
          defaultWorkspace = "workspace number 1";
          modifier = config.sway.modifier;
          terminal = config.sway.terminal;
          startup =
            config.sway.startup
            ++ lib.optionals (config.sway.background != null) [
              {
                command = ''
                  ${lib.getExe pkgs.swaybg} \
                    -i ${lib.escapeShellArg (toString config.sway.background)} \
                    -m fill
                '';
              }
            ];
          output = config.sway.output;
          input = {
            "type:touchpad" = {
              natural_scroll = "enabled";
              tap = "enabled";
            };
            "type:keyboard" = {
              xkb_numlock = "enabled";
            };
          };
          window = {
            titlebar = false;
            border = 0;
            commands =
              config.sway.window
              ++ [
                {
                  criteria = {floating = true;};
                  command = "border none";
                }
                {
                  criteria = {app_id = "kitty-in-space";};
                  command = "floating enable, resize set 700 800, sticky enable";
                }
                {
                  criteria.title = "^(Picture-in-Picture|Incrustation vidéo)$";
                  command = "floating enable, resize set 700 800, sticky enable, opacity 0.8";
                }
                {
                  criteria.class = "^vlc$";
                  command = "floating enable, sticky enable, resize set width 640 px height 360 px, move position center";
                }
                {
                  criteria = {app_id = "crashreporter";};
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
            names = [config.stylix.fonts.monospace.name];
            style = "Regular";
            size = toString config.sway.size;
          };
          colors =
            lib.recursiveUpdate {
              focused = {
                border = config.stylix.base16Scheme.base0C;
                background = config.stylix.base16Scheme.base00;
                text = config.stylix.base16Scheme.base0C;
                indicator = config.stylix.base16Scheme.base01;
                childBorder = config.stylix.base16Scheme.base01;
              };
              unfocused = {
                border = config.stylix.base16Scheme.base00;
                background = config.stylix.base16Scheme.base00;
                text = config.stylix.base16Scheme.base07;
                indicator = config.stylix.base16Scheme.base01;
                childBorder = config.stylix.base16Scheme.base01;
              };
            }
            config.sway.colors;
        };
        extraConfig = lib.optionalString (config.sway.radius != null) ''
          corner_radius ${toString config.sway.radius}
        '';
      };
    };
  };
}
