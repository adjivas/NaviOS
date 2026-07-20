{
  lib,
  inputs,
  ...
}: {
  den.aspects.sm64coopdx-runner-base.nixos = {
    nix.enable = true;
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "sm64coopdx"
      ];

    console.enable = false;

    hardware.graphics.enable = true;

    services.seatd.enable = true;

    users.users.alice = {
      isNormalUser = true;
      linger = true;
      extraGroups = [
        "seat"
        "input"
      ];
      createHome = true;
      password = "alice";
      home = "/home/alice";
    };
    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs = {
        baserom = inputs.super-mario-64-rom;
        sm64mods = [];
        # sm64mods = with inputs; [
        #   { name = "bandicoot64"; src = sm64mods_bandicoot64; }
        #   { name = "cs_bomberman"; src = sm64mods_cs_bomberman; }
        #   { name = "cs_goomba"; src = sm64mods_cs_goomba; }
        #   { name = "cs_murder_drones_pack"; src = sm64mods_cs_murder_drones_pack; }
        #   { name = "cs_penguin"; src = sm64mods_cs_penguin; }
        #   { name = "cs_rayman"; src = sm64mods_cs_rayman; }
        #   { name = "cs_the_wastelanders"; src = sm64mods_cs_the_wastelanders; }
        #   { name = "cs_tom_and_jerry"; src = sm64mods_cs_tom_and_jerry; }
        #   { name = "cs_zelda_cdi_trio"; src = sm64mods_cs_zelda_cdi_trio; }
        #   { name = "epic_mickey_texture_pack"; src = sm64mods_epic_mickey_texture_pack; }
        #   { name = "gun_mod"; src = sm64mods_gun_mod; }
        #   { name = "minecraft_hangout_collection"; src = sm64mods_minecraft_hangout_collection; }
        #   { name = "pet_boo"; src = sm64mods_pet_boo; }
        #   { name = "pet_widdle"; src = sm64mods_pet_widdle; }
        #   { name = "portals"; src = sm64mods_portals; }
        #   { name = "sonic_char_rebooted"; src = sm64mods_sonic_char_rebooted; }
        #   { name = "super_mario_kart"; src = sm64mods_super_mario_kart; }
        #   { name = "weather_cycle_dx"; src = sm64mods_weather_cycle_dx; }
        #   { name = "wpet_penguin"; src = sm64mods_wpet_penguin; }
        # ];
      };
    };
  };
}
