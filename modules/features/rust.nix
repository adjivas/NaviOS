{
  den.aspects.rust.homeManager = {
    fenix,
    pkgs,
    ...
  }: {
    config = {
      home.packages = [
        (with fenix;
          combine [
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
  };
}
