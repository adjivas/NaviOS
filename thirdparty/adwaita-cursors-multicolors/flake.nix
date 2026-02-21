{
  description = "Adwaita cursors recolored (multi-colors) and recompiled with xcursorgen";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    adwaita-src = {
      url = "git+https://gitlab.gnome.org/GNOME/adwaita-icon-theme.git";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, adwaita-src, ... }: flake-parts.lib.mkFlake {
    inherit inputs;
  } {
    systems = [ "x86_64-linux" "aarch64-linux" ];

    perSystem = { self', pkgs, ... }: {
      packages.adwaita-cursors-multicolors = pkgs.stdenvNoCC.mkDerivation {
        pname = "adwaita-cursors-multicolors";
        version = "git";

        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          xorg.xcursorgen
          xcur2png
        ];

        buildPhase = ''
          runHook preBuild

          src="${adwaita-src}"
          cursorSrc="$src/Adwaita/cursors"
          pngsSrc="$src/src/cursors/pngs"

          work="work"
          ${pkgs.coreutils}/bin/mkdir -p "$work"

          workDir="$work/Adwaita/cursors"
          ${pkgs.coreutils}/bin/mkdir -p "$workDir"

          workGen="$work/src/cursors"
          ${pkgs.coreutils}/bin/mkdir -p $workGen
          cp -r $src/src/cursors/pngs $workGen
          cp $src/src/cursors/cursorgen.py $workGen

          chmod -R u+w $workGen

          set -- red blue green orange purple cyan magenta yellow
          while [ "$#" -gt 0 ]; do
            color="$1"; shift
            (
              mapfile -d "" -t curFiles < <(${pkgs.findutils}/bin/find "$cursorSrc" -type f -name '*.cur' -print0)

              set -- "''${curFiles[@]}"
              while [ "$#" -gt 0 ]; do
                file="$1"; shift
                base="$(${pkgs.coreutils}/bin/basename "$file")"
                ${pkgs.imagemagick}/bin/magick "$file"\[1\] -alpha on -channel RGB -fuzz 10% -fill $color -opaque black "CUR:$workDir/$base"
              done

              cp -rf $src/src/cursors/pngs $workGen
              mapfile -d "" -t pngFiles < <(${pkgs.findutils}/bin/find $src/src/cursors/pngs -type f -name '*.png' -print0)
              set -- "''${pngFiles[@]}"
              while [ "$#" -gt 0 ]; do
                file="$1"; shift
                target="$workGen''${file##*/src/cursors}"
                ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname $target);
                ${pkgs.imagemagick}/bin/magick "$file"\[1\] -alpha on -channel RGB -fuzz 30% -fill $color -opaque black "PNG:$target"
              done

              cd $workGen
              ${pkgs.python3}/bin/python cursorgen.py
              cd -
              cp -r $workDir ''${color}Adwaita
            )
          done

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          set -- red blue green orange purple cyan magenta yellow
          while [ "$#" -gt 0 ]; do
            export color="$1"; shift

            outDir="$out/share/icons/''${color}Adwaita"
            ${pkgs.coreutils}/bin/mkdir -p "$outDir"

            cp -r ''${color}Adwaita $outDir/cursors

            ${pkgs.coreutils}/bin/ln -s "$outDir/cursors/default" "$outDir/cursors/left_ptr"

            ${pkgs.envsubst}/bin/envsubst '$color' > "$outDir/index.theme" <<'EOF'
[Icon Theme]
Name=''${color}Adwaita
Comment=$color recolor of Adwaita cursors
Inherits=Adwaita
EOF
          done

          runHook postInstall
        '';
      };

      # nix build .#adwaita-cursors-multicolors
      packages.default = self.packages.${pkgs.stdenv.hostPlatform.system}.adwaita-cursors-multicolors;
    };
  };
}
