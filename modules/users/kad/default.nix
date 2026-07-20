{
  den.aspects.kad.homeManager = {
    config,
    pkgs,
    ...
  }: {
    home.shellAliases = {
      zathura = "${pkgs.zathura}/bin/zathura --fork";
    };

    nvf = {
      mouse = "a";
    };
    gnome-control-center = {
      user = "kad";
    };
    git = {
    };

    # stylix-theme.scheme = {
    #   base05 = "#fbf5e4"; # background layer1
    #   base00 = "#1c1b22"; # foreground layer1
    #   base0C = "#f6e7bc"; # background layer3
    #   base01 = "#374956"; # foreground layer3
    #   # base0A = "#f9e2af"; # foreground extra
    # };
    stylix.targets.firefox.profileNames = [config.firefox.profileName];

    # TODO remove this evil lines
    # nixpkgs.config.permittedInsecurePackages = [
    #   "luanti-5.14.0"
    # ];

    home.packages = with pkgs; [
      # luanti-client
      # Graphics
      krita
      blender
      # Chat
      dino
    ];
  };
}
