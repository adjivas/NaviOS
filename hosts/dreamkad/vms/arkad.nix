{ pkgs, inputs, lib, config, ... }: {
  options = {
    arkad.enable = lib.mkEnableOption "enable arkad";
    
    arkad.domains = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "";
    };

    arkad.volumes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "";
    };

    arkad.cdrom = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "NixOS iso install";
    };
  };
  config = lib.mkIf config.arkad.enable {
    system.activationScripts.copyNvramDreaminstall.text = ''
      dst="/var/lib/libvirt/qemu/nvram/arkad-install.fd"
      [ -e "$dst" ] || {
        mkdir -p "$(dirname "$dst")"
        cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd "$dst"
      }
    '';

    arkad.domains = [ {
      definition = let base = inputs.nixvirt.lib.domain.templates.linux {
        name = "arkad (with PXE)";
        uuid = "e742c8e2-1235-4b1d-b2e6-cc3b7f2eabce";

        vcpu = {
          placement = "static";
          count = 2;
        };
        memory = {
          count = 4;
          unit = "GiB";
        };

        storage_vol = {
          pool = "default";
          volume = "arkad-overlay.qcow2";
        };
        # install_vol = "${inputs.self.packages.x86_64-linux.arkad}/iso/${inputs.self.packages.x86_64-linux.arkad.name}";

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
              driver = { name = "qemu"; type = "qcow2"; discard = "unmap"; };
              source = {
                pool = "default";
                volume = "arkad-overlay.qcow2";
              };
              target = { dev = "vda"; bus = "virtio"; };
              serial = "NAVY_INDUSTRY";
            }
            {
              type = "file";
              device = "cdrom";
              driver = {
                name = "qemu";
                type = "raw";
              };
              source.file = "${config.arkad.cdrom}";
              target = {
                dev = "sdc";
                bus = "sata";
              };
              readonly = true;
              address = {
                type = "drive";
                controller = 0;
                bus = 0;
                target = 0;
                unit = 2;
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
          boot = [ { dev = "hd"; } { dev = "cdrom"; } ];
          loader = {
            path = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"; # UEFI firmware
            readonly = true;
            type = "pflash";
          };
          nvram = {
            template = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
            templateFormat = "raw";
            format = "raw";
            path = "/var/lib/libvirt/qemu/nvram/arkad-install.fd";
          };

          smbios = {
            mode = "sysinfo";
          };
        };
      });
    } ];

    arkad.volumes = [ {
      name = "arkad-overlay.qcow2";
      definition = inputs.nixvirt.lib.volume.writeXML {
        name = "arkad-overlay.qcow2";
        capacity = { count = 100; unit = "GiB"; };
        # capacity = { count = 32; unit = "GiB"; };
        target.format = { type = "qcow2"; };
      };
    } ];
  };
}
