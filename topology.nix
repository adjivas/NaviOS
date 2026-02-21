{ config, lib, ... }:
let
  inherit (config.lib.topology) mkInternet mkRouter mkConnection;
in {
}
