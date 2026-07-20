{
  den.aspects.alice.homeManager = {
    lib,
    pkgs,
    baserom,
    sm64mods,
    ...
  }: let
    sm64modsUnpacked =
      pkgs.runCommand "sm64mods-unpacked" {
        nativeBuildInputs = [pkgs.unzip];
      } ''
        mkdir -p "$out"

        ${builtins.concatStringsSep "\n" (map (mod: ''
            unzip -oq "${mod.src}" -d "$out"
          '')
          sm64mods)}
      '';
  in {
    home.activation.installSm64mods = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p .local/share/sm64coopdx

      cp -r ${sm64modsUnpacked} "$HOME/.local/share/sm64coopdx/mods"
      chmod -R u+rwX,go+rX "$HOME/.local/share/sm64coopdx/mods"
    '';

    sm64ex.baserom = baserom;
    cage.startScript = "${pkgs.sm64coopdx}/bin/sm64coopdx";
  };
}
