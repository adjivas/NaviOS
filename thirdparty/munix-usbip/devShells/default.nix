{
  mkShell,
  lib,
  systemd,
  cargo,
  rust-analyzer,
  rustfmt,
  passt,
  bubblewrap,
  libkrun,
  muvm,
  sidebus-broker,
  wl-cross-domain-proxy,
  wl-backdrop,
  pkgs,
}: let
  projects = [
    libkrun
    muvm
  ];
in
  mkShell {
    MUVM_UDEVD_PATH = "${systemd}/lib/systemd/systemd-udevd";
    nativeBuildInputs = lib.concatMap (pkg: pkg.nativeBuildInputs) projects;
    buildInputs =
      (lib.concatMap (pkg: pkg.buildInputs) projects)
      ++ [
        # virglrenderer
        cargo
        rust-analyzer
        rustfmt
        passt
        bubblewrap
        sidebus-broker
        wl-cross-domain-proxy
        wl-backdrop
      ]
      ++ (with pkgs; [
        meson
        wayland
        wayland-protocols
        wayland-scanner
        cairo
        libgbm
        util-linux
        jq
      ]);
    # Enough things to compile wl-cross-domain-proxy, muvm, etc. in development
  }
