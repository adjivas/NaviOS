{ lib, pkgs, config, ... }: {
  options = {
    mangohud.enable = lib.mkEnableOption "enable mangohud";
    mangohud.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mangohud;
    };
  };
  config = lib.mkIf config.mangohud.enable {
    stylix.targets.mangohud.enable = true;

    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
      package = config.mangohud.package;
      settings = {
        background_alpha = lib.mkForce 0.0;
        font_size = lib.mkForce 16;
        no_small_font = true;
        font_scale = lib.mkForce 1.0;
        font_scale_media_player = 1.0;

        hud_no_margin = true;
        text_outline_thickness = 1.5;
        horizontal = true;

        time = true;
        time_no_label = true;
        time_format = "%H:%M";

        frame_timing = 0;
        media_player = true;
        media_player_format = "{artist} - {title}";

        fps_limit = "90,144,240";

        gpu_stats = true;
        cpu_stats = true;
        vram = true;
        ram = true;
        ram_color = "F5C2E7";
      };
    };
  };
}
