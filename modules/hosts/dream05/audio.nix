# NixOS module for audio support on Fairphone 5.
#
# This module enables playback and capture through the Qualcomm QCM6490 audio
# subsystem. It configures:
# - FastRPC access to the audio DSP firmware files.
# - PipeWire and WirePlumber with Qualcomm-specific settings.
# - Fairphone 5 ALSA UCM2 profiles.
{
  den.aspects.dream05-audio.nixos = {
    pkgs,
    lib,
    ...
  }: {
    # Attach the FastRPC server to the ADSP sensors protection domain and expose
    # its HexagonFS files. The explicit device path is required because the
    # conventional /usr/share/qcom path does not contain package files on NixOS.
    systemd.services.hexagonrpcd-adsp-sensorspd = {
      description = "Qualcomm ADSP FastRPC server (sensorspd)";
      wantedBy = ["multi-user.target"];
      after = ["local-fs.target"];

      serviceConfig = {
        ExecStart = "${pkgs.hexagonrpc}/bin/hexagonrpcd -f /dev/fastrpc-adsp -d adsp -s -R ${pkgs.firmware-fairphone-fp5}/usr/share/qcom/qcm6490/Fairphone/fp5";
        Restart = "on-failure";
        RestartSec = "3";
      };
    };

    # Open the modem's hostless RX/TX streams after UCM configures the
    # audio routes. The Voice Call profile starts and stops each instance;
    # %I expands to its ALSA stream argument, e.g. Rhw:F5,7 or Thw:F5,7.
    systemd.user.services."dummystreamhack@" = {
      description = "Qualcomm voice-call ALSA stream";

      serviceConfig = {
        ExecStart = "${pkgs.dummystreamhack}/bin/dummystreamhack %I";
        KillMode = "process";
      };
    };

    # Use PipeWire with the Qualcomm-specific WirePlumber configuration.
    services.pulseaudio.enable = lib.mkForce false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      wireplumber.configPackages = [pkgs.wireplumber-config-fairphone-fp5];
    };

    # Point both audio user services at the Fairphone 5 UCM2 profile tree.
    systemd.user.services.pipewire.environment = {
      ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-fairphone-fp5}/share/alsa/ucm2";
    };
    systemd.user.services.wireplumber.environment = {
      ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-fairphone-fp5}/share/alsa/ucm2";
    };
  };
}
