{
  lib,
  rustPlatform,
  # fetchpatch,
  fetchFromGitea,
  pkg-config,
  libdrm,
}:
# TODO: upstream
rustPlatform.buildRustPackage {
  pname = "wl-cross-domain-proxy";
  version = "0-unstable-2026-01-30";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "drakulix";
    repo = "wl-cross-domain-proxy";
    rev = "c6ce1ca89fb4d6f4f18d3aaf88324d40d4589177";
    hash = "sha256-ydyT4DFzWzhzOZR591UOgLjVQt/v6hRSNjzM3QtohlU=";
  };

  nativeBuildInputs = [pkg-config];

  buildInputs = [libdrm];

  cargoHash = "sha256-k3dmxIuCQoOrn/VwauTdzuRw/XKQB6LPLgO5ql0rE7E=";
  cargoPatches = [
    # (fetchpatch {
    #   name = "XXX.patch";
    #   url = "https://codeberg.org/drakulix/wl-cross-domain-proxy/pulls/XXX.patch";
    #   hash = lib.fakeHash;
    # })
  ];

  meta = {
    homepage = "https://codeberg.org/drakulix/wl-cross-domain-proxy";
    description = "Proxy for the wayland protocol across virtio-gpu cross-domain context";
    mainProgram = "wl-cross-domain-proxy";
    platforms = lib.platforms.linux;
    license = [lib.licenses.mit];
    maintainers = [lib.maintainers.valpackett];
  };
}
