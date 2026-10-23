{
  mesa,
  lib,
  stdenv,
}:
(mesa.override {
  # nothing currently
}).overrideAttrs (_: old: {
  mesonFlags =
    old.mesonFlags
    ++ lib.optionals stdenv.hostPlatform.isx86_64 [(lib.mesonBool "amdgpu-virtio" true)];
  # not that amdgpu can't be found on aarch64 but let's avoid rebuilds for now
  # patches = old.patches ++ [ ];
})
