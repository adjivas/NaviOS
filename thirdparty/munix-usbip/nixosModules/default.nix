{self}: {
  pkgs,
  lib,
  utils,
  config,
  ...
}: let
  runtimeDir = "/run/vm-user";
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.virtualisation.munix.defaultCommand = lib.mkOption {
    type = lib.types.str;
    default = "bash";
    description = "Default command to run when starting the VM without arguments.";
  };

  config = {
    boot.isContainer = true;
    fileSystems."/".device = lib.mkDefault "/dev/sda"; # dummy
    fileSystems."/".fsType = "invisiblefs";

    # Disable unused things
    environment.defaultPackages = lib.mkDefault [];
    documentation = {
      enable = lib.mkDefault false;
      doc.enable = lib.mkDefault false;
      info.enable = lib.mkDefault false;
      man.enable = lib.mkDefault false;
      nixos.enable = lib.mkDefault false;
    };
    services.logrotate.enable = false;
    services.udisks2.enable = false;
    system.tools.nixos-generate-config.enable = false;
    system.activationScripts.specialfs = lib.mkForce "";
    systemd.coredump.enable = false;
    networking.firewall.enable = false;
    networking.useDHCP = lib.mkDefault false;
    networking.resolvconf.enable = false;
    powerManagement.enable = false;
    boot.kexec.enable = false;
    console.enable = false;

    # Configure activation / systemd
    boot.initrd.systemd.enable = true; # for etc.overlay, but we don't have initrd
    system.etc.overlay.enable = true; # erofs
    system.etc.overlay.mutable = false;
    system.systemBuilderCommands =
      # XXX: removed with the introduction of nixos-init
      ''
        ln -s ${config.system.build.etcMetadataImage} $out/etc-metadata-image
        ln -s ${config.system.build.etcBasedir} $out/etc-basedir
      '';
    system.switch.enable = false;
    services.udev.enable = lib.mkDefault true;
    services.udev.packages = lib.mkDefault [];
    services.resolved.enable = false;
    environment.etc."resolv.conf".source = "/run/resolv.conf";
    environment.etc."machine-id".source = "/run/machine-id";
    environment.etc."localtime".source = "/run/localtime";
    environment.etc."systemd/system".source = lib.mkForce (
      utils.systemdUtils.lib.generateUnits {
        type = "system";
        units = config.systemd.units;
        upstreamUnits = [
          "sysinit.target"
          "local-fs.target"
          "nss-user-lookup.target"
          "umount.target"
          "sockets.target"
          "shutdown.target"
          "reboot.target"
          "exit.target"
          "final.target"
          "systemd-exit.service"
          "systemd-journald.socket"
          "systemd-journald-audit.socket"
          "systemd-journald-dev-log.socket"
          "systemd-journald.service"
          "systemd-udevd-kernel.socket"
          "systemd-udevd-control.socket"
          "user.slice"
        ];
        upstreamWants = ["multi-user.target.wants"];
      }
    );

    # systemd.package = pkgs.systemdMinimal; # no analyze
    systemd.defaultUnit = "microvm.target";
    systemd.targets.microvm = {
      description = "Minimal microVM system";
      wants = [
        "systemd-journald.socket"
        "systemd-udevd.service"
        "dbus.socket"
      ];
      unitConfig.AllowIsolate = "yes";
    };
    systemd.services.generate-shutdown-ramfs.enable = lib.mkForce false;
    systemd.services.systemd-remount-fs.enable = lib.mkForce false;
    systemd.services.systemd-pstore.enable = lib.mkForce false;
    systemd.services.lastlog2-import.enable = lib.mkForce false;
    systemd.services.suid-sgid-wrappers.enable = lib.mkForce false;
    systemd.services.systemd-udevd = {
      # Redefine to remove the Before deps and get out of the critical chain
      enable = true;
      description = "Rule-based Manager for Device Events and Files";
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        CapabilityBoundingSet = "~CAP_SYS_TIME CAP_WAKE_ALARM";
        Delegate = "";
        DelegateSubgroup = "udev";
        Type = "notify-reload";
        OOMScoreAdjust = "-1000";
        Sockets = "systemd-udevd-control.socket systemd-udevd-kernel.socket systemd-udevd-varlink.socket";
        Restart = "always";
        RestartSec = "0";
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-udevd";
        FileDescriptorStoreMax = "512";
        FileDescriptorStorePreserve = "yes";
        KillMode = "mixed";
        TasksMax = "infinity";
        PrivateMounts = "yes";
        ProtectHostname = "yes";
        MemoryDenyWriteExecute = "yes";
        RestrictAddressFamilies = "AF_UNIX AF_NETLINK AF_INET AF_INET6";
        RestrictRealtime = "yes";
        RestrictSUIDSGID = "yes";
        SystemCallFilter = [
          "@system-service @module @raw-io bpf"
          "~@clock"
        ];
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        LockPersonality = "yes";
        IPAddressDeny = "any";
        WatchdogSec = "3min";
      };
    };

    # Configure user accounts
    systemd.sysusers.enable = false;
    services.userborn.enable = true;
    services.userborn.static = true;
    users.mutableUsers = false;
    users.users.appvm = {
      uid = 1337;
      group = "appvm";
      isNormalUser = false;
      isSystemUser = true;
      home = "/home/appvm";
      description = "microVM User";
      shell = pkgs.bash; # not nologin, despite being a "system" user
      extraGroups = [
        "wheel"
        "video"
        "input"
        "systemd-journal"
      ];
    };
    users.groups.appvm.gid = 1337;
    users.allowNoPasswordLogin = true;

    # Configure services

    systemd.settings.Manager.DefaultEnvironment = "XDG_RUNTIME_DIR=${runtimeDir}";

    systemd.sockets.session-bus = {
      enable = true;
      description = "D-Bus session bus socket";
      wantedBy = ["microvm.target"];
      partOf = ["session-bus.service"];
      listenStreams = ["${runtimeDir}/dbus.sock"];
      socketConfig = {
        SocketUser = "appvm";
        SocketGroup = "appvm";
      };
    };
    systemd.services.session-bus = {
      enable = true;
      description = "D-Bus session bus";
      requires = ["session-bus.socket"];
      serviceConfig = {
        ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --syslog-only"; # no systemd activation, we don't run a *session* systemd
        User = "appvm";
        Group = "appvm";
      };
    };

    hardware.graphics.enable = true;
    hardware.graphics.package = self.packages.${system}.mesa;

    system.build.munix = pkgs.symlinkJoin {
      name = "munix";
      paths = [self.packages.${system}.munix];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/munix \
          --add-flags ${config.system.build.toplevel} \
          --set MICROVM_DEFAULT_COMMAND ${lib.escapeShellArg config.virtualisation.munix.defaultCommand}
      '';
    };
  };
}
