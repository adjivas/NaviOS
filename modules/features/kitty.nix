{
  den.aspects.kitty.homeManager = {
    lib,
    pkgs,
    config,
    osConfig,
    ...
  }: {
    options.kitty = {
      cursorColor = lib.mkOption {
        type = lib.types.str;
        default = "#00ffff";
      };
      cursorTextColor = lib.mkOption {
        type = lib.types.str;
        default = osConfig.stylix.base16Scheme.base04;
      };
    };

    config = {
      stylix.targets.kitty.enable = false;
      programs.kitty = {
        enable = true;
        enableGitIntegration = true;
        shellIntegration.enableBashIntegration = true;
        settings = {
          confirm_os_window_close = 0;
          hide_window_decorations = "yes";
          close_on_child_death = true;
          enable_audio_bell = false;
          copy_on_select = true;
          clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
          paste_actions = "filter,quote-urls-at-prompt,confirm";
          # shell_integration = "disabled";

          cursor_blink_interval = 0.75;
          cursor_shape = "block";
          cursor_shape_unfocused = "unchanged";

          # Font
          font_family = osConfig.stylix.fonts.monospace.name;
          # font_size = osConfig.stylix.fonts.sizes.terminal + 0.0;

          # Colors
          foreground = osConfig.stylix.base16Scheme.base05;
          background = osConfig.stylix.base16Scheme.base00;
          selection_background = osConfig.stylix.base16Scheme.base05;
          selection_foreground = osConfig.stylix.base16Scheme.base00;
          url_color = osConfig.stylix.base16Scheme.base04;
          cursor = config.kitty.cursorColor;
          cursor_text_color = config.kitty.cursorTextColor;
          active_border_color = osConfig.stylix.base16Scheme.base03;
          inactive_border_color = osConfig.stylix.base16Scheme.base01;
          active_tab_background = osConfig.stylix.base16Scheme.base00;
          active_tab_foreground = osConfig.stylix.base16Scheme.base05;
          inactive_tab_background = osConfig.stylix.base16Scheme.base01;
          inactive_tab_foreground = osConfig.stylix.base16Scheme.base04;
          tab_bar_background = osConfig.stylix.base16Scheme.base01;
          wayland_titlebar_color = osConfig.stylix.base16Scheme.base00;
          macos_titlebar_color = osConfig.stylix.base16Scheme.base00;

          # Normal colors (0-7)
          color0 = osConfig.stylix.base16Scheme.base00;
          color1 = osConfig.stylix.base16Scheme.base08;
          color2 = osConfig.stylix.base16Scheme.base0B;
          color3 = osConfig.stylix.base16Scheme.base0C;
          color4 = osConfig.stylix.base16Scheme.base0D;
          color5 = osConfig.stylix.base16Scheme.base0E;
          color6 = osConfig.stylix.base16Scheme.base0C;
          color7 = osConfig.stylix.base16Scheme.base05;

          # Bright colors (8-15)
          color8 = osConfig.stylix.base16Scheme.base03;
          color9 = osConfig.stylix.base16Scheme.base08;
          color10 = osConfig.stylix.base16Scheme.base0B;
          color11 = osConfig.stylix.base16Scheme.base0C;
          color12 = osConfig.stylix.base16Scheme.base0D;
          color13 = osConfig.stylix.base16Scheme.base0E;
          color14 = osConfig.stylix.base16Scheme.base0C;
          color15 = osConfig.stylix.base16Scheme.base07;

          # Extended base16 colors (16-21)
          color16 = osConfig.stylix.base16Scheme.base09;
          color17 = osConfig.stylix.base16Scheme.base0F;
          color18 = osConfig.stylix.base16Scheme.base01;
          color19 = osConfig.stylix.base16Scheme.base02;
          color20 = osConfig.stylix.base16Scheme.base04;
          color21 = osConfig.stylix.base16Scheme.base06;
        };
      };
      xdg.configFile."kitty/paste-actions.py".text = ''
        def filter_paste(text: str) -> str:
            return text.replace("\\\r\n", " ").replace("\\\n", " ")
      '';

      home.packages = [
        pkgs.babashka
        pkgs.ghostscript
        (pkgs.writeTextFile {
          name = "lsi";
          destination = "/bin/lsi";
          executable = true;
          text = ''
            if [ "$#" -eq 0 ]; then
              mapfile -t images < <(
                find . -maxdepth 1 -type f -print0 |
                  while IFS= read -r -d "" file; do
                    ${pkgs.file}/bin/file --mime-type -b "$file" | grep -q '^image/' &&
                      printf '%s\n' "$file"
                  done
              )

              exec ${pkgs.chafa}/bin/chafa -g -l "''${images[@]}"
            elif [ "$#" -eq 1 ]; then
              exec ${pkgs.chafa}/bin/chafa --fit-width -l "$1"
            else
              exec ${pkgs.chafa}/bin/chafa -g -l "$@"
            fi
          '';
        })
      ];
    };
  };
}
