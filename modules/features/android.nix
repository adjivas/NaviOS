{
  flake.nixosModules.android = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.android = {
      user = lib.mkOption {
        type = lib.types.str;
        description = "User to add to the adbusers group.";
      };
    };

    config = {
      programs.adb.enable = true;

      users.users.${config.android.user}.extraGroups = ["adbusers"];

      services.udev.packages = [
        pkgs.androidenv.androidPkgs.platform-tools
      ];
    };
  };
}
