{ pkgs, luanti, lib, config, ... }: {
  options = {
    luanti.enable = lib.mkEnableOption "enable luanti";
  };
  config = lib.mkIf config.luanti.enable {
    nixpkgs.overlays = [ luanti ];
    home.packages = let
      luantiClientWithGames = (pkgs.luanti-client.withPackages {
        games = with pkgs.luantiPackages.games; [
          mineclone2
          mineclonia
          minetest_game
          nodecore
        ];
        mods = with pkgs.luantiPackages.mods; [
          i3
          animalia
          draconis
          logistica
        ];
        texturePacks = with pkgs.luantiPackages.texturePacks; [
          soothing32
          vilja_pix_2
        ];
        clientMods = with pkgs.luantiPackages.clientMods; [ ];
      });
      luasocket = pkgs.luajitPackages.luasocket;
      luantiWithSocket = pkgs.writeShellScriptBin "luanti" ''
        export LUA_PATH="${luasocket}/share/lua/5.1/?.lua;${luasocket}/share/lua/5.1/?/init.lua;''${LUA_PATH-}"
        export LUA_CPATH="${luasocket}/lib/lua/5.1/?.so;''${LUA_CPATH-}"
        exec ${luantiClientWithGames}/bin/luanti "$@"
      '';
    in [
      luantiWithSocket
    ];
    home.file.".minetest/minetest.conf".text = ''
      secure.enable_security = true
      secure.trusted_mods = foo
    '';
  };
}
