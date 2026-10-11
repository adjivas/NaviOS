{
  muvm,
  libkrun,
  muvm-src,
  systemd,
  rustPlatform,
}:
(muvm.override {
  libkrun = libkrun;
  fex = "/nonexistent"; # do not pull the x86 emulator on arm64
}).overrideAttrs (_: {
  postPatch = ""; # no more sysctl; udevd now takes the var anyway; XXX: fex
  MUVM_UDEVD_PATH = "${systemd}/lib/systemd/systemd-udevd";
  src = muvm-src;
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${muvm-src}/Cargo.lock";
  };
})
