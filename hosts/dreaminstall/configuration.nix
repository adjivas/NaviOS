{ self, inputs, config, pkgs, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];

  nix.settings.download-buffer-size = "5096M";

  boot.postBootCommands = ''
    if [[ " $(</proc/cmdline) " =~ \ PW_IDENT=([^[:space:]]+) ]]; then
      ident="''${BASH_REMATCH[1]}"

      mkdir -p /etc/nixos/secret

      ${pkgs.coreutils}/bin/printf '%s' "$ident" | ${pkgs.coreutils}/bin/base64 -d > /etc/nixos/secret/ident.txt
      ${pkgs.coreutils}/bin/chmod 600 /etc/nixos/secret/ident.txt

      # Host Secret
      ${pkgs.age}/bin/age -d -i /etc/nixos/secret/ident.txt -o /tmp/disk.key ${inputs.secrets}/dreamdesk-password.age
      ${pkgs.age}/bin/age -d -i /etc/nixos/secret/ident.txt -o /tmp/git-secret-token.txt ${inputs.secrets}/git-secret-token.age
    fi
  '';

  # udevadm info --query=property --name=/dev/sdX
  services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="NAVY_INDUSTRY", SYMLINK+="disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4XDNF0M914953K"
    SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ENV{ID_SERIAL}=="NAVY_INDUSTRY", SYMLINK+="disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4XDNF0M914953K-part%n"
  '';
  # SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="QEMU_HARDDISK_NAVY_INDUSTRY", SYMLINK+="disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4XDNF0M914953K"
  # SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ENV{ID_SERIAL}=="QEMU_HARDDISK_NAVY_INDUSTRY", SYMLINK+="disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4XDNF0M914953K-part%n"

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  boot.tmp.useTmpfs = false;

  users.motd = "hey listen!";
  users.users.nixos.isNormalUser = true;
  users.groups.nixos = {};
  users.users.nixos.group = "nixos";
  users.users.nixos.extraGroups = [ "wheel" ];

  environment.interactiveShellInit = ''
    journalctl --follow -u auto-install.service
  '';

  systemd.services.auto-install = {
    description = "Fetch Git repo and secret submodule";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      Environment = [
        # "NIX_PATH=nixpkgs=flake:nixpkgs:/nix/var/nix/profiles/per-user/root/channels"
        "NIX_PATH=nixpkgs=flake:nixpkgs"
        "PATH=/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin"
      ];
      ExecStart = pkgs.writeShellScript "auto-install" ''
        set -euo pipefail

        # Clone Nix Code
        ${pkgs.git}/bin/git clone https://█████.███/█████/█████.███ /tmp/nixos
        cd /tmp/nixos

        # Clone Secret
        export GIT_SECRET_TOKEN="$(cat /███/█████.███)"
        git clone "https://█████:$GIT_SECRET_TOKEN@█████.███/█████/█████.git"
        cd secret
        ${pkgs.agebox}/bin/agebox decrypt --private-keys /etc/nixos/secret/ident.txt --all
        cd ..

        # Prepare Disk
        ${pkgs.disko}/bin/disko --mode destroy,format,mount --yes-wipe-all-disks --flake .#dreamadjivas
        mkdir -p /mnt/nix/persistent/{etc/nixos,var/{lib/{systemd/coredump,bluetooth,nixos},log}}
        mkdir -p /mnt/nix/persistent/home/adjivas
        mkdir -p /mnt/nix/persistent/home/adjivas/.config/passage
        cp -rf /tmp/nixos/secret/nix/persistent/secrets /mnt/nix/persistent
        cp -rf /tmp/nixos/secret/nix/persistent/home/adjivas/.secrets /mnt/nix/persistent/home/adjivas
        cp -rf /tmp/nixos/secret/nix/persistent/home/adjivas/.config/passage/store /mnt/nix/persistent/home/adjivas/.config/passage
        cp -rf /tmp/nixos /mnt/nix/persistent/etc

        # Prepare Agenix
        mkdir -p /nix/persistent/secrets
        mount --bind /mnt/nix/persistent/secrets /nix/persistent/secrets
        mount -o remount,ro,bind /nix/persistent/secrets

        # Install
        cd /mnt/nix/persistent/etc/nixos
        ${pkgs.nix}/bin/nix --extra-experimental-features flakes --extra-experimental-features nix-command flake update
        ${pkgs.nixos-install-tools}/bin/nixos-install --no-channel-copy --no-root-password --flake /mnt/nix/persistent/etc/nixos#dreamadjivas
        reboot
      '';
    };
  };

  environment.systemPackages = [
    pkgs.git
    pkgs.disko
    pkgs.age
    pkgs.agebox
    # debug
    pkgs.htop
    pkgs.ripgrep
  ];

  system.stateVersion = "25.05";
}
