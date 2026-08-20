{
  libkrun,
  libkrunfw,
  libkrun-src,
  rustPlatform,
  libcap_ng,
  variant ? null,
  ...
}: let
  libkrunfw' = libkrunfw.override {inherit variant;};
  libkrun' = libkrun.override {
    withBlk = true;
    withNet = true;
    withGpu = true;
    # --- stick to the override used in nixpkgs' muvm package to reuse nixos.org cache when not overriding src ---
    # withSound = true; # not for pipewire forwarding, anyway
    # withTimesync = true; # why not?..
    # ---------
    inherit variant;
    libkrunfw = libkrunfw';
  };
in
  # libkrun'
  libkrun'.overrideAttrs (old: {
    src = libkrun-src;
    cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${libkrun-src}/Cargo.lock";
      outputHashes = {
        "mesa3d_util-0.1.76" = "sha256-oe022WxNFGbJVkD6bmg3UOvZ4wSZu9y6xQoYUOx65gY=";
      };
    };
    buildInputs = old.buildInputs ++ [libcap_ng]; # new dep
  })
