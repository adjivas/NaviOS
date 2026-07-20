{
  lib,
  pkgs,
  rustPlatform,
  fetchNpmDeps,
  fetchFromGitHub,
  pkg-config,
  cmake,
  openssl,
  nodejs,
  npmHooks,
}:
rustPlatform.buildRustPackage rec {
  pname = "moonlight-web-stream";
  version = "2.8";

  src = fetchFromGitHub {
    owner = "MrCreativ3001";
    repo = "moonlight-web-stream";
    rev = "v${version}";
    hash = "sha256-NNGE8r+KWROQoBZpTpef09NOnkbWIt9DwRxU1vBpYLo=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-v98g6sXJgjNYtaXjz7iV4HYLVnpiA8y5TAeRQ/PF6KI=";

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-hT/RM9vdq5CYmZJm0kW0OUos/6uhCvxA8uVxkgFHqZI=";
  };

  npmRoot = ".";

  nativeBuildInputs = [
    pkg-config
    cmake
    nodejs
    npmHooks.npmConfigHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
  ];

  OPENSSL_ROOT_DIR = "${openssl.dev}";
  OPENSSL_INCLUDE_DIR = "${openssl.dev}/include";
  OPENSSL_LIB_DIR = "${openssl.out}/lib";
  OPENSSL_NO_VENDOR = "1";

  cargoBuildFlags = [
    "--package"
    "web-server"
    "--package"
    "streamer"
  ];

  postPatch = ''
      substituteInPlace Cargo.toml \
        --replace-fail 'sha2 = "0.10.9"' 'sha2 = "0.10.9"
    rustls = { version = "0.23", default-features = false, features = ["std", "ring"] }'

      ${pkgs.perl}/bin/perl -0pi -e 's/#\[actix_web::main\]\s*async\s+fn\s+main\(\)\s*\{/#\[actix_web::main\] async fn main() {\n    rustls::crypto::ring::default_provider()\n        .install_default()\n        .expect("failed to install rustls ring crypto provider");/s' src/main.rs

      ${pkgs.gnugrep}/bin/grep -q 'install_default' src/main.rs
  '';

  preBuild = ''
    npm run build
  '';

  postInstall = ''
    mkdir -p $out/bin

    if [ -f target/release/web-server ]; then
      cp target/release/web-server $out/bin/
      chmod +x $out/bin/web-server
    fi
    if [ -f target/release/streamer ]; then
      cp target/release/streamer $out/bin/
      chmod +x $out/bin/streamer
    fi

    mkdir -p $out/share/moonlight-web-stream/static
    cp -r dist/* $out/share/moonlight-web-stream/static/
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath [openssl]} $out/bin/web-server
    patchelf --add-rpath ${lib.makeLibraryPath [openssl]} $out/bin/streamer
  '';

  meta = {
    description = "Web server that streams Sunshine to a browser";
    homepage = "https://github.com/MrCreativ3001/moonlight-web-stream";
    license = lib.licenses.gpl3Plus;
    mainProgram = "web-server";
    platforms = lib.platforms.linux;
  };
}
