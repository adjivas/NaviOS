rec {
  # Den adapted from default microvm template.
  description = "NixOS in MicroVMs with Den";

  nixConfig = {
    extra-substituters = [
      "https://microvm.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      "cache.nixos.org-1:6NCHdD59X431o0gWDea5TUrG2NPlLxP3oyrN6qT5XrM="
    ];
  };

  inputs.den.url = "github:denful/den";
  inputs.import-tree.url = "github:denful/import-tree";
  inputs.navios = {
    url = "git+https://framagit.org/mouse/nix.git?ref=DEN";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  inputs.microvm = {
    url = "github:microvm-nix/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.super-mario-64-rom = {
    url = "path:/home/adjivas/.agenix/agenix/games/super_mario_64.us.z64";
    # url = "path:/home/adjivas/.games/super_mario_64.us.z64";
    # url = "path:./super_mario_64.us.z64";
    flake = false;
  };

  inputs.sm64mods_bandicoot64 = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/bandicoot64.zip";
    flake = false;
  };

  inputs.sm64mods_cs_bomberman = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_bomberman.zip";
    flake = false;
  };

  inputs.sm64mods_cs_goomba = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_goomba.zip";
    flake = false;
  };

  inputs.sm64mods_cs_murder_drones_pack = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_murder_drones_pack.zip";
    flake = false;
  };

  inputs.sm64mods_cs_penguin = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_penguin.zip";
    flake = false;
  };

  inputs.sm64mods_cs_rayman = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_rayman.zip";
    flake = false;
  };

  inputs.sm64mods_cs_the_wastelanders = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_the_wastelanders.zip";
    flake = false;
  };

  inputs.sm64mods_cs_tom_and_jerry = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_tom_and_jerry.zip";
    flake = false;
  };

  inputs.sm64mods_cs_zelda_cdi_trio = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/cs_zelda_cdi_trio.zip";
    flake = false;
  };

  inputs.sm64mods_epic_mickey_texture_pack = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/epic_mickey_texture_pack.zip";
    flake = false;
  };

  inputs.sm64mods_gun_mod = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/gun_mod.zip";
    flake = false;
  };

  inputs.sm64mods_minecraft_hangout_collection = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/minecraft_hangout_collection.zip";
    flake = false;
  };

  inputs.sm64mods_pet_boo = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/pet_boo.zip";
    flake = false;
  };

  inputs.sm64mods_pet_widdle = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/pet_widdle.zip";
    flake = false;
  };

  inputs.sm64mods_portals = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/portals.zip";
    flake = false;
  };

  inputs.sm64mods_sonic_char_rebooted = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/sonic_char_rebooted.zip";
    flake = false;
  };

  inputs.sm64mods_super_mario_kart = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/super_mario_kart.zip";
    flake = false;
  };

  inputs.sm64mods_weather_cycle_dx = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/weather_cycle_dx.zip";
    flake = false;
  };

  inputs.sm64mods_wpet_penguin = {
    url = "path:/home/adjivas/.agenix/agenix/games/sm64mods/wpet_penguin.zip";
    flake = false;
  };

  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [
        (inputs.import-tree "${inputs.navios}/modules/features")
        (inputs.import-tree ./modules)
        {
          den.aspects.runnable-sm64coopdx-microvm.nixos = {
            nixpkgs.config.allowUnfree = true;
          };
        }
      ];
      specialArgs = {
        inherit inputs;
      };
    }).config.flake;
}
