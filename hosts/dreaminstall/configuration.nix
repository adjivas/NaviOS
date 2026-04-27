{ self, secretsSystem, secretsUser, cache, pkgs, lib, ... }: {
  imports = [
    (self + /nixosModules/yubico.nix)
  ];

  nix.settings.download-buffer-size = "5096M";

  # nix config show --extra-experimental-features nix-command | grep trusted-public-keys
  # nix build nixpkgs#hello --extra-experimental-features flakes --extra-experimental-features nix-command --option substituters "http://192.168.1.2:5000"
  nix.settings = {
    substituters = [
      "http://192.168.1.2:5000"
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "binarycache.example.com:9TSbWtdq8CqiAC28r3g2OF27vJP2I28edNSyRwMVgts="
    ];
  };

  environment.etc."navios".source = self;

  environment.etc."secrets-system".source = secretsSystem;
  environment.etc."secrets-user".source = secretsUser;

  # udevadm info --query=property --name=/dev/sdX | grep ID_SERIAL
  services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="NAVY_INDUSTRY", SYMLINK+="disk/by-id/ata-NavyIndustry_SSD"
    SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", ENV{ID_SERIAL}=="NAVY_INDUSTRY", SYMLINK+="disk/by-id/ata-NavyIndustry_SSD-part%n"

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

  yubico.enable = true;

  boot.tmp.useTmpfs = false;

  environment.etc."install.sh".text = ''
    set -euo pipefail

    echo "Are you ready ? (Press Enter)"
    read
    sudo ${pkgs.age}/bin/age --decrypt -i /etc/ident-red.txt /etc/secrets-system/key-0.ident.age | sudo tee /etc/ident-blue.txt > /dev/null
    echo "Disko Step"
    sudo ${pkgs.age}/bin/age --decrypt -i /etc/ident-blue.txt /etc/secrets-system/disko-dreamland-password.txt.age | sudo tee /tmp/disk.key > /dev/null
    sudo ${pkgs.age}/bin/age --decrypt -i /etc/ident-blue.txt /etc/secrets-system/fido2-salt.bin.age | sudo tee /tmp/fido2-salt.bin > /dev/null
    sudo chmod 0400 /tmp/disk.key
    sudo chmod 0400 /tmp/fido2-salt.bin
    sudo ${pkgs.disko}/bin/disko --mode destroy,format,mount --yes-wipe-all-disks --flake /etc/navios/.#dream00
    for device in $(${pkgs.libfido2}/bin/fido2-token -L | ${pkgs.coreutils}/bin/cut -d: -f1); do
      sudo ${pkgs.systemd}/bin/systemd-cryptenroll \
        --fido2-with-client-pin=no \
        --fido2-device=$device \
        --fido2-salt-file=/tmp/fido2-salt.bin \
        --unlock-key-file=/tmp/disk.key \
        /dev/disk/by-partlabel/disk-dream00-luks
    done
    sudo mkdir -v -p /mnt/nix/persistent/{etc/nixos,var/{lib/{systemd/coredump,bluetooth,nixos},log}}
    sudo mkdir -v -p /mnt/nix/persistent/secrets /mnt/nix/persistent/home/adjivas/.secrets

    echo "Secret Step"
    sudo cp -v /etc/ident-blue.txt /mnt/nix/persistent/secrets/ident.txt
    sudo cp -v /etc/ident-blue.txt /mnt/nix/persistent/home/adjivas/.secrets/ident.txt
    sudo cp -v -rL /etc/secrets-system/ /mnt/nix/persistent/secrets/age
    sudo cp -v -rL /etc/secrets-user /mnt/nix/persistent/home/adjivas/.secrets/age

    echo "Agenix Step"
    sudo mkdir -v -p /nix/persistent/secrets
    sudo mount -v --bind /mnt/nix/persistent/secrets /nix/persistent/secrets
    sudo mount -v -o remount,ro,bind /nix/persistent/secrets

    echo "Install Step"
    sudo cp -v -rL /etc/navios /mnt/nix/persistent/etc
    if [[ "$(cat /sys/class/dmi/id/board_name)" == "Oryx Pro" ]]; then
      (sudo time ${pkgs.nixos-install-tools}/bin/nixos-install --no-channel-copy --no-root-password --option accept-flake-config true --flake /mnt/nix/persistent/etc/navios#dream76) 2>&1 | sudo tee /mnt/nix/persistent/home/adjivas/install.log
    else
      (sudo time ${pkgs.nixos-install-tools}/bin/nixos-install --no-channel-copy --no-root-password --option accept-flake-config true --flake /mnt/nix/persistent/etc/navios#dream00) 2>&1 | sudo tee /mnt/nix/persistent/home/adjivas/install.log
    fi
    sudo reboot
  '';

  programs.bash = {
    loginShellInit = ''
      if [ "$SHLVL" -eq 1 ]; then
        sh /etc/install.sh
      fi
    '';
  };
        # elif [[ "$(cat /sys/class/dmi/id/board_name)" == "SABERTOOTH Z87" ]]; then

  users.motd = "hey listen!";
  users.users.nixos.isNormalUser = true;
  users.groups.nixos = {};
  users.users.nixos.group = "nixos";
  users.users.nixos.extraGroups = [ "wheel" ];

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

  system.stateVersion = "25.11";
}
