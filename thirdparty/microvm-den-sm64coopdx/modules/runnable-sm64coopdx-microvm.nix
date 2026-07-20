{
  inputs,
  den,
  ...
}: {
  imports = [
    ./configuration.nix
    ./home.nix
  ];

  den.aspects.alice.includes = [
    den.aspects.sm64ex
    den.aspects.cage
  ];

  den.batteries.sm64coopdx-runner = {host, ...}: {
    includes = [
      den.aspects.sm64coopdx-runner-base
    ];

    nixos = {
      imports = [
        inputs.microvm.nixosModules.microvm
      ];

      microvm = {
        graphics.enable = true;

        hypervisor = "qemu";
        vcpu = 2;
        mem = 8192;

        socket = "control.socket";
        writableStoreOverlay = "/nix/.rw-store";

        qemu.extraArgs = [
          "-device"
          "virtio-input-host-pci,id=${host.sm64coopdx.pad}-gamepad,evdev=/dev/input/${host.sm64coopdx.pad}-gamepad"

          "-device"
          "virtio-input-host-pci,id=${host.sm64coopdx.pad}-touchpad,evdev=/dev/input/${host.sm64coopdx.pad}-touchpad"
        ];
      };
    };
  };

  den.aspects.runnable-sm64coopdx-microvm = {
    nixos = {
      imports = [
        inputs.microvm.nixosModules.microvm
      ];
      microvm = {
        graphics.enable = true;
        # shares = [
        #   {
        #     source = "/nix/store";
        #     mountPoint = "/nix/.ro-store";
        #     tag = "ro-store";
        #     proto = "9p";
        #   }
        # ];

        hypervisor = "qemu";
        vcpu = 2;
        mem = 8192;

        socket = "control.socket";
        writableStoreOverlay = "/nix/.rw-store";
      };
    };
  };
}
