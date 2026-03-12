{ lib, config, ... }: {
  options = {
    pipewire.enable = lib.mkEnableOption "enable pipewire";
    pipewire.sink = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Default audio sink";
    };
  };
  config = lib.mkIf config.pipewire.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.pipewire.wireplumber.extraConfig."10-no-bluetooth" = {
      "wireplumber.profiles" = {
        "main" = {
          "monitor.bluez" = "disabled";
          "monitor.bluez-midi" = "disabled";
        };
      };
    };

    services.pipewire.wireplumber.extraConfig."99-default-sink" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = config.pipewire.sink; }
          ];
          actions = {
            update-props = {
              "priority.session" = 2000;
              "priority.driver" = 2000;
              "node.default" = true;
            };
          };
        }
      ];
    };

    # systemctl --user restart wireplumber.service
    services.pipewire.wireplumber.extraConfig."99-custom" = {
      "wireplumber.settings"."default.configured.audio.sink" = config.pipewire.sink;
      "wireplumber.settings"."device.routes.default-sink-volume" = 1.0;
      "monitor.alsa.rules" = [
        # pw-dump | jq '.[] | select(.type=="PipeWire:Interface:Node") | select(.info.props."node.name" == "alsa_output.pci-0000_00_1b.0.iec958-stereo")'
        {
          matches = [
            { "node.name" = "alsa_output.pci-0000_00_1b.0.iec958-stereo"; }
          ];
          actions = {
            update-props = {
              "node.nick" = "Navy Industry Speaker";
              "node.description" = "Digital Stereo (IEC958) Navy Industry";
            };
          };
        }
        # pw-dump | jq '.[] | select(.type=="PipeWire:Interface:Node") | select(.info.props."node.name" == "alsa_output.usb-SYBA_TECH_SA9227_USB_Audio-01.analog-stereo")'
        {
          matches = [
            { "node.name" = "alsa_output.usb-SYBA_TECH_SA9227_USB_Audio-01.analog-stereo"; }
          ];
          actions = {
            update-props = {
              "node.nick" = "Navy Industry Headphone";
              "node.description" = "Analog Stereo (SA9227 384KHz) Navy Industry";
            };
          };
        }
        # pw-dump | jq '.[] | select(.type=="PipeWire:Interface:Node") | select(.info.props."node.name" == "alsa_output.pci-0000_00_03.0.hdmi-stereo")'
        {
          matches = [
            { "node.name" = "alsa_output.pci-0000_00_03.0.hdmi-stereo"; } # HDMI
          ];
          actions = {
            update-props = {
              "node.disabled" = true;
            };
          };
        }
      ];
    };
  };
}
