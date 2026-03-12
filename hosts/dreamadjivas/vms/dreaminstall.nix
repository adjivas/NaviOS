{ pkgs, inputs, lib, config, ... }: {
  options = {
    dreaminstall.enable = lib.mkEnableOption "enable dreaminstall";
    
    dreaminstall.domains = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "";
    };

    dreaminstall.volumes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "";
    };
  };
  config = lib.mkIf config.dreaminstall.enable (lib.mkMerge [
    {
      system.activationScripts.copyNvramDreaminstall.text = ''
        dst="/var/lib/libvirt/qemu/nvram/dreaminstall-install.fd"
        [ -e "$dst" ] || {
          mkdir -p "$(dirname "$dst")"
          cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd "$dst"
        }
      '';

      virtualisation.machines = lib.mkAfter [{
        domains = [ {
          definition = let base = inputs.nixvirt.lib.domain.templates.linux {
            name = "dreaminstall (Pixie PXE server required)";
            uuid = "e7c1c8e2-1235-4b1d-b2e6-cc3b7f2eabce";

            vcpu = {
              placement = "static";
              count = 2;
            };
            memory = {
              count = 20;
              unit = "GiB";
            };

            # storage_vol = {
            #   pool = "default";
            #   volume = "dreaminstall-overlay.qcow2";
            #   serial = "";
            # };
            # install_vol = "${inputs.self.packages.x86_64-linux.dreaminstall}/iso/${inputs.self.packages.x86_64-linux.dreaminstall.name}";

            networks = [
              (inputs.nixvirt.lib.mkBridgeNetwork {
                bridge = "br-inf";
                mac = "ba:e0:37:d0:62:71";
              })
            ];

            virtio_video = true;
            virtio_drive = true;
          }; in inputs.nixvirt.lib.domain.writeXML (base // {
            devices = base.devices // {
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
                  type = "volume";
                  device = "disk";
                  driver = {
                    name = "qemu";
                    type = "qcow2";
                    cache = "none";
                    discard = "unmap";
                    detect_zeroes = "unmap";
                  };
                  source = {
                    pool = "default";
                    volume = "dreaminstall-overlay.qcow2";
                  };
                  target = {
                    dev = "vda";
                    bus = "virtio";
                  #   dev = "sda";
                  #   bus = "sata";
                  };
                  serial = "NAVY_INDUSTRY";
                  # address = {
                  #   type = "drive";
                  #   controller = 0;
                  #   bus = 0;
                  #   target = 0;
                  #   unit = 0;
                  # };
                }
                # {
                #   type = "file";
                #   device = "cdrom";
                #   driver = {
                #     name = "qemu";
                #     type = "raw";
                #   };
                #   source.file = "${inputs.self.packages.x86_64-linux.dreaminstall}/iso/${inputs.self.packages.x86_64-linux.dreaminstall.name}";
                #   target = {
                #     dev = "sdc";
                #     bus = "sata";
                #   };
                #   readonly = true;
                #   address = {
                #     type = "drive";
                #     controller = 0;
                #     bus = 0;
                #     target = 0;
                #     unit = 2;
                #   };
                # }
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
              ];
            };
            sysinfo = {
              type = "smbios";
              system = {
                entry = [
                  {
                    name = "manufacturer"; value = "Navy Industry";
                  }
                  {
                    name = "product"; value = "All Series";
                  }
                  {
                    name = "serial"; value = "System Serial Number";
                  }
                ];
              };
            };
            os = base.os // {
              boot = [ { dev = "hd"; } { dev = "network"; } ];
              loader = {
                path = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"; # UEFI firmware
                readonly = true;
                type = "pflash";
              };
              nvram = {
                template = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
                templateFormat = "raw";
                format = "raw";
                path = "/var/lib/libvirt/qemu/nvram/dreaminstall-install.fd";
              };

              smbios = {
                mode = "sysinfo";
              };
            };
          });
        } ];

        volumes = [{
          name = "dreaminstall-overlay.qcow2";
          definition = inputs.nixvirt.lib.volume.writeXML {
            name = "dreaminstall-overlay.qcow2";
            capacity = { count = 100; unit = "GiB"; };
            # capacity = { count = 32; unit = "GiB"; };
            target.format = { type = "qcow2"; };
          };
        }];
      }];
    }
  ]);
}
