{ lib, config, pkgs, fenix, ... }: {
  options = {
    rust.enable = lib.mkEnableOption "enable rust";
  };
  config = lib.mkIf config.rust.enable {
    home.packages = [
      (with fenix; combine [
        stable.cargo
        stable.clippy
        stable.rust-src
        stable.rustc
        stable.rustfmt
        stable.llvm-tools-preview
        targets."wasm32-unknown-unknown".stable.rust-std
      ])
      pkgs.cargo-watch
    ];
  };
}
