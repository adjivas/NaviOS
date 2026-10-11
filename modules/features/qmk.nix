{den, ...}: {
  den.aspects.qmk.nixos = {
    users.groups.qmk = {};

    services.udev.extraRules = ''
      # ErgoDox EZ / HalfKay
      SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="0478", GROUP="qmk", MODE="0660"

      # Swiss / Atmel DFU
      SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2ff4", GROUP="qmk", MODE="0660"
    '';
  };

  den.aspects.qmk-user = {user, ...}: {
    includes = [
      den.aspects.qmk
    ];

    nixos = {
      users.users.${user.userName}.extraGroups = [
        "qmk"
      ];
    };
  };
}
