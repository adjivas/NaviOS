{ lib, ... }: {
  specialisation.multiseat.configuration = {
    services.xserver.displayManager.lightdm = {
      extraConfig = lib.mkForce ''
        [Seat:*]
        greeter-session=lightdm-gtk-greeter
        user-session=sway

        [Seat:seat0]
        autologin-user=adjivas
        autologin-session=sway

        [Seat:seat1]
        autologin-user=kad
        autologin-session=sway
      '';
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="drm", ENV{ID_AUTOSEAT}="0", ENV{ID_SEAT}=""

      # seat0: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor Integrated Graphics Controller
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:00:02.0", ENV{ID_SEAT}="seat0"
      SUBSYSTEM=="drm", KERNEL=="card*-*", KERNELS=="0000:00:02.0", ENV{ID_SEAT}="seat0"
      SUBSYSTEM=="drm", KERNEL=="renderD*", KERNELS=="0000:00:02.0", ENV{ID_SEAT}="seat0"

      SUBSYSTEM=="tty", KERNEL=="tty1", ENV{ID_SEAT}="seat0"
      # seat0: Bus 001 Device 018: ID feed:1307 ErgoDox EZ ErgoDox EZ
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="feed", ENV{ID_MODEL_ID}=="1307", ENV{ID_SEAT}="seat0"
      # seat0: Apple, Inc. Magic Trackpad 2
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="05ac", ENV{ID_MODEL_ID}=="0265", ENV{ID_SEAT}="seat0"

      # seat1: USB Optical Mouse
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="30fa", ENV{ID_MODEL_ID}=="0400", ENV{ID_SEAT}="seat1"
      # seat1: Wacom Co., Ltd CTL-480 [Intuos Pen (S)]
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="056a", ENV{ID_MODEL_ID}=="030e", ENV{ID_SEAT}="seat1"
      # seat1: RDMCTMZT Panda 20
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="36b0", ENV{ID_MODEL_ID}=="3006", ENV{ID_SEAT}="seat1"
      # seat1: Swiss (Cheeseboard)
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="4c43", ENV{ID_MODEL_ID}=="0420", ENV{ID_SEAT}="seat1"
      # ACTION=="add", SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="4c43", ENV{ID_MODEL_ID}=="0420", ENV{ID_SEAT}="seat1"
      # ACTION=="change", SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="4c43", ENV{ID_MODEL_ID}=="0420", ENV{ID_SEAT}="seat1"

      # seat1: [AMD/ATI] Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M]
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:03:00.0", ENV{ID_SEAT}="seat1"
      SUBSYSTEM=="drm", KERNEL=="card*-*", KERNELS=="0000:03:00.0", ENV{ID_SEAT}="seat1"
      SUBSYSTEM=="drm", KERNEL=="renderD*", KERNELS=="0000:03:00.0", ENV{ID_SEAT}="seat1"
      SUBSYSTEM=="sound", KERNEL=="card*", KERNELS=="0000:03:00.1", ENV{ID_SEAT}="seat1"

      # seat1: HDA/Intel
      SUBSYSTEM=="sound", KERNEL=="card0", ENV{ID_SEAT}="seat1"

      SUBSYSTEM=="tty", KERNEL=="tty2", ENV{ID_SEAT}="seat1"

      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:03:00.0", SYMLINK+="dri/amd"
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:00:02.0", SYMLINK+="dri/intel"
    '';
  };
}
