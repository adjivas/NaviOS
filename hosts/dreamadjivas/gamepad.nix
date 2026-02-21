{ lib, pkgs, ... }: let
  ds4 = {
    blue = {
      mac = "10:18:49:a1:9b:26";
      color = {
        green = 0;
        red = 0;
        blue = 255;
      };
    };

    orange = {
      mac = "d0:bc:c1:a4:5f:98";
      color = {
        green = 128;
        red = 255;
        blue = 0;
      };
    };

    purple = {
      mac = "a4:53:85:94:03:f3";
      color = {
        green = 0;
        red = 127;
        blue = 255;
      };
    };
  };
in {
  home-manager.users.adjivas.waybar.modules-right = lib.mkBefore [
    "battery#ps-controller-1"
    "battery#ps-controller-2"
    "battery#ps-controller-3"
  ];
  home-manager.users.adjivas.waybar.bar = {
    "battery#ps-controller-1" = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "DS4-Blue({capacity}%)";
      bat = "ps-controller-battery-10:18:49:a1:9b:26";
      interval = 10;
      tooltip-format = "{time} remaining";
    };

    "battery#ps-controller-2" = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "DS4-Orange({capacity}%)";
      bat = "ps-controller-battery-d0:bc:c1:a4:5f:98";
      interval = 10;
      tooltip-format = "{time} remaining";
    };
    "battery#ps-controller-3" = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "DS4-Purple({capacity}%)";
      bat = "ps-controller-battery-a4:53:85:94:03:f3";
      interval = 10;
      tooltip-format = "{time} remaining";
    };
  };
  home-manager.users.adjivas.programs.waybar.style = lib.mkAfter ''
    #battery.ps-controller-1 {
      background-color: blue;
      color: white;
    }

    #battery.ps-controller-2 {
      background-color: orange;
      color: black;
    }

    #battery.ps-controller-3 {
      background-color: purple;
      color: white;
    }
  '';

  # sudo udevadm control --reload
  # sudo udevadm trigger --subsystem-match=input
  services.udev.extraRules = lib.mkAfter (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (color: config: ''
        # USB Gamepad Keyboard
        SUBSYSTEM=="input", KERNEL=="event*", \
          ATTRS{name}=="Sony Interactive Entertainment Wireless Controller", ATTRS{uniq}=="${config.mac}", \
          ENV{ID_INPUT_JOYSTICK}=="1", \
          SYMLINK+="dualshock-joystick-${color}", \
          TAG+="systemd", ENV{SYSTEMD_WANTS}+="evsieve-ds4-dualshock-${color}", \
          ENV{SYSTEMD_WANTS}+="evsieve-ds4-dualshock-mouse-${color}"

        # USB Gamepad Mouse
        SUBSYSTEM=="input", KERNEL=="event*", \
          ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ATTRS{uniq}=="${config.mac}", \
          ENV{ID_INPUT_TOUCHPAD}=="1", \
          SYMLINK+="dualshock-touchpad-${color}"

        # Bluetooh Gamepad Keyboard
        SUBSYSTEM=="input", KERNEL=="event*", \
          ATTRS{name}=="Wireless Controller", ATTRS{uniq}=="${config.mac}", \
          ENV{ID_INPUT_JOYSTICK}=="1", \
          SYMLINK+="dualshock-joystick-${color}", \
          TAG+="systemd", ENV{SYSTEMD_WANTS}+="evsieve-ds4-dualshock-${color}", \
          ENV{SYSTEMD_WANTS}+="evsieve-ds4-dualshock-mouse-${color}"

        # Bluetooh Gamepad Mouse
        SUBSYSTEM=="input", KERNEL=="event*", \
          ATTRS{name}=="Wireless Controller Touchpad", ATTRS{uniq}=="${config.mac}", \
          ENV{ID_INPUT_TOUCHPAD}=="1", \
          SYMLINK+="dualshock-touchpad-${color}"
      '') ds4
    )
  );

  systemd.services = lib.mkMerge (
    lib.mapAttrsToList (color: config: {
      "evsieve-ds4-dualshock-${color}" = let
        evsieveScript = pkgs.writeShellScript "evsieve-ds4-dualshock-${color}" ''
          set -eu

          event_name=$(${pkgs.coreutils}/bin/basename $(${pkgs.coreutils}/bin/readlink -f /dev/dualshock-joystick-${color}))
          input_dev=$(${pkgs.coreutils}/bin/basename $(${pkgs.coreutils}/bin/readlink -f /sys/class/input/''${event_name}/..))

          ${pkgs.coreutils}/bin/echo ${toString config.color.blue} | ${pkgs.coreutils}/bin/tee /sys/class/leds/''${input_dev}:blue/brightness
          ${pkgs.coreutils}/bin/echo ${toString config.color.red} | ${pkgs.coreutils}/bin/tee /sys/class/leds/''${input_dev}:red/brightness
          ${pkgs.coreutils}/bin/echo ${toString config.color.green} | ${pkgs.coreutils}/bin/tee /sys/class/leds/''${input_dev}:green/brightness
        '';
      in {
        description = "Evsieve DS4 Virtual (${color})";
        after = [ "multi-user.target" ];

        unitConfig.ConditionPathExists = "/dev/dualshock-joystick-${color}";

        serviceConfig = {
          Type = "simple";
          ExecStart = evsieveScript;
          Restart = "always";
          RestartSec = 0.5;
        };
      };
      "evsieve-ds4-dualshock-mouse-${color}" = {
        description = "Evsieve DS4 Virtual (${color})";
        after = [ "multi-user.target" ];

        unitConfig.ConditionPathExists = "/dev/dualshock-joystick-${color}";

        serviceConfig = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.evsieve}/bin/evsieve \
              --input "/dev/dualshock-touchpad-${color}" persist=reopen grab \
              --output name="Dualshock (evsieve) Mouse ${color}" create-link="/dev/input/by-id/dualshock-evsieve-mouse-${color}"
          '';
          Restart = "always";
          RestartSec = 0.5;
        };
      };

    }) ds4
  );
}
