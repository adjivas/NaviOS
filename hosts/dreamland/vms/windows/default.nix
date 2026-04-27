{ pkgs, inputs, lib, config, ... }: {
  options = {
    windows.enable = lib.mkEnableOption "enable windows";
    windows.iso = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the Windows ISO file";
    };

    windows.unattend = lib.mkOption {
      type = lib.types.path;
      default = ./autounattend.xml;
      readOnly = true;
      description = "autounattend.xml file";
    };

    windows.unattendIso = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "unattend.iso result";
    };

    windows.virtioIso = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "virtio-win.iso result";
    };

    windows.OVMF = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "OVMF";
    };

    windows.volumes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "List of libvirt volumes definitions for Nobara.";
    };
  };
  config = lib.mkIf config.windows.enable (lib.mkMerge [
    {
      system.activationScripts.copyNvramWindows.text = ''
        dst="/var/lib/libvirt/qemu/nvram/windows_VARS.fd"
        [ -e "$dst" ] || {
          mkdir -p "$(dirname "$dst")"
          cp ${(pkgs.OVMF.override {
            secureBoot = true;
            msVarsTemplate = true;
          }).fd}/FV/OVMF_VARS.ms.fd "$dst"
          chown qemu-libvirtd:kvm "$dst"
          chmod 660 "$dst"
        }
      '';

      windows.virtioIso = pkgs.runCommand "virtio-win.iso" {} ''
        ${pkgs.cdrtools}/bin/mkisofs -l -V VIRTIO-WIN -o $out ${pkgs.virtio-win}
      '';

      windows.unattendIso = pkgs.runCommand "unattend-iso" { } ''
        mkdir -p "$out/iso"
        cp ${config.windows.unattend} autounattend.xml
        ${pkgs.cdrkit}/bin/genisoimage -Jr -o $out/iso/unattendName.iso autounattend.xml
      '';

      windows.OVMF = "${(pkgs.OVMF.override {
        secureBoot = true;
        msVarsTemplate = true;
      }).fd}";

      virtualisation.machines = lib.mkAfter [{
        domains = [{
          definition = let base = inputs.nixvirt.lib.domain.templates.windows ({
            name = "windows";
            uuid = "def734bb-e2ca-44ee-80f5-0ea0f2523aaa";
            memory = { count = 8; unit = "GiB"; };
            # storage_vol = { pool = "default"; volume = "windows.qcow2"; };
            install_vol = "${config.windows.iso}";
            install_virtio = true;
            nvram_path = "/var/lib/libvirt/qemu/nvram/windows_VARS.fd";
            no_graphics = false;

            networks = [
              (inputs.nixvirt.lib.mkBridgeNetwork {
                bridge = "br-inf";
                mac = "ba:e0:37:d0:62:42";
              })
            ];

            bridge_name = "br0";

            virtio_net = true;
            virtio_drive = true;
          } // lib.optionalAttrs (config.windows.iso != null) {
            install_vol = config.windows.iso;
          }); in inputs.nixvirt.lib.domain.writeXML (base // {
            features = {
              acpi = { };
              hyperv.vendor_id = { state = true; value = "randomid"; };
              kvm.hidden.state = true;
            };
            qemu-commandline = {
              arg = [
                # Native Qemu Audio support
                {value = "-device";}
                {value = "{\"driver\":\"ich9-intel-hda\"}";}
                {value = "-device";}
                {value = "{\"driver\":\"hda-micro\",\"audiodev\":\"hda\"}";}
                {value = "-audiodev";}
                {value = "{\"driver\":\"pa\",\"id\":\"hda\",\"server\":\"unix:/run/user/1000/pulse/native\"}";}
                # Scream
                # {value = "-device";}
                # {value = "{\"driver\":\"ivshmem-plain\",\"id\":\"shmem1\",\"memdev\":\"ivshmem_scream\"}";}
                # {value = "-object";}
                # {value = "{\"qom-type\":\"memory-backend-file\",\"id\":\"ivshmem_scream\",\"mem-path\":\"/dev/shm/scream\",\"size\":2097152,\"share\":true}";}
                # Lookingglass LG
                {value = "-device";}
                {value = "{\"driver\":\"ivshmem-plain\",\"id\":\"shmem0\",\"memdev\":\"looking-glass\"}";}
                {value = "-object";}
                {value = "{\"qom-type\":\"memory-backend-file\",\"id\":\"looking-glass\",\"mem-path\":\"/dev/kvmfr0\",\"size\":67108864,\"share\":true}";}
              ];
            };
            vcpu = {
              placement = "static";
              count = 4;
            };
            cpu = {
              mode = "host-passthrough";
              check = "full";
              migratable = true;
              topology = {
                sockets = 1;
                dies = 1;
                cores = 2;
                threads = 2;
              };
              feature = {
                policy = "require";
                name = "topoext";
              };
            };
            iothreads = {
              count = 1;
            };
            cputune = {
              emulatorpin = {
                cpuset = "0,4";
              };
              iothreadpin = {
                iothread = 1;
                cpuset = "0,4";
              };
              vcpupin = [
                {
                  vcpu = 0;
                  cpuset = "0";
                }
                {
                  vcpu = 1;
                  cpuset = "1";
                }
                {
                  vcpu = 2;
                  cpuset = "2";
                }
                {
                  vcpu = 3;
                  cpuset = "3";
                }
              ];
            };
            devices = base.devices // {
              rng = { model = "virtio"; backend = { model = "random"; source = /dev/urandom; }; };
              video.model.type = "none";
              graphics = {
                type = "spice";
                listen = {type = "none";};
                image = {compression = false;};
                gl = {enable = false;};
              };
              input = [
                # ErgoDox EZ ErgoDox EZ
                {
                  type = "evdev";
                  source = {
                    dev = "/dev/input/by-id/usb-ErgoDox_EZ_ErgoDox_EZ_0-event-kbd";
                    grab = "all";
                    grabToggle = "ctrl-ctrl";
                    repeat = true;
                  };
                }
                # Apple, Inc. Magic Trackpad 2
                {
                  type = "evdev";
                  source = {
                    dev = "/dev/input/by-id/usb-Apple_Inc._Magic_Trackpad_2_CC2929200Z7J5R9AM-if01-event-mouse";
                  };
                }
              ];
              kvmfr = {
                device = "/dev/kvmfr0";
                # size = "33554432";
                size = 67108864;
              };
              interface = {
                type = "bridge";
                mac.address = "52:54:00:2e:54:54";
                source.bridge = "br0";
                model.type = "e1000e";
              };
              disk = lib.optionals (config.windows.iso != null) [
                {
                  type = "file";
                  device = "cdrom";
                  driver = {
                    name = "qemu";
                    type = "raw";
                  };
                  source.file = "${config.windows.iso}";
                  target = {
                    dev = "sda";
                    bus = "sata";
                  };
                  address = {
                    type = "drive";
                    controller = 1;
                    bus = 0;
                    target = 0;
                    unit = 0;
                  };
                }
              ] ++ [
                {
                  type = "file";
                  device = "cdrom";
                  driver = {
                    name = "qemu";
                    type = "raw";
                  };
                  source.file = "${config.windows.unattendIso}/iso/unattendName.iso";
                  target = {
                    dev = "sdb";
                    bus = "sata";
                  };
                  address = {
                    type = "drive";
                    controller = 1;
                    bus = 0;
                    target = 0;
                    unit = 1;
                  };
                }
                {
                  type = "file";
                  device = "cdrom";
                  driver = {
                    name = "qemu";
                    type = "raw";
                  };
                  source.file = "${config.windows.virtioIso}";
                  target = {
                    dev = "sde";
                    bus = "sata";
                  };
                  readonly = true;
                  address = {
                    type = "drive";
                    controller = 1;
                    bus = 0;
                    target = 0;
                    unit = 2;
                  };
                }
                #{
                #  type = "file";
                #  device = "disk";
                #  source.file = "/var/lib/libvirt/images/windows.raw";
                #  driver = {
                #    name = "qemu";
                #    type = "raw";
                #  };
                #  target = {
                #    dev = "sdc";
                #    bus = "sata";
                #  };
                #  serial = "WIN-181MI4660H05U6M9";
                #  address = {
                #    type = "drive";
                #    controller = 0;
                #    bus = 0;
                #    target = 0;
                #    unit = 4;
                #  };
                #}
                {
                  type = "block";
                  device = "disk";
                  source.dev = "/dev/disk/by-id/ata-OCZ-REVODRIVE3_OCZ-181MI4660H05U6M9";
                  driver = {
                    name = "qemu";
                    type = "raw";
                    cache = "none";
                    io = "native";
                    discard = "unmap";
                  };
                  target = {
                    dev = "sdd";
                    bus = "sata";
                  };
                  serial = "WIN-181MI4660H05U6M9";
                  address = {
                    type = "drive";
                    controller = 0;
                    bus = 0;
                    target = 0;
                    unit = 0;
                  };
                }
              ];
              watchdog = { model = "itco"; action = "reset"; };
              memballoon.model = "none";
              # console = {
              #   type = "pty";
              #   target = {
              #     type = "virtio";
              #     port = 0;
              #   };
              # };
              tpm = {
                model = "tpm-crb";
                backend = {
                  type = "emulator";
                  version = "2.0";
                };
              };
              hostdev = [
                {
                  mode = "subsystem";
                  type = "pci";
                  managed = true;
                  source = {
                    address = {
                      domain = 0;
                      bus = 3;
                      slot = 0;
                      function = 0;
                      multifunction = true;
                    };
                  };
                }
                # Apple Magic Trackpad 2
                # {
                #   mode = "subsystem";
                #   type = "usb";
                #   source = {
                #     vendor.id = 1452;
                #     product.id = 613;
                #   };
                # }
                # USB Optical Mouse
                {
                  mode = "subsystem";
                  type = "usb";
                  source = {
                    startupPolicy = "optional";
                    vendor.id = 12538;
                    product.id = 1024;
                  };
                }
                # Wacom Co., Ltd CTL-480
                {
                  mode = "subsystem";
                  type = "usb";
                  managed = true;
                  source = {
                    startupPolicy = "optional";
                    vendor.id = 1386;
                    product.id = 782;
                  };
                }
              ];
            };
            qemu-override = {
              device = {
                alias = "hostdev0";
                frontend = {
                  property = {
                    name = "x-vga";
                    type = "bool";
                    value = "true";
                  };
                };
              };
            };
            os = base.os // {
              boot = [{ dev = "hd"; } { dev = "cdrom"; }];
              loader = base.os.loader // {
                path = "${config.windows.OVMF}/FV/OVMF_CODE.ms.fd"; # UEFI firmware
                readonly = true;
                type = "pflash";
              };
              nvram = base.os.nvram // {
                template = "${config.windows.OVMF}/FV/OVMF_VARS.ms.fd";
                templateFormat = "raw";
                format = "raw";
                path = "/var/lib/libvirt/qemu/nvram/windows_VARS.fd";
              };
            };
          });
        }];

        windows.volumes = [
          #{
          #  definition = inputs.nixvirt.lib.volume.writeXML {
          #    name = "windows.raw";
          #    capacity = { count = 64; unit = "GiB"; };
          #    target.format = { type = "raw"; };
          #  };
          #}
        ];
      }];
    }
  ]);
}
