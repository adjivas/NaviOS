{inputs, ...}: {
  den.aspects.anyrun.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    anyrunPackages = inputs.anyrun.packages.${system};
  in {
    imports = [
      ({modulesPath, ...}: {
        disabledModules = [
          "${modulesPath}/programs/anyrun.nix"
        ];
      })

      inputs.anyrun.homeManagerModules.default
    ];

    options.anyrun.package = lib.mkOption {
      type = lib.types.package;
      default = anyrunPackages.anyrun;
    };

    config = {
      systemd.user.services.anyrun.Service.KillMode = lib.mkForce "control-group";

      programs.anyrun = {
        enable = true;
        package = config.anyrun.package;

        config = {
          x = {fraction = 0.5;};
          y = {fraction = 0.2;};
          width = {fraction = 0.55;};

          ignoreExclusiveZones = true;
          closeOnClick = false;
          showResultsImmediately = false;
          maxEntries = null;
          layer = "overlay";

          hideIcons = false;
          hidePluginInfo = true;

          plugins = with anyrunPackages; [
            translate
            rink
            applications
            symbols
          ];

          keybinds = [
            {
              key = "Return";
              action = "select";
            }

            {
              key = "Up";
              action = "up";
            }
            {
              key = "Down";
              action = "down";
            }

            {
              key = "k";
              action = "up";
              ctrl = true;
            }
            {
              key = "j";
              action = "down";
              ctrl = true;
            }

            {
              key = "Escape";
              action = "close";
            }
          ];
        };

        extraCss = ''
          @define-color fg-color #eeeeee;
          @define-color desc-color #cccccc;

          window {
            background: #0dcdcd50;
          }

          .matches,
          .plugin,
          list.plugin {
            background: transparent;
          }

          box.main {
            padding: 15px;
            border-radius: 15px;
            min-height: 100px;
          }

          text {
            font-size: 24px;
            min-height: 30px;
            padding: 5px;
            color: #0dcdcd;
            background: gray;
            border-radius: 10px;
          }

          box.plugin:first-child {
            margin-top: 15px;
          }

          box.plugin.info {
            min-width: 200px;
          }

          label.match {
            color: @fg-color;
            font-size: 24px;
          }

          label.match.description {
            font-size: 20px;
            color: @desc-color;
          }

          label.plugin.info {
            font-size: 24px;
            font-weight: bold;
            color: @fg-color;
          }

          .matches {
            border-top: 1px solid rgba(255, 255, 255, 0.18);
            margin-top: 15px;
          }

          .match {
            padding: 2.5px 0px 2.5px 0px;
          }

          .match:selected {
            background: #0dcdcd;
            animation: fade 0.1s linear;
            border-radius: 10px;
            border: 1px solid #eeeeee;
          }

          .match:selected label {
            color: #1c1b22;
            font-weight: bold;
          }

          @keyframes fade {
            0% {
              opacity: 0;
            }

            100% {
              opacity: 1;
            }
          }
        '';

        extraConfigFiles."applications.ron".text = ''
          Config(
            desktop_actions: false,
            max_entries: 3,
            terminal: Some("kitty"),
          )
        '';

        extraConfigFiles."symbols.ron".text = ''
          Config(
            max_entries: 1,
          )
        '';

        extraConfigFiles."translate.ron".text = ''
          Config(
            prefix: ":",
            language_delimiter: ">",
            max_entries: 1,
          )
        '';
      };
    };
  };
}
