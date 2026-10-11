{den, ...}: {
  den.batteries.android = {
    includes = [
      den.aspects.android
    ];

    nixos = {user, ...}: {
      users.users.${user.userName}.extraGroups = ["adbusers"];
    };
  };

  den.aspects.android.nixos = {pkgs, ...}: {
    programs.adb.enable = true;

    services.udev.packages = [
      pkgs.androidenv.androidPkgs.platform-tools
    ];
  };
}
