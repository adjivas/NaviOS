{self, ...}: {
  den.aspects.gajim.homeManager = {
    pkgs,
    lib,
    config,
    wrappers,
    ...
  }: let
    gajimIcon = builtins.path {
      name = "gajim.svg";
      path = "${self.outPath}/artwork/waybar/gajim.svg";
    };
  in {
    options.gajim.package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;

      default = let
        gajim = pkgs.gajim.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              substituteInPlace gajim/common/dbus/statusnotifieritem.py \
                --replace-fail \
                  '        self._menu = DBusMenuService("/StatusNotifierItem/Menu", session_bus, menu)' \
                  '        self._menu = DBusMenuService("/StatusNotifierItem/Menu", session_bus, menu)

                      self._watcher_id = Gio.bus_watch_name(
                          Gio.BusType.SESSION,
                          "org.kde.StatusNotifierWatcher",
                          Gio.BusNameWatcherFlags.NONE,
                          self._on_watcher_appeared,
                          self._on_watcher_vanished,
                      )

                  def _on_watcher_appeared(self, *_args: Any) -> None:
                      self.register()

                  def _on_watcher_vanished(self, *_args: Any) -> None:
                      self._registered = False'
            '';

          postInstall =
            (old.postInstall or "")
            + ''
              while IFS= read -r icon; do
                case "$icon" in
                  *.svg)
                    install -m644 \
                      ${gajimIcon} \
                      "$icon"
                    ;;

                  *.png)
                    ${lib.getExe pkgs.imagemagick} \
                      -background none \
                      ${gajimIcon} \
                      -alpha set \
                      -resize 32x32 \
                      "$icon"
                    ;;
                esac
              done < <(
                find "$out" \
                  -type f \
                  \( -name 'gajim-status-*.svg' -o -name 'gajim-status-*.png' \)
              )
            '';
        });
      in
        wrappers {
          inherit pkgs;

          package = gajim;
          exePath = "${gajim}/bin/gajim";
          binName = "gajim";
        };
    };

    config = {
      home.packages = [
        config.gajim.package
      ];

      xdg.desktopEntries.gajim = {
        name = "Gajim";
        genericName = "XMPP Client";
        comment = "Chat securely with XMPP";
        icon = "org.gajim.Gajim";
        exec = lib.getExe config.gajim.package;
        terminal = false;
        categories = [
          "Network"
          "InstantMessaging"
        ];
      };
    };
  };
}
