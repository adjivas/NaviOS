{ lib, pkgs, config, ... }: {
  options = {
    kitty.enable = lib.mkEnableOption "enable kitty";
  };
  config = lib.mkIf config.kitty.enable {
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
        # shell_integration = "disabled";

        cursor_blink_interval = 0.75;
        cursor_shape = "block";
        cursor_shape_unfocused = "unchanged";

        # Font
        font_family = config.stylix.fonts.monospace.name;
        font_size = config.stylix.fonts.sizes.terminal + 0.0;

        # Colors
        foreground = config.stylix.base16Scheme.base05;
        background = config.stylix.base16Scheme.base00;
        selection_background = config.stylix.base16Scheme.base05;
        selection_foreground = config.stylix.base16Scheme.base00;
        url_color = config.stylix.base16Scheme.base04;
        cursor = config.stylix.base16Scheme.base0C;
        cursor_text_color = config.stylix.base16Scheme.base04;
        active_border_color = config.stylix.base16Scheme.base03;
        inactive_border_color = config.stylix.base16Scheme.base01;
        active_tab_background = config.stylix.base16Scheme.base00;
        active_tab_foreground = config.stylix.base16Scheme.base05;
        inactive_tab_background = config.stylix.base16Scheme.base01;
        inactive_tab_foreground = config.stylix.base16Scheme.base04;
        tab_bar_background = config.stylix.base16Scheme.base01;
        wayland_titlebar_color = config.stylix.base16Scheme.base00;
        macos_titlebar_color = config.stylix.base16Scheme.base00;

        # Normal colors (0-7)
        color0 = config.stylix.base16Scheme.base00;
        color1 = config.stylix.base16Scheme.base08;
        color2 = config.stylix.base16Scheme.base0B;
        color3 = config.stylix.base16Scheme.base0C;
        color4 = config.stylix.base16Scheme.base0D;
        color5 = config.stylix.base16Scheme.base0E;
        color6 = config.stylix.base16Scheme.base0C;
        color7 = config.stylix.base16Scheme.base05;

        # Bright colors (8-15)
        color8 = config.stylix.base16Scheme.base03;
        color9 = config.stylix.base16Scheme.base08;
        color10 = config.stylix.base16Scheme.base0B;
        color11 = config.stylix.base16Scheme.base0C;
        color12 = config.stylix.base16Scheme.base0D;
        color13 = config.stylix.base16Scheme.base0E;
        color14 = config.stylix.base16Scheme.base0C;
        color15 = config.stylix.base16Scheme.base07;

        # Extended base16 colors (16-21)
        color16 = config.stylix.base16Scheme.base09;
        color17 = config.stylix.base16Scheme.base0F;
        color18 = config.stylix.base16Scheme.base01;
        color19 = config.stylix.base16Scheme.base02;
        color20 = config.stylix.base16Scheme.base04;
        color21 = config.stylix.base16Scheme.base06;
      };
    };
    home.shellAliases.lsix = "icat";
    home.packages = [
      pkgs.babashka
      pkgs.ghostscript
      (pkgs.writeTextFile {
        name = "icat";
        destination = "/bin/icat";
        executable = true;
        text = ''
          #!${pkgs.babashka}/bin/bb

          (require '[babashka.fs :as fs]
                   '[babashka.process :refer [sh]])

          (def thumbnail-size 320)

          (defn identify-ok [path]
            (let [{:keys [exit out]}
                  (sh ["${pkgs.imagemagick}/bin/magick" "identify" (str path)] {:err :string})]
              (when (zero? exit)
                {:path (str path)})))

          (defn compose-images-bytes [images]
            (let [args (-> ["${pkgs.imagemagick}/bin/magick" "-background" "black"]
                   (into (mapcat (fn [image] [
                     "(" image
                       "-resize" (str thumbnail-size "x" thumbnail-size)
                       "-gravity" "center"
                       "-extent"  (str thumbnail-size "x" thumbnail-size)
                     ")"]) images))
                   (conj "+append" "-alpha" "remove" "png:-"))
                 {:keys [exit out err]} (sh args {:out :bytes :err :string})]
              (when (pos? exit)
                (throw (ex-info "magick append failed" {:exit exit :err err}))) out))

          (defn icat-image [bytes]
            (let [{:keys [exit err]}
                  (sh ["${pkgs.kitty}/bin/kitty" "+kitten" "icat" "--align" "left" "--stdin" "yes"]
                      {:in bytes :out :inherit :err :inherit})]
              (when (pos? exit)
                (throw (ex-info "kitty icat failed" {:exit exit :err err})))))

          (defn window-size []
            (let [s (:out (sh ["${pkgs.kitty}/bin/kitty" "+kitten" "icat" "--print-window-size"] {:out :string}))
                  [w h] (str/split (str/trim s) #"x")]
              {:weight (Long/parseLong w)
               :height (Long/parseLong h)}))

          (defn list-files [path]
            (->> (fs/list-dir path)
                 (filter fs/regular-file?)
                 (keep identify-ok)
                 (map :path)))

          (defn print-images [files]
            (let [paths files
                  weight (:weight (window-size))
                  chunk-size (max 1 (quot weight thumbnail-size))
                  chunks (partition-all chunk-size paths)]
              (doseq [partition chunks]
                (-> partition compose-images-bytes icat-image))))

          (defn expand-path [path]
            (cond
              (fs/regular-file? path) [(str path)]
              (fs/directory? path) (list-files path)
              :else []))

          (let [paths *command-line-args*]
            (if (seq paths)
              (print-images (mapcat expand-path paths))
              (do (print-images (list-files ".")))))
        '';
      })
    ];
  };
}
