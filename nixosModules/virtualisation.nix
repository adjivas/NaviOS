{ inputs, lib, pkgs, config, ... }: {
  options = {
    virtualisation.enable = lib.mkEnableOption "enable virtualisation";
    virtualisation.machines = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
    virtualisation.networks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
    virtualisation.user = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    {
      users.groups.qemu-libvirtd = {};
      users.users.qemu-libvirtd.group = "qemu-libvirtd";
    }
    (lib.mkIf config.virtualisation.enable (
      {
        programs.virt-manager.enable = true;
        users.extraGroups.libvirtd.members = [ config.virtualisation.user ];
        users.extraGroups.kvm.members = [ config.virtualisation.user ];

        environment.etc."looking-glass-client.ini".text = ''
          [win]
          fullScreen=no
          borderless=yes
          title=Looking Glass

          [app]
          shmFile=/dev/kvmfr0

          [spice]
          enable=no

          [input]
          escapeKey=KEY_SCROLLLOCK
        '';

        environment.systemPackages = with pkgs; [
          spice
          spice-gtk
          spice-protocol
          spice-vdagent
          spice-autorandr
          virglrenderer
          win-spice
          pciutils
          wlr-randr
          looking-glass-client
          mesa-demos
          (writeShellScriptBin "list-iommu-groups" ''
            shopt -s nullglob
            for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
              echo "IOMMU Group ''${g##*/}:"
              for d in $g/devices/*; do
                echo -e "\t$(lspci -nns ''${d##*/})"
              done
            done
          '')
          (writeShellScriptBin "gpu-detach" ''
            # Unbind from host
            echo 0000:03:00.0 | tee /sys/bus/pci/drivers/amdgpu/ubind
            echo 0000:03:00.1 | tee /sys/bus/pci/drivers/snd_hda_intel/ubind
          
            # Reset
            echo > /sys/bus/pci/devices/0000:03:00.0/driver_override
            echo > /sys/bus/pci/devices/0000:03:00.1/driver_override
          
            # Bind to vfio-pci
            echo 0000:03:00.0 > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
            echo 0000:03:00.1 > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true

            # LACT
            systemctl restart lactd.service
          '')
          (writeShellScriptBin "gpu-reattach" ''
            ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_03_00_0
            ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_03_00_1

            # Unbind from VFIO
            echo 0000:03:00.0 > /sys/bus/pci/drivers/vfio-pci/unbind
            echo 0000:03:00.1 > /sys/bus/pci/drivers/vfio-pci/unbind

            # Reset
            echo > /sys/bus/pci/devices/0000:03:00.0/driver_override
            echo > /sys/bus/pci/devices/0000:03:00.1/driver_override

            # Re-Bind to host driver
            echo 0000:03:00.0 | tee /sys/bus/pci/drivers/amdgpu/bind
            echo 0000:03:00.1 | tee /sys/bus/pci/drivers/snd_hda_intel/bind

            # LACT
            systemctl restart lactd.service
          '')
          python3Packages.virt-firmware
          python3Packages.ovmfvartool
        ];
        systemd.tmpfiles.rules = [
          "f /dev/shm/looking-glass 0660 ${config.virtualisation.user} qemu-libvirtd -"
          "d /var/lib/libvirt/images 0755 root qemu-libvirtd -"
          "z /dev/kvmfr0 0660 ${config.virtualisation.user} qemu-libvirtd -"
          "z /dev/ptmx 0660 ${config.virtualisation.user} qemu-libvirtd -"
        ];

        # boot.initrd.services.udev.rules = ''
        #   SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", OWNER="adjivas", GROUP="qemu-libvirtd", MODE="0660"
        # '';
        # services.udev.extraRules = ''
        #   SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", OWNER="adjivas", GROUP="qemu-libvirtd", MODE="0660"
        # '';

        # virtualisation = {
        #   spiceUSBRedirection.enable = true;
        # };
        # services.spice-vdagentd.enable = true;

        # NixVirt
        users.groups.qemu-libvirtd = {};
        users.users.qemu-libvirtd.group = "qemu-libvirtd";

        virtualisation.libvirt = {
          enable = true;
          swtpm.enable = true;
        };

        # sudo virsh dumpxml nobara
        virtualisation.libvirt.connections."qemu:///system".domains = lib.flatten (lib.catAttrs "domains" config.virtualisation.machines);
        virtualisation.libvirt.connections."qemu:///system".pools = [
          {
            active = true;
            # sudo virsh vol-list default
            # sudo virsh pool-dumpxml default
            definition = inputs.nixvirt.lib.pool.writeXML {
              name = "default";
              uuid = "074f8b64-e825-432e-8da6-2843ff9d96bb";
              type = "dir";
              target.path = "/var/lib/libvirt/images";
            };
            volumes = lib.flatten (lib.catAttrs "volumes" config.virtualisation.machines);
          }
        ];
        virtualisation.libvirt.connections."qemu:///system".networks = config.virtualisation.networks;
      }
    ))
  ];
}
