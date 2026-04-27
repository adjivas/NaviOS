{ pkgs, lib, config, ... }: {
  options = {
    sm64ex.enable = lib.mkEnableOption "enable sm64ex";
    sm64ex.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sm64coopdx;
    };
    sm64ex.baserom = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
    };
    sm64ex.settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        # save-name: = 0 SM64;
        # save-name: = 1 SM64;
        # save-name: = 2 SM64;
        # save-name: = 3 SM64;
        amount_of_players = 16;
        background_gamepad = 838860801;
        bettercam_aggression = 0;
        bettercam_analog = false;
        bettercam_centering = false;
        bettercam_collision = true;
        bettercam_degrade = 50;
        bettercam_dpad = false;
        bettercam_enable = false;
        bettercam_invertx = false;
        bettercam_inverty = true;
        bettercam_mouse_look = false;
        bettercam_pan_level = 0;
        bettercam_xsens = 50;
        bettercam_ysens = 50;
        bubble_death = true;
        compress_on_startup = false;
        coop_bouncy_bounds = 0;
        coop_draw_distance = 4;
        coop_host_port = 7777;
        coop_host_save_slot = 1;
        coop_join_ip = "mario.navi";
        coop_join_port = 7777;
        coop_menu_level = 0;
        coop_menu_random = false;
        coop_menu_sound = 0;
        coop_menu_staff_roll = false;
        coop_nametags = true;
        coop_network_system = 0;
        coop_player_interaction = 1;
        coop_player_knockback_strength = 25;
        coop_player_model = 0;
        coop_player_palette_cap = [ "ff" "00" "00" ] ;
        coop_player_palette_emblem = [ "ff" "00" "00" ];
        coop_player_palette_gloves = [ "ff" "ff" "ff" ];
        coop_player_palette_hair = [ "73" "06" "00" ];
        coop_player_palette_pants = [ "00" "00" "ff" ];
        coop_player_palette_shirt = [ "ff" "00" "00" ];
        coop_player_palette_shoes = [ "72" "1c" "0e" ];
        coop_player_palette_skin = [ "fe" "c1" "79" ];
        coop_stay_in_level_after_star = 0;
        coopnet_dest = 0;
        coopnet_ip = "net.coop64.us";
        coopnet_password = "";
        coopnet_port = 34197;
        debug_error = true;
        debug_info = true;
        debug_offset = 0;
        debug_print = true;
        debug_tags = 0;
        disable_gamepads = false;
        disable_popups = false;
        djui_scale = 0;
        djui_theme = 1;
        djui_theme_center = true;
        djui_theme_font = 0;
        dynos_local_player_model_only = false;
        env_volume = 127;
        fade_distant_sounds = false;
        frame_limit = 60;
        fullscreen = false;
        gamepad_number = 0;
        interpolation_mode = 1;
        key_a = [ "0026" "1000" "1103" ];
        key_b = [ "0033" "1001" "1101" ];
        key_cdown = [ "0150" "ffff" "ffff" ];
        key_chat = [ "001c" "ffff" "ffff" ];
        key_cleft = [ "014b" "ffff" "ffff" ];
        key_console = [ "0029" "003b" "ffff" ];
        key_cright = [ "014d" "ffff" "ffff" ];
        key_cup = [ "0148" "ffff" "ffff" ];
        key_ddown = [ "014f" "100c" "ffff" ];
        key_disconnect = [ "ffff" "ffff" "ffff" ];
        key_dleft = [ "0153" "100d" "ffff" ];
        key_dright = [ "0151" "100e" "ffff" ];
        key_dup = [ "0147" "100b" "ffff" ];
        key_l = [ "002a" "1009" "1104" ];
        key_next = [ "0018" "ffff" "ffff" ];
        key_playerlist = [ "000f" "1004" "ffff" ];
        key_prev = [ "0016" "ffff" "ffff" ];
        key_r = [ "0036" "100a" "101b" ];
        key_start = [ "0039" "1006" "ffff" ];
        key_stickdown = [ "001f" "ffff" "ffff" ];
        key_stickleft = [ "001e" "ffff" "ffff" ];
        key_stickright = [ "0020" "ffff" "ffff" ];
        key_stickup = [ "0011" "ffff" "ffff" ];
        key_x = [ "0017" "1002" "ffff" ];
        key_y = [ "0032" "1003" "ffff" ];
        key_z = [ "0025" "1007" "101a" ];
        language = "English";
        lua_profiler = false;
        master_volume = 80;
        msaa = 0;
        music_volume = 127;
        mute_focus_loss = false;
        pause_anywhere = false;
        player_pvp_mode = 0;
        romhackcam_bowser = false;
        romhackcam_centering = false;
        romhackcam_collision = true;
        romhackcam_dpad = false;
        romhackcam_enable = 0;
        romhackcam_slowfall = true;
        romhackcam_toxic_gas = true;
        rules_version = 0;
        rumble_strength = 50;
        sfx_volume = 127;
        show_fps = true;
        skip_intro = true;
        skip_pack_generation = false;
        stick_deadzone = 16;
        texture_filtering = 2;
        uncapped_framerate = true;
        use_standard_key_bindings_chat = false;
        vsync = true;
        window_h = 800;
        window_w = 1280;
        window_x = 0;
        window_y = 0;
      };
    };
  };
  config = let
    mkConfig =
      key: value:
      let
        generatedValue =
          if lib.isBool value then
            (if value then "true" else "false")
          else if lib.isList value then
            lib.concatStringsSep " " value
          else
            toString value;
      in
      "${key} ${generatedValue}";
  in lib.mkIf config.sm64ex.enable {
    programs.sm64ex = {
      enable = true;
      package = config.sm64ex.package;
      baserom = config.sm64ex.baserom;
    };

    xdg.dataFile."sm64coopdx/sm64config.txt".text = lib.concatStringsSep "\n" (lib.mapAttrsToList mkConfig config.sm64ex.settings);

    home.file = let
      # Characters
      sonicCharacterRebooted = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/sonic-character-rebooted.13/download";
        name = "sonic-char-rebooted";
        sha256 = "sha256-Zi3lnnoukqVL86NgWI7qqqKp+27isHuIslwBZrTK38Q=";
        extension = "zip";
      };
      goomba = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/cs-goomba.1033/download";
        name = "goomba";
        sha256 = "sha256-plAI4XyOPar2eshSPNWTdUZsdXwxA9nijTknyDKZr7A=";
        extension = "zip";
      };
      penguin = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/cs-penguin.1025/download";
        name = "penguin";
        sha256 = "sha256-1v8F4oje2qXMyfXGif89U5U6vMN2R/3moFDlh9IpugY=";
        extension = "zip";
      };
      portals = pkgs.fetchzip {
        url = "https://github.com/peachypeachsm64/coopdx-mods-portals/releases/download/v1.0/portals.zip";
        name = "portals";
        sha256 = "sha256-5Pcox+Gr4W25kWz8g4Xubpz5DBFpsDRn8vLKmK5HB9A=";
        extension = "zip";
      };
      theWastelanders = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/cs-the-wastelanders.892/download";
        name = "[CS] The Wastelanders";
        sha256 = "sha256-3DV2Ni1KWcK5BIreMNLQ60icFWyfdmWi6PrAt5bSFNg=";
        extension = "zip";
      };
      murderDrones = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/cs-murder-drones-pack.755/download";
        name = "[CS] Murder Drones Pack";
        sha256 = "sha256-YlWMhWWzd21dMRphiQ4fJGB9HpoQAxMSTRvMkGAIvX0=";
        extension = "zip";
      };
      CDIZeldaTrio = pkgs.fetchzip {
        url = "https://filecache42.gamebanana.com/mods/cs_zelda_cdi_trio.zip";
        name = "[CS] Zelda CDI Trio";
        sha256 = "sha256-H+54ewsu2ZqNT3D3G0gkA/htzhytZOiHsIc8f8PK7fQ=";
        extension = "zip";
      };
      # Mods
      gunMod = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/gun-mod-dx.15/download";
        name = "gun-mod.zip";
        sha256 = "sha256-PhU5A2R74pzrfjW5hpklzVhrMu+mpKewSPn7tKjrIRY=";
        extension = "zip";
      };
      weatherCycleDX = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/weather-cycle-dx.272/download";
        name = "weather-cycle-dx.zip";
        sha256 = "sha256-xe3LHhCMJykAw1D8oxk/+9e/UqDvxdtQJ2z5LjIYCFo=";
        extension = "zip";
      };
      widdlePets = pkgs.fetchzip {
        url = "https://github.com/wibblus/widdle-pets/releases/download/v1.2/widdle-pets.zip";
        name = "widdle-pets";
        sha256 = "sha256-FjVhiWnhyX2Wr34ugwgZbjvf092+90GRu8QS646aJxk=";
        extension = "zip";
      };
      # Pets
      petPenguin = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/pet-penguin.274/download";
        name = "wpet-penguin";
        sha256 = "sha256-ihkaak/jh6WQztXuBMKKPjXeB7++ESJCurXpdXrSoEU=";
        extension = "zip";
      };
      petBoo = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/pet-boo-mod.277/download";
        name = "[PET] Boo Mod.zip";
        sha256 = "sha256-WzT7WeiXXVsCGzYH8qE78uHwBI8XzDS7zeOavtBzjDc=";
        extension = "zip";
      };
      crashBandicoot64 = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/crash-bandicoot-64.879/download";
        name = "crash-bandicoot-64";
        sha256 = "sha256-7zX/N1afVsE/CIZ5HfwXkBFSvGP7s4KFGq/7nAPPXWU=";
        extension = "zip";
      };
      coco = "[CS] TheWolf Coco Bandicoot";
      crash = "[CS] TheWolf Crash Bandicoot";
      akuaku = "[PET] Aku Aku";
      # Level
      superMarioKart = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/super-mario-kart.24/download";
        name = "super-mario-kart";
        sha256 = "sha256-8uuQoHAefNWXOARoHw9hQ+0K/vHZhFg8fRvNJC4l7CY=";
        extension = "zip";
      };
      minecraftHangoutCollection = pkgs.fetchzip {
        url = "https://mods.sm64coopdx.com/mods/minecraft-hangout-collection.714/download";
        name = "minecraft-hangout-collection";
        sha256 = "sha256-0ocQLpcQSun6o1Dlak0stEV+bF0l85tp0nmrvgarz+I=";
        extension = "zip";
      };
    in {
      ".local/share/sm64coopdx/mods/sonic-char-rebooted".source = "${sonicCharacterRebooted}";
      ".local/share/sm64coopdx/mods/goomba".source = "${goomba}";
      ".local/share/sm64coopdx/mods/penguin".source = "${penguin}";
      ".local/share/sm64coopdx/mods/portals".source = "${portals}";
      ".local/share/sm64coopdx/mods/[CS] The Wastelanders".source = "${theWastelanders}";
      ".local/share/sm64coopdx/mods/[CS] Murder Drones Pack".source = "${murderDrones}";
      ".local/share/sm64coopdx/mods/[CS] Zelda CDI Trio".source = "${CDIZeldaTrio}";
      ".local/share/sm64coopdx/mods/gun-mod".source = "${gunMod}";
      ".local/share/sm64coopdx/mods/weather-cycle-dx".source = "${weatherCycleDX}";
      ".local/share/sm64coopdx/mods/widdle-pets".source = "${widdlePets}";
      ".local/share/sm64coopdx/mods/wpet-penguin".source = "${petPenguin}";
      ".local/share/sm64coopdx/mods/[PET] Boo Mod".source = "${petBoo}";
      ".local/share/sm64coopdx/mods/${coco}".source = "${crashBandicoot64}/${coco}";
      ".local/share/sm64coopdx/mods/${crash}".source = "${crashBandicoot64}/${crash}";
      ".local/share/sm64coopdx/mods/${akuaku}".source = "${crashBandicoot64}/${akuaku}";
      ".local/share/sm64coopdx/mods/super-mario-kart".source = "${superMarioKart}";
      ".local/share/sm64coopdx/mods/minecraft-hangout-collection".source = "${minecraftHangoutCollection}";
    };
  };
}
