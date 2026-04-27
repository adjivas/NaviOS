{ pkgs, config, ... }: {
  specialisation.vfio-passthrough.configuration = {
    virtualisation = {
      vfio = {
        enable = true;
        IOMMUType = "intel"; # intel_iommu=on iommu=pt
        ignoreMSRs = true; # kvm ignore_msrs=1 report_ignored_msrs=0
        devices = [ # vfio-pci ids=1002:744c,1002:ab30
          # GPU RX 7900 GRE
          "1002:744c"
          # Audio HDMI Navi 31
          "1002:ab30"
        ];
      };
      kvmfr = {
        enable = true;
        devices = [{
          # size = 67108864;
          size = 64;

          permissions = {
            user = config.virtualisation.user;
            group = "qemu-libvirtd";
            mode = "0660";
          };
        }];
      };
      libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";

        qemu = {
          package = pkgs.qemu_full;
          runAsRoot = true;
          swtpm.enable = true;
        };

        deviceACL = [
          "/dev/vfio/vfio"
          "/dev/kvm"
          "/dev/kvmfr0"
          "/dev/null"
          "/dev/full"
          "/dev/zero"
          "/dev/random"
          "/dev/urandom"
          "/dev/pts"
          "/dev/ptmx"
          "/dev/input/by-id/usb-30fa_USB_Optical_Mouse-event-mouse"
          "/dev/input/by-id/usb-Apple_Inc._Magic_Trackpad_2_CC2929200Z7J5R9AM-if01-event-mouse"
          "/dev/input/by-id/usb-System76_Launch_Configurable_Keyboard__launch_1_-if02-event-kbd"
          "/dev/input/by-id/usb-Bregoli_Swiss-event-kbd"
          "/dev/shm/looking-glass"
        ];
      };
    };
  };
}
