{ pkgs, ... }: {
  programs.adb.enable = true;
  users.users."adjivas".extraGroups = ["adbusers"];

  services.udev.packages = [
    pkgs.androidenv.androidPkgs.platform-tools
  ];
}
