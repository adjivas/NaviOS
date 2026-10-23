{
  inputs,
  self,
  den,
  ...
}: {
  den.batteries.niri-session = {
    display,
    includes,
  }: {
    name = "niri-session-${display}";

    includes =
      [den.aspects.niri]
      ++ map
      (battery:
        battery {
          target = "niri.service";
          inherit display;
        })
      includes;
  };

  den.aspects.niri = {
    includes = [
      (den.lib.policy.when
        ({user, ...}: user.hasAspect den.aspects.anyrun)
        den.aspects.niri-anyrun)

      (den.lib.policy.when
        ({user, ...}: user.hasAspect den.aspects.rofi)
        den.aspects.niri-rofi)
    ];
    nixos = {pkgs, ...}: let
      system = pkgs.stdenv.hostPlatform.system;
      niri = inputs.niri.packages.${system}.niri;
    in {
      programs.niri = {
        enable = true;
        package = niri;
      };
    };
    homeManager = {
      config,
      pkgs,
      lib,
      ...
    }: let
      system = pkgs.stdenv.hostPlatform.system;
      niri = inputs.niri.packages.${system}.niri;
    in {
      imports = [
        inputs.niri-flake.homeModules.niri
      ];
      options.niri = {
        package = lib.mkOption {
          type = lib.types.package;
          default = niri;
        };
        includes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        modifier = lib.mkOption {
          type = lib.types.str;
          default = "Mod";
        };
        viewport-columns = lib.mkOption {
          type = lib.types.ints.positive;
          default = 2;
        };
        background = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
        };

        terminal = lib.mkOption {
          type = lib.types.package;
          default = pkgs.kitty;
        };
        lock = lib.mkOption {
          type = lib.types.package;
          default = config.programs.swaylock.package;
        };

        radius = lib.mkOption {
          type = lib.types.nullOr lib.types.float;
          default = 10.0;
        };

        launcher = lib.mkOption {
          type = lib.types.package;
          default = config.rofi.package;
        };

        colors = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };

        xkbFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "/etc/lafayette/qwerty-l.xkb_keymap";
        };

        startup = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options.command = lib.mkOption {
              type = lib.types.str;
            };
          });

          default = [
            {
              command = lib.getExe config.niri.terminal;
            }
          ];
        };
      };

      config = let
        columnProportion = 1.0 / config.niri.viewport-columns;
        columnPercent = "${toString (100.0 / config.niri.viewport-columns)}%";
      in {
        home.packages = [
          pkgs.xwayland-satellite
        ];
        xdg.configFile.niri-config.source = lib.mkForce (
          pkgs.writeText "niri-config.kdl" ''
            ${config.programs.niri.finalConfig}

            ${lib.concatMapStringsSep "\n" (path: ''
                include "${path}"
              '')
              config.niri.includes}
          ''
        );

        programs.niri.settings = {
          outputs."eDP-1".scale = 2.0;
          outputs."HDMI-A-2".enable = false;

          animations = {
            window-open = {
              kind.easing = {
                duration-ms = 1500;
                curve = "ease-out-cubic";
              };
              custom-shader = builtins.readFile "${self.outPath}/artwork/shaders/open.glsl";
            };

            window-close = {
              kind.easing = {
                duration-ms = 1000;
                curve = "ease-out-cubic";
              };
              custom-shader = builtins.readFile "${self.outPath}/artwork/shaders/close.glsl";
            };
            window-resize = {
              kind.spring = {
                damping-ratio = 1.0;
                stiffness = 800;
                epsilon = 0.0001;
              };

              custom-shader = builtins.readFile "${self.outPath}/artwork/shaders/niri_resize.glsl";
            };
            window-movement = {
              kind.spring = {
                damping-ratio = 1.0;
                stiffness = 500;
                epsilon = 0.0001;
              };
            };
          };
          cursor = {
            theme = "cyanAdwaita";
            size = 24;
          };

          hotkey-overlay = {
            skip-at-startup = true;
          };

          input = {
            keyboard = lib.mkIf (config.niri.xkbFile != null) {
              xkb.file = config.niri.xkbFile;
            };

            warp-mouse-to-focus = {
              mode = "center-xy-always";
            };
          };
          gestures = {
            hot-corners.enable = false;
          };

          spawn-at-startup = map (entry: {sh = entry.command;}) config.niri.startup;

          overview = {
            workspace-shadow.enable = false;
          };

          layer-rules = [
            {
              matches = [
                {namespace = "^awww-daemonawww-overview$";}
              ];

              place-within-backdrop = true;
            }
            # Rofi
            {
              matches = [
                {
                  namespace = "^rofi$";
                }
              ];

              shadow = {
                enable = true;
                softness = 20;
                spread = 4;
                offset = {
                  x = 0;
                  y = 6;
                };
                color = "#00000090";
              };
            }
            # Waybar
            {
              matches = [
                {
                  namespace = "^waybar$";
                }
              ];

              shadow = {
                enable = true;
                softness = 10;
                spread = 2;
                offset = {
                  x = 0;
                  y = 3;
                };
                color = "#00000090";
              };
            }
          ];

          layout = {
            gaps = 5;

            default-column-width.proportion = columnProportion;

            # background-color = "#00FFFFff";
            background-color = "transparent";

            focus-ring.enable = false;
            border.enable = false;

            shadow = {
              enable = true;
              softness = 20;
              spread = 4;
              offset = {
                x = 0;
                y = 0;
              };
              color = "#00000080";
              inactive-color = "#00000000";
            };

            struts = {
              left = 2;
              right = 2;
              top = 0;
              bottom = 0;
            };
          };

          window-rules = [
            # Rounded corners
            {
              clip-to-geometry = true;

              geometry-corner-radius = {
                top-left = config.niri.radius;
                top-right = config.niri.radius;
                bottom-left = config.niri.radius;
                bottom-right = config.niri.radius;
              };
            }
            {
              matches = [
                {
                  app-id = "kitty-in-space";
                }
              ];

              open-floating = true;
              default-column-width.proportion = 0.25;
              default-window-height.proportion = 0.25;
            }

            # Picture-in-Picture
            {
              matches = [
                {
                  title = "^(Picture-in-Picture|Incrustation vidéo)$";
                }
              ];

              open-floating = true;
              default-column-width.proportion = 0.25;
              default-window-height.proportion = 0.25;
              opacity = 0.8;
            }

            # VLC
            {
              matches = [
                {
                  app-id = "(?i)^vlc$";
                }
              ];

              open-floating = true;
              default-column-width.proportion = 0.25;
              default-window-height.proportion = 0.25;
            }
          ];

          binds = let
            modifier = config.niri.modifier;
            niriExe = lib.getExe niri;
            jq = lib.getExe pkgs.jq;
          in {
            # "${modifier}+Menu".action.toggle-overview = {};
            "${modifier}+Escape".action.spawn-sh = ''
              ${lib.getExe config.niri.lock} --daemonize && ${niriExe} msg action power-off-monitors
            '';

            "${modifier}+E".action.quit = {};
            "${modifier}+Q".action.close-window = {};
            "${modifier}+Shift+Q".action.spawn-sh = ''
              pid="$(${niriExe} msg --json focused-window | ${jq} -r '.pid // empty')"

              [ -n "$pid" ] && ${pkgs.coreutils}/bin/kill -9 "$pid"
            '';

            "${modifier}+Return".action.spawn-sh = ''
              ${niriExe} msg action set-column-width "${columnPercent}"
              exec ${lib.getExe config.niri.terminal}
            '';
            "${modifier}+Shift+Return".action.spawn = [
              (lib.getExe config.niri.terminal)
              "--class"
              "kitty-in-space"
            ];

            "${modifier}+D".action.spawn = [
              (lib.getExe config.niri.launcher)
            ];

            "${modifier}+L".action.focus-column-right = {};
            "${modifier}+H".action.focus-column-left = {};
            "${modifier}+J".action.focus-workspace-down = {};
            "${modifier}+K".action.focus-workspace-up = {};

            # Move
            "${modifier}+Shift+H".action.move-column-left = {};
            "${modifier}+Shift+L".action.move-column-right = {};
            "${modifier}+Shift+J".action.move-column-to-workspace-down = {};
            "${modifier}+Shift+K".action.move-column-to-workspace-up = {};
            "${modifier}+C".action.center-column = {};

            # Resize
            "${modifier}+Ctrl+H".action.set-window-width = "-5%";
            "${modifier}+Ctrl+L".action.set-window-width = "+5%";
            "${modifier}+Ctrl+J".action.set-window-height = "+5%";
            "${modifier}+Ctrl+K".action.set-window-height = "-5%";
            "${modifier}+W".action.spawn-sh = ''
              width="$(${niriExe} msg --json focused-window | ${jq} -r '.layout.tile_size[0]')"
              screen_width="$(${niriExe} msg --json outputs | ${jq} -r '.[].logical.width')"

              if [ "$(echo "$width > $screen_width/2" | ${lib.getExe pkgs.bc})" = 1 ]; then
                ${niriExe} msg action set-column-width "${toString columnPercent}"
              else
                ${niriExe} msg action set-column-width "100%"
              fi
            '';

            "${modifier}+F".action.maximize-window-to-edges = {};
            # "${modifier}+Shift+F".action.toggle-windowed-fullscreen = {};

            # Stack
            "${modifier}+Period".action.consume-window-into-column = {};
            "${modifier}+Comma".action.expel-window-from-column = {};

            # Floating
            "${modifier}+Space".action.switch-focus-between-floating-and-tiling = {};

            "${modifier}+Shift+Space".action.spawn-sh = ''
              ${niriExe} msg action toggle-window-floating
              ${niriExe} msg action set-column-width "25%"
              ${niriExe} msg action set-window-height "25%"
            '';

            # Screenshot
            "${modifier}+P".action.screenshot = {};
            "${modifier}+Shift+P".action.screenshot-window = {};
            "${modifier}+Ctrl+P".action.screenshot-screen = {};

            # Record
            "${modifier}+R".action.spawn-sh = ''
              videos_dir="${config.xdg.userDirs.videos or "$HOME/Videos"}"
              ${pkgs.coreutils}/bin/mkdir -p "$videos_dir"

              if ! ${pkgs.procps}/bin/pgrep -x wf-recorder >/dev/null; then
                ${pkgs.coreutils}/bin/timeout -s INT 30s \
                  ${pkgs.wf-recorder}/bin/wf-recorder \
                    --codec libvpx \
                    --geometry "$(${pkgs.slurp}/bin/slurp)" \
                    --file="$videos_dir/$(${pkgs.coreutils}/bin/date +recorder_%Y-%m-%d-%H%M%S.webm)"
              fi
            '';

            "${modifier}+Shift+R".action.spawn-sh = ''
              ${pkgs.killall}/bin/killall -s SIGINT wf-recorder 2>/dev/null || true
            '';

            # Invisibility
            "${modifier}+I".action.toggle-window-rule-opacity = {};
          };

          prefer-no-csd = true;
        };
      };
    };
  };
}
