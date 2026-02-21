{ self, lib, pkgs, inputs, ... }: {
  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
    inputs.lan-mouse.homeManagerModules.default
  ];
  
  home-manager.extraSpecialArgs = {
    nvf = inputs.nvf.homeManagerModules.default;
    firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    buildFirefoxXpiAddon = inputs.firefox-addons.lib.${pkgs.stdenv.hostPlatform.system}.buildFirefoxXpiAddon;
    telegram-desktop = inputs.telegram-desktop-patched.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # luanti = inputs.nix-luanti.overlays.default;
    fenix = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};
  };

  home-manager.useUserPackages = true;
  home-manager.users.kad = ({ nvf, ... }: {
    home.username = "kad";
    home.homeDirectory = lib.mkForce "/home/kad";

    home.shellAliases = {
      zathura = "${pkgs.zathura}/bin/zathura --fork";
    };

    # Programs
    imports = [
      nvf
      (self + /homeManagerModules)
      ./firefox.nix
      ./sway.nix
    ];
    nvf = {
      enable = true;
      mouse = "a";
    };
    sway.enable = true;
    swaylock.enable = true;
    waybar.enable = true;
    bemenu.enable = true;
    firefox.enable = true;
    gnome-control-center = {
      enable = true;
      user = "kad";
    };
    telegram.enable = true;
    # luanti.enable = true;
    rust.enable = true;
    ripgrep.enable = true;
    kitty.enable = true;
    git = {
      enable = true;
    };
    fzf.enable = true;
    zathura.enable = true;
    ssh.enable = true;
    bash.enable = true;
    htop.enable = true;
    starship.enable = true;
    mangohud.enable = true;
    mako.enable = true;
    wlsunset.enable = true;
    pcsx2.enable = true;
    lan-mouse.enable = true;

    stylix-theme.scheme = {
      base05 = "#fbf5e4"; # background layer1
      base00 = "#1c1b22"; # foreground layer1
      base0C = "#f6e7bc"; # background layer3
      base01 = "#374956"; # foreground layer3
      # base0A = "#f9e2af"; # foreground extra
    };

    home.packages = with pkgs; [
      luanti-client
      # Graphics
      krita
      blender
      # Chat
      dino
    ];

    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "25.05";

    # Let home Manager install and manage itself.
    programs.home-manager.enable = true;
  });
}
