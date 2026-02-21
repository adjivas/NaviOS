{ modulesPath, pkgs, inputs, lib, config, ... }: {
  options = {
    dreamkad.enable = lib.mkEnableOption "enable dreamkad";
    
    dreamkad.domains = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "";
    };

    dreamkad.volumes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "";
    };
  };
  config = lib.mkIf config.dreamkad.enable (lib.mkMerge [
    {
      system.activationScripts.copyNvramDreamkad.text = ''
        dst="/var/lib/libvirt/qemu/nvram/dreamkad-kad_VARS.fd"
        [ -e "$dst" ] || {
          mkdir -p "$(dirname "$dst")"
          cp -f ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd "$dst"
        }
      '';

      system.activationScripts.homeDreamkad.text = ''
        dst="/var/lib/libvirt/images/dreamkad-home-btrfs.qcow2"
        [ -e "$dst" ] || {
          mkdir -p "$(dirname $dst)"
          ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$dst" 100G

          ${pkgs.kmod}/bin/modprobe nbd max_part=8
          ${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 "$dst"

          ${pkgs.btrfs-progs}/bin/mkfs.btrfs -L dreamkad-home /dev/nbd0

          ${pkgs.qemu}/bin/qemu-nbd --disconnect /dev/nbd0 || true

          ${pkgs.systemd}/bin/udevadm settle || true

          ${pkgs.util-linux}/bin/blockdev --rereadpt /dev/nbd0 || true

          ${pkgs.kmod}/bin/modprobe -r nbd || true
        }
      '';

      virtualisation.machines = lib.mkAfter [{
        domains = [{
          definition = let base = inputs.nixvirt.lib.domain.templates.linux {
            type = "qemu";
            name = "dreamkad (GPU passthrough required)";
            uuid = "e7c1c8e2-1234-4b1d-b2e6-cc3b7f2eabcd";

            vcpu = {
              placement = "static";
              count = 6;
            };
            memory = {
              count = 8;
              unit = "GiB";
            };

            # storage_vol = {
            #   pool = "default";
            #   volume = "dreamkad-overlay.qcow2";
            # };

            networks = [
              (inputs.nixvirt.lib.mkBridgeNetwork {
                bridge = "br-inf";
                mac = "ba:e0:37:d0:62:71";
              })
            ];

            bridge_name = "br0";

            virtio_video = false;
            virtio_drive = false;
          }; in inputs.nixvirt.lib.domain.writeXML (base // {
            devices = base.devices // {
              video.model.type = "none";

              rng = { model = "virtio"; backend = { model = "random"; source = /dev/urandom; }; };
              console = {
                type = "pty";
                target = {
                  type = "virtio";
                  port = 0;
                };
              };
              tpm = {
                model = "tpm-crb";
                backend = {
                  type = "emulator";
                  version = "2.0";
                };
              };
              disk = [
                {
                  device = "disk";
                  driver = { name = "qemu"; type = "qcow2"; discard = "unmap"; };
                  # source = { pool = "default"; volume = "dreamkad-overlay.qcow2"; };
                  source = { file = "/var/lib/libvirt/images/dreamkad-overlay.qcow2"; };
                  target = { dev = "vda"; bus = "virtio"; };
                }
                {
                  device = "disk";
                  driver = { name = "qemu"; type = "qcow2"; discard = "unmap"; };
                  # source = { pool = "default"; volume = "dreamkad-home.qcow2"; };
                  source = { file = "/var/lib/libvirt/images/dreamkad-home-btrfs.qcow2"; };
                  target = { dev = "vdb"; bus = "virtio"; };
                  boot = null;
                }
              ];
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
                    };
                  };
                }
                {
                  mode = "subsystem";
                  type = "pci";
                  managed = true;
                  source = {
                    address = {
                      domain = 0;
                      bus = 3;
                      slot = 0;
                      function = 1;
                    };
                  };
                }
                # Bregoli Swiss
                {
                  mode = "subsystem";
                  type = "usb";
                  source = {
                    startupPolicy = "optional";
                    vendor.id = 65261;
                    product.id = 0;
                  };
                }
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
                  source = {
                    startupPolicy = "optional";
                    vendor.id = 1386;
                    product.id = 782;
                  };
                }
              ];
            };
            os = base.os // {
              boot = [ { dev = "hd"; } ];
              loader = {
                path = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"; # UEFI firmware
                readonly = true;
                type = "pflash";
              };
              nvram = {
                template = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
                templateFormat = "raw";
                format = "raw";
                path = "/var/lib/libvirt/qemu/nvram/dreamkad-kad_VARS.fd";
              };
            };
          });
        }];

        volumes = [{
          name = "dreamkad-overlay.qcow2";
          definition = inputs.nixvirt.lib.volume.writeXML {
            name = "dreamkad-overlay.qcow2";
            capacity = { count = 100; unit = "GiB"; };
            target.format = { type = "qcow2"; };
            backingStore = {
              path = "${inputs.self.packages.x86_64-linux.dreamkad}/nixos.qcow2";
              format = { type = "qcow2"; };
            };
          };
        }];
      }];
    }
  ]);
}
