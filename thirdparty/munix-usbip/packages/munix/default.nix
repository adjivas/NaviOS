{
  stdenv,
  writeScriptBin,
  symlinkJoin,
  makeWrapper,
  muvm,
  passt,
  bubblewrap,
  jq,
  util-linux,
  sidebus-broker,
  wl-cross-domain-proxy,
  wl-backdrop,
  mesa,
  rustc,
}: let
  munixScript = (writeScriptBin "munix" (builtins.readFile ../../munix)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  munixSystemd = stdenv.mkDerivation {
    name = "munix-systemd";
    src = ../../systemd;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      cp -aR $src/* $out
    '';
  };
  microActivate = stdenv.mkDerivation {
    name = "micro-activate";
    src = ../../micro-activate.rs;
    dontUnpack = true;
    nativeBuildInputs = [rustc];
    buildPhase = ''
      rustc -C opt-level=s -C panic=abort --edition 2024 -o micro-activate $src
    '';
    installPhase = ''
      mkdir -p $out/bin
      mv micro-activate $out/bin
    '';
  };
in
  symlinkJoin {
    name = "munix";
    paths = [munixScript microActivate muvm passt bubblewrap jq util-linux sidebus-broker wl-cross-domain-proxy wl-backdrop];
    buildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/munix --prefix PATH : $out/bin --set FALLBACK_OPENGL_DRIVER ${mesa} --set MUNIX_SYSTEMD_UNITS ${munixSystemd}
    '';
  }
