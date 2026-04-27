{ lib, pkgs, ... }: {
  home-manager.users.adjivas.wayland.windowManager.sway.config.startup = lib.mkAfter [
    { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; always = true; }
    { command = "${pkgs.chatty}/bin/chatty --gapplication-service"; }
    { command = "${pkgs.calls}/bin/gnome-calls --gapplication-service"; }
    { command = "${pkgs.gnome-contacts}/bin/gnome-contacts --gapplication-service"; }
  ];

  home-manager.users.adjivas.waybar.modules-right = lib.mkBefore [
    "custom/modem-audio"
    "custom/modem"
  ];
  home-manager.users.adjivas.waybar.bar = {
    "custom/modem" = {
      interval = 10;
      exec = ''${pkgs.modemmanager}/bin/mmcli -J -m any | ${pkgs.jq}/bin/jq -e '(.modem.generic.state // "")' 2>/dev/null'';
      format = "MODEM-EG25({}) ";
      tooltip = false;
    };
    "custom/modem-audio" = {
      interval = 60;
      on-click = "${pkgs.systemd}/bin/systemctl --user restart eg25-toggle.service";
      exec = pkgs.writeShellScript "eg25-toggle.sh" ''
        set -euo pipefail

        is_mute="$(${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq -r '
          [ .[]
            | select(.type=="PipeWire:Interface:Node")
            | { name: .info.props["node.name"]
              , m: ( [ .info.params.Props[]? | select(type=="object" and has("mute")) | .mute ]
                     | last // false )
              }
          ] as $nodes
          | (($nodes[] | select(.name=="eg25-downlink-output") | .m) // false) as $down
          | (($nodes[] | select(.name=="eg25-uplink-output") | .m) // false) as $up
          | if ($down and $up) then "true" else "false" end
        ')"

        ${pkgs.coreutils}/bin/echo '{"text":"","alt":"'$is_mute'"}'
      '';
      return-type = "json";
      format = "EG25-Mic({icon}) ";
      format-icons = {
        "true" = "mute";
        "false" = "unmut";
      };
      tooltip = false;
    };
  };

  # dconf watch /
  home-manager.users.adjivas.dconf.settings = {
    "org/gnome/evolution" = {
      default-address-book = "system-address-book";
    };

    "org/freedesktop/folks" = {
      primary-store = "eds:system-address-book";
    };

    "org/gnome/Contacts" = {
      did-initial-setup = true;
    };
  };

  hardware.usb-modeswitch.enable = true;

  networking.networkmanager = {
    enable = true;
    # plugins = with pkgs; [
    #   networkmanager-l2tp
    #   networkmanager-openvpn
    # ];
  };

  # busctl call org.freedesktop.DBus / org.freedesktop.DBus StartServiceByName 'su' 'org.freedesktop.ModemManager1' 0
  # busctl status org.freedesktop.ModemManager1
  systemd.services.ModemManager = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.modemmanager}/bin/ModemManager --debug" ];
      ExecStartPost = [ "${pkgs.modemmanager}/bin/mmcli --set-logging=INFO" ];
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.udev.extraRules = lib.mkAfter (''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", \
      ATTR{idVendor}=="2c7c", ATTR{idProduct}=="0125", \
      TAG+="systemd", \
      ENV{SYSTEMD_WANTS}+="eg25-autoconnect.service" \
      ENV{SYSTEMD_WANTS}+="eg25-usb-voice"
  '');

  systemd.services.eg25-autoconnect = {
    description = "Auto-connect 4G with mmcli (wait for modem)";
    after = [ "ModemManager.service" ];
    wants = [ "ModemManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "eg25-autoconnect.sh" ''
        set -euo pipefail

        for _ in $(${pkgs.coreutils}/bin/seq 1 30); do
          if ${pkgs.modemmanager}/bin/mmcli -J -m any \
             | ${pkgs.jq}/bin/jq -e '( .modem.generic.manufacturer // "" ) == "QUALCOMM INCORPORATED"' >/dev/null; then
             break
          fi
          ${pkgs.coreutils}/bin/sleep 1
        done

        # Check with have any Qualcomm modem
        if ! ${pkgs.modemmanager}/bin/mmcli -J -m any \
           | ${pkgs.jq}/bin/jq -e '( .modem.generic.manufacturer // "" ) == "QUALCOMM INCORPORATED"' >/dev/null; then
           exit 0
        fi

        # Connect
        if ${pkgs.modemmanager}/bin/mmcli -J -m any \
           | ${pkgs.jq}/bin/jq -e '( .modem.generic.state // "") == "disabled"' >/dev/null; then
          ${pkgs.modemmanager}/bin/mmcli -m any --simple-connect="apn=ebouygtel.com,ip-type=ipv6"
        fi
      '';
    };
  };

  systemd.services.eg25-usb-voice = {
    description = "Set EG25-G voice codec to USB (QPCMV=1,2)";
    after = [ "ModemManager.service" ];
    wants = [ "ModemManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "eg25-usb-voice.sh" ''
        set -euo pipefail

        for _ in $(${pkgs.coreutils}/bin/seq 1 30); do
          if ${pkgs.modemmanager}/bin/mmcli -J -m any \
             | ${pkgs.jq}/bin/jq -e '( .modem.generic.manufacturer // "" ) == "QUALCOMM INCORPORATED"' >/dev/null; then
             break
          fi
          ${pkgs.coreutils}/bin/sleep 1
        done

        # Check with have any Qualcomm modem
        if ! ${pkgs.modemmanager}/bin/mmcli -J -m any \
           | ${pkgs.jq}/bin/jq -e '( .modem.generic.manufacturer // "" ) == "QUALCOMM INCORPORATED"' >/dev/null; then
           exit 0
        fi

        # Enable the UAC
        if ! ${pkgs.modemmanager}/bin/mmcli -m any --command='AT+QCFG="USBCFG"' \
           | ${pkgs.gnugrep}/bin/grep -Eq '\+QCFG:.*(,1){5,}'; then
           ${pkgs.modemmanager}/bin/mmcli -m any --command='AT+QCFG="USBCFG",0x2C7C,0x0125,1,1,1,1,1,1,1' || true
        fi

        # Enable the PCM
        if ! ${pkgs.modemmanager}/bin/mmcli -m any --command='AT+QPCMV?' \
           | ${pkgs.gnugrep}/bin/grep -q '+QPCMV: 1,2'; then
          ${pkgs.modemmanager}/bin/mmcli -m any --command='AT+QPCMV=1,2' || true
        fi
      '';
    };
  };

  # pw-cli ls Node | grep -i quectel
  # PipeWire
  # https://pipewire.pages.freedesktop.org/wireplumber/policies/linking.html
  # systemctl --user restart pipewire pipewire-pulse wireplumber
  services.pipewire.extraConfig.pipewire."90-eg25-bridge.conf" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "EG25 Downlink (modem to RODE)";

          "capture.props" = {
            "node.name" = "eg25-downlink-input";
            "node.target" = "alsa_input.usb-Quectel_EG25-G-05.mono-fallback";
            "audio.channels" = 1;
            "audio.position" = [ "MONO" ];
          };
          "playback.props" = {
            "node.name" = "eg25-downlink-output";
            "node.description" = "EG25 Downlink playback";
            "node.target" = "alsa_output.usb-R__DE_Microphones_R__DE_NT-USB_Mini_5898BE";
            "audio.channels" = 1;
            "audio.position" = [ "MONO" ];
          };
        };
      }
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "EG25 Uplink (RODE to modem)";

          "capture.props" = {
            "node.name" = "eg25-uplink-input";
            "node.description" = "EG25 Uplink capture";
            "node.target" = "alsa_input.usb-R__DE_Microphones_R__DE_NT-USB_Mini_5898BEA";
            "audio.channels" = 1;
            "audio.position" = [ "MONO" ];
          };
          "playback.props" = {
            "node.name" = "eg25-uplink-output";
            "node.description" = "EG25 Uplink playback";
            "node.target" = "alsa_output.usb-Quectel_EG25-G-05.mono-fallback";
            "audio.channels" = 1;
            "audio.position" = [ "MONO" ];
          };
        };
      }
    ];
  };

  systemd.user.services.eg25-toggle = {
    description = "Mute EG25 loopback outputs at login";
    after = [ "pipewire.service" "wireplumber.service" ];
    requires = [ "pipewire.service" "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "eg25-toggle.sh" ''
        id="$(${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq -r '
          .[] | select(.type=="PipeWire:Interface:Node")
              | select(.info.props["node.name"]=="eg25-downlink-output")
              | .id
        ')"
        [ -n "$id" ] && ${pkgs.wireplumber}/bin/wpctl set-mute "$id" toggle

        id="$(${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq -r '
          .[] | select(.type=="PipeWire:Interface:Node")
              | select(.info.props["node.name"]=="eg25-uplink-output")
              | .id
        ')"
        [ -n "$id" ] && ${pkgs.wireplumber}/bin/wpctl set-mute "$id" toggle
      '';
    };
    wantedBy = [ "default.target" ];
  };

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("wheel") &&
          (
            action.id == "org.freedesktop.ModemManager1.Location" ||
            action.id == "org.freedesktop.ModemManager1.Voice" ||
            action.id.startsWith("org.freedesktop.ModemManager1.")
          )
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # Enable gpsd
  services.gpsd.enable = true;
  services.gpsd.devices = [ "/dev/ttyUSB1" ];
  services.geoclue2.enable = true;
  users.users.geoclue.extraGroups = [ "networkmanager" ];

  # Gnome-Calls
  programs.calls.enable = true;

  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ]; # Chatty dependency

  services.dbus.packages = [ pkgs.evolution-data-server ]; # Gnome-contacts
  systemd.user.services.evolution-source-registry = {
    description = "Evolution Source Registry";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.evolution-data-server}/libexec/evolution-source-registry";
      Restart = "on-failure";
    };
  };
  systemd.user.services.evolution-addressbook-factory = {
    description = "Evolution Addressbook Factory";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.evolution-data-server}/libexec/evolution-addressbook-factory";
      Restart = "on-failure";
    };
  };
  systemd.user.services.evolution-calendar-factory = {
    description = "Evolution Calendar Factory";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.evolution-data-server}/libexec/evolution-calendar-factory";
      Restart = "on-failure";
    };
  };

  environment.sessionVariables = {
    # gsettings list-schemas
    # gsettings list-recursively
    GSETTINGS_SCHEMA_DIR = lib.concatStringsSep ":" (
      map (package: "${package}/share/gsettings-schemas/${package.pname}-${package.version}/glib-2.0/schemas")
          [
            pkgs.gsettings-desktop-schemas
            pkgs.chatty
            pkgs.gnome-contacts
            pkgs.evolution-data-server
            pkgs.gsettings-desktop-schemas
            pkgs.gnome-online-accounts
          ]
    );
  };

  environment.systemPackages = with pkgs; [
    alsa-ucm-conf
    alsa-utils
    atinout
    modemmanager
    polkit_gnome

    chatty
    mmsd-tng
    glib

    gsettings-desktop-schemas # Chatty schema ?
    gnome-contacts # gnome-calls
    gnome-maps
  ];
}
