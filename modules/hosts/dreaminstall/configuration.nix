{
  den,
  nixConfig,
  ...
}: {
  flake.nixosModules.dreaminstall = {
    self,
    pkgs,
    secretsSystem,
    secretsUser,
    ...
  }: {
    # imports = builtins.attrValues self.nixosModules;

    imports = [
      den.aspects.yubico.nixos
      den.aspects.nix-cache-client.nixos
    ];

    networking.hosts = {
      "192.168.1.10" = ["dream00"];
      "2a04:cec0:1902:2824::10" = ["dream00"];
      "192.168.1.11" = ["dream00"];
      "2a04:cec0:1902:2824::11" = ["dream00"];
      "192.168.1.76" = ["dream76"];
      "2a04:cec0:1902:2824::76" = ["dream76"];
      "192.168.1.77" = ["dream76"];
      "2a04:cec0:1902:2824::77" = ["dream76"];
    };

    nix.cache.client = {
      extraSubstituters =
        [
          "http://dream00:5000"
          "http://dream76:5000"
        ]
        ++ nixConfig.extra-substituters;
      extraTrustedPublicKeys =
        [
          "binarycache.example.com:9TSbWtdq8CqiAC28r3g2OF27vJP2I28edNSyRwMVgts="
        ]
        ++ nixConfig.extra-trusted-public-keys;
    };

    nix.settings.download-buffer-size = "5096M";

    # nix config show --extra-experimental-features nix-command | grep trusted-public-keys
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
    };

    environment.etc."navios".source = self;

    environment.etc."secrets-system".source = secretsSystem;
    environment.etc."secrets-user".source = secretsUser;

    environment.etc."ssh/known_hosts".text = ''
      [dream00]:60022 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9ppVfpZznDAjOi0hTrChskdVslnNYJL4e+Msv+1F/b
      [dream76]:60022 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9ppVfpZznDAjOi0hTrChskdVslnNYJL4e+Msv+1F/b
    '';

    # udevadm info --query=property --name=/dev/sdX | grep ID_SERIAL
    services.udev.extraRules = ''
      SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="MOUSY_INDUSTRY", SYMLINK+="disk/by-id/ata-NavyIndustry_SSD"
      SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ENV{ID_SERIAL}=="MOUSY_INDUSTRY", SYMLINK+="disk/by-id/ata-NavyIndustry_SSD-part%n"

      SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="Samsung_SSD_980_PRO_1TB_S5P2NL0TA01768Z_1", SYMLINK+="disk/by-id/ata-NavyIndustry_SSD"
      SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ENV{ID_SERIAL}=="Samsung_SSD_980_PRO_1TB_S5P2NL0TA01768Z_1", SYMLINK+="disk/by-id/ata-NavyIndustry_SSD-part%n"
    '';

    services.openssh = {
      enable = true;
      openFirewall = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    boot.tmp.useTmpfs = false;

    environment.etc."install.sh".text = ''
      set -euo pipefail

      if [[ "$(cat /sys/class/dmi/id/board_name)" == "Oryx Pro" ]]; then
        machine="dream76"
        remote="dream00"
      else
        machine="dream00"
        remote="dream76"
      fi

      echo "Are you ready to unlock the secret? (Press Enter)"
      read
      sudo ${pkgs.age}/bin/age --decrypt -i /etc/ident-red.txt /etc/secrets-system/key-0.ident.age | sudo tee /etc/ident-blue.txt > /dev/null
      echo "Disko Step"
      sudo ${pkgs.age}/bin/age --decrypt -i /etc/ident-blue.txt /etc/secrets-system/disko-dreamland-password.txt.age | sudo tee /tmp/disk.key > /dev/null
      sudo ${pkgs.age}/bin/age --decrypt -i /etc/ident-blue.txt /etc/secrets-system/fido2-salt.bin.age | sudo tee /tmp/fido2-salt.bin > /dev/null
      sudo chmod 0400 /tmp/disk.key
      sudo chmod 0400 /tmp/fido2-salt.bin
      sudo ${pkgs.disko}/bin/disko --mode destroy,format,mount --yes-wipe-all-disks --flake /etc/navios/.#dream00

      echo "Are you ready to register your keys? (Press Enter)"
      read
      for yubico in $(${pkgs.libfido2}/bin/fido2-token -L | ${pkgs.coreutils}/bin/cut -d: -f1); do
        sudo ${pkgs.systemd}/bin/systemd-cryptenroll \
          --fido2-with-client-pin=no \
          --fido2-device=$yubico \
          --fido2-salt-file=/tmp/fido2-salt.bin \
          --unlock-key-file=/tmp/disk.key \
          /dev/disk/by-partlabel/disk-dream00-luks
      done

      echo "Prepare Persistent Layout Step"
      sudo mkdir -v -p /mnt/nix/persistent/{etc/nixos,var/{lib/{systemd/coredump,bluetooth,nixos},log}}
      sudo mkdir -v -p /mnt/nix/persistent/secrets /mnt/nix/persistent/home/adjivas/.secrets
      sudo mkdir -v -p /mnt/nix/persistent/secrets /mnt/nix/persistent/home/kad/.secrets
      sudo mkdir -v -p /mnt/nix/persistent/home/adjivas/{Documents,Etudes,Pictures,PoCs}
      sudo mkdir -v -p /mnt/nix/persistent/snapshots/adjivas/{Documents,Etudes,Pictures,PoCs}
      sudo mkdir -p /mnt/nix/persistent/backups/$machine/adjivas

      echo "Secret Step"
      sudo cp -v /etc/ident-blue.txt /mnt/nix/persistent/secrets/ident.txt
      sudo cp -v /etc/ident-blue.txt /mnt/nix/persistent/home/adjivas/.secrets/ident.txt
      sudo cp -v /etc/ident-blue.txt /mnt/nix/persistent/home/kad/.secrets/ident.txt
      sudo cp -v -rL /etc/secrets-system/ /mnt/nix/persistent/secrets/age
      sudo cp -v -rL /etc/secrets-user /mnt/nix/persistent/home/adjivas/.secrets/age
      sudo cp -v -rL /etc/secrets-user /mnt/nix/persistent/home/kad/.secrets/age

      echo "Backup Step"
      SSH_KEY="/tmp/btrbk_dreamland_ed25519_key"
      sudo ${pkgs.age}/bin/age --decrypt -i /etc/ident-blue.txt /etc/secrets-system/btrbk_dreamland_ed25519_key.age | sudo tee "$SSH_KEY" > /dev/null
      sudo chmod 0400 "$SSH_KEY"
      for subvol in Documents Etudes Pictures PoCs; do
        if ! latest=$(sudo ssh -i "$SSH_KEY" -p 60022 -o UserKnownHostsFile=/etc/ssh/known_hosts -o ConnectTimeout=1 -o IdentitiesOnly=yes btrbk-latest@$remote "''${subvol}"); then
          echo "Failed to retrieve latest backup for $subvol"
          continue
        fi
        sudo btrfs subvolume delete "/mnt/nix/persistent/home/adjivas/$subvol"
        sudo btrfs receive "/mnt/nix/persistent/snapshots/adjivas" < <(
          sudo ssh -i "$SSH_KEY" -p 60022 -o UserKnownHostsFile=/etc/ssh/known_hosts -o ConnectTimeout=1 -o IdentitiesOnly=yes btrbk-restore@$remote $machine $latest
        )
        sudo btrfs subvolume snapshot \
          "/mnt/nix/persistent/snapshots/adjivas/$(basename "$latest")" \
          "/mnt/nix/persistent/home/adjivas/$subvol"
      done
      sudo mkdir -p /mnt/nix/persistent/backups/$remote/adjivas

      echo "Agenix Step"
      sudo mkdir -v -p /nix/persistent/secrets
      sudo mount -v --bind /mnt/nix/persistent/secrets /nix/persistent/secrets
      sudo mount -v -o remount,ro,bind /nix/persistent/secrets

      echo "Install Step"
      sudo cp -v -rL /etc/navios /mnt/nix/persistent/etc
      (sudo time ${pkgs.nixos-install-tools}/bin/nixos-install \
        --no-channel-copy \
        --no-root-password \
        --option accept-flake-config true \
        --flake /mnt/nix/persistent/etc/navios#$machine) 2>&1 | sudo tee /tmp/install.log /mnt/nix/persistent/home/adjivas/install.log
      sudo reboot
    '';

    programs.bash = {
      loginShellInit = ''
        if [ "$SHLVL" -eq 1 ] && [ "$(tty)" = "/dev/tty1" ]; then
          sh /etc/install.sh
        fi
      '';
    };
    # elif [[ "$(cat /sys/class/dmi/id/board_name)" == "SABERTOOTH Z87" ]]; then

    users.motd = "hey listen!";
    users.users.nixos.isNormalUser = true;
    users.groups.nixos = {};
    users.users.nixos.group = "nixos";
    users.users.nixos.extraGroups = ["wheel"];

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      git
      disko
      age
      agebox
      # debug
      pkgs.htop
      pkgs.ripgrep
      pkgs.vim
    ];

    system.stateVersion = "26.05";
  };
}
