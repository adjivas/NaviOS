{
  inputs,
  den,
  ...
}: {
  den.aspects.waybar.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.waybar = {
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs.nixpkgs-waybar.legacyPackages.${pkgs.stdenv.hostPlatform.system}.waybar;
      };

      height = lib.mkOption {
        type = lib.types.int;
        default = 30;
      };
    };

    config.programs.waybar = {
      enable = true;
      package = config.waybar.package;

      settings.bar = {
        position = lib.mkDefault "top";
        layer = lib.mkDefault "top";
        height = config.waybar.height;
      };
    };
    config.programs.waybar.style = ''
      * {
        font-family: ${config.stylix.fonts.monospace.name};
        font-size: ${(toString config.stylix.fonts.sizes.desktop) + "px"};

        min-height: 0;
        min-width: 0;
        border-radius: 0;
        color: black;
      }
    '';
  };

  den.batteries.waybar = {
    position,
    aspects,
  }: {
    target ? "graphical-session.target",
    display ? "wayland-1",
  }: {user, ...}: let
    sessionName = builtins.head (builtins.match "([^.]+).*" target);
    name = "waybar-${user.userName}-${position}-${display}-${sessionName}";
  in {
    inherit name;

    includes = [den.aspects.waybar] ++ aspects;

    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: let
      inherit position;

      waybarConfig = pkgs.writeText "waybar-${name}.json" (
        builtins.toJSON (config.programs.waybar.settings.bar // {inherit position;})
      );

      waybarStyle = pkgs.writeText "waybar-${name}.css" ''
        ${config.programs.waybar.style}

        window#waybar {
          background-image: linear-gradient(
            to ${position},
            ${config.stylix.base16Scheme.base0C} 0%,
            #0a9a9a 100%
          );
        }
      '';
    in {
      # systemctl --user restart waybar-niri.service
      systemd.user.services.${name} = {
        Unit = {
          Description = "Waybar for ${name}";
          PartOf = [target];
          After = [target];
          ConditionEnvironment = "WAYLAND_DISPLAY=${display}";
        };

        Service = {
          ExecStart = "${lib.getExe config.programs.waybar.package} -c ${waybarConfig} -s ${waybarStyle}";
          Restart = "on-failure";
          RestartSec = 1;

          Environment = [
            "SESSION_ID=${user.userName}-${display}-${sessionName}"
          ];
        };

        Install.WantedBy = [target];
      };
    };
  };
}
