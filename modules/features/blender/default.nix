{
  den.aspects.blender.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.blender = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.blender;
      };
      startup = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = ./startup.blend;
      };
      themes = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
      };
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
      };
    };

    config = let
      blenderVersion = lib.versions.majorMinor config.blender.package.version;
    in {
      home.packages = [config.blender.package];

      home.file = lib.mkMerge [
        (lib.optionalAttrs (config.blender.startup != null) {
          ".config/blender/${blenderVersion}/config/startup.blend".source =
            config.blender.startup;
        })
        (lib.listToAttrs (
          map (theme: {
            name = ".config/blender/${blenderVersion}/scripts/presets/interface_theme/${baseNameOf theme}";
            value.source = theme;
          })
          config.blender.themes
        ))
      ];

      home.activation.blenderPreferences = lib.hm.dag.entryAfter ["blenderExtensions"] ''
        ${lib.getExe config.blender.package} --background --python-expr '
          import bpy


          bpy.context.preferences.view.show_splash = False
          bpy.ops.preferences.addon_enable(module="bl_ext.blender_org.node_wrangler")
          bpy.ops.wm.save_userpref()
        '
      '';

      home.activation.blenderExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
        for extension in ${lib.escapeShellArgs (map toString config.blender.extensions)}; do
          ${lib.getExe config.blender.package} \
            --command extension install-file \
            -r user_default \
            -e "$extension"
        done
      '';
    };
  };
}
