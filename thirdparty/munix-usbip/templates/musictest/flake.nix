{
  nixConfig = {
    extra-substituters = ["https://cache.clan.lol"];
    extra-trusted-public-keys = [
      "cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28="
    ];
  };

  inputs = {
    munix.url = "git+https://git.clan.lol/clan/munix?shallow=1&ref=main";
    nixpkgs.follows = "munix/nixpkgs";
  };

  outputs = {
    nixpkgs,
    munix,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ];
    musictest-vm = system:
      nixpkgs.lib.nixosSystem {
        modules = [
          munix.nixosModules.default
          (
            {pkgs, ...}: {
              system.stateVersion = "26.05";
              virtualisation.munix.defaultCommand = "euphonica";

              nixpkgs.hostPlatform = system;

              programs.dconf.enable = true;
              fonts.packages = with pkgs; [adwaita-fonts];
              environment.systemPackages = with pkgs; [euphonica];

              # Local background service as a demo that doesn't require network creds :)
              services.mpd = {
                enable = true;
                startWhenNeeded = true;
                musicDirectory = "/etc/demo-music";
                user = "appvm";
                group = "appvm";
                settings.audio_output = [
                  {
                    type = "pipewire";
                    name = "Pipewire Output";
                  }
                ];
              };
              environment.etc."demo-music/0101GhostsI.ogg".source = pkgs.fetchurl {
                # just a CC-BY-SA licensed example
                url = "https://archive.org/download/NineInchNailsGhostsI-Iv24bit48khz/0101GhostsI.ogg";
                sha256 = "0iijm1c191aqkxybl4a4gvlpnf72hk4896lwvp0xixkhds88qzxi";
              };
            }
          )
        ];
      };
  in {
    packages = forAllSystems (system: {
      default = (musictest-vm system).config.system.build.munix;
    });
  };
}
