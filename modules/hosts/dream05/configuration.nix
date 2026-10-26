{
  den.aspects.dream05-configuration.nixos = {pkgs, ...}: {
    # Enable experimental Nix features (flakes).
    nixpkgs.config.allowUnfree = true;
    nix = {
      settings = {
        builders-use-substitutes = true;
        accept-flake-config = true;
        warn-dirty = false;
        experimental-features = [
          "flakes"
          "nix-command"
          "pipe-operators"
        ];
        trusted-users = ["@wheel"];
        trusted-public-keys = [
          "dreamland-1:y2C2W6jwh9S6gF9bcrKRBP7GOXBvmO0MEQSNUzAHUTU=" # remote build
        ];
      };
    };

    # Disable documentation (hides desktop icon).
    documentation.nixos.enable = false;

    systemd.network.wait-online.enable = false;

    # Core GNOME apps are set by the `gnome-mobile` module. The additional packages
    # listed here can be seen as an example of other useful apps for mobile use.
    environment.systemPackages = with pkgs; [
      # Miscellaneous packages.
      wl-clipboard # Wayland clipboard util, also used for Waydroid clipboard sharing.

      # Apps.
      dialect # Translation app.
      firefox-mobile
      gnome-decoder # QR code scanner & generator.
      gnome-software
      resources # System resource monitor.
      warp # Magic wormhole file transfer.

      # GNOME extensions.
      gnomeExtensions.app-hider # Hide desktop icons.
    ];

    system.stateVersion = "26.05";
  };
}
