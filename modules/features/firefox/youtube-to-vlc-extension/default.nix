{
  den,
  inputs,
  ...
}: {
  den.aspects.firefox-youtube-to-vlc = {
    includes = [
      den.aspects.vlc
    ];

    homeManager = {pkgs, ...}: let
      yt-dlp = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.yt-dlp;
    in {
      xdg.dataFile."vlc/lua/playlist/youtube.lua".source = ./youtube.lua;
      vlc.runtimeInputs = [
        pkgs.ffmpeg
        yt-dlp
      ];
      home.packages = [
        yt-dlp
      ];

      firefox = let
        extension =
          pkgs.runCommandLocal "youtube-to-vlc.xpi" {
            nativeBuildInputs = with pkgs; [
              jq
              zip
            ];
          } ''
            cp ${./manifest.json} manifest.json
            cp ${./background.js} background.js

            jq empty manifest.json
            zip "$out" manifest.json background.js
          '';
        host = pkgs.writeShellApplication {
          name = "youtube-to-vlc-host";
          runtimeInputs = with pkgs; [
            python3
            vlc
          ];
          text = ''exec ${./youtube-to-vlc-host.py} "$@"'';
        };
      in {
        policies.ExtensionSettings."youtube-to-vlc@dreamland.local" = {
          installation_mode = "force_installed";
          install_url = "file://${extension}";
          private_browsing = true;
          temporarily_allow_weak_signatures = false;
        };
        nativeMessagingHosts = [
          (pkgs.writeTextFile {
            name = "youtube-to-vlc-native-messaging-host";
            destination = "/lib/mozilla/native-messaging-hosts/local.youtube_to_vlc.json";
            text = builtins.toJSON {
              name = "local.youtube_to_vlc";
              description = "Open a YouTube video in VLC";

              path = "${host}/bin/youtube-to-vlc-host";
              type = "stdio";

              allowed_extensions = [
                "youtube-to-vlc@dreamland.local"
              ];
            };
          })
        ];
      };
    };
  };
}
