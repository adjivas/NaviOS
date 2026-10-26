{
  den.aspects.blocky.nixos = {
    config,
    lib,
    ...
  }: {
    options.blocky = {
      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 53;
      };

      unboundAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.8";
      };

      nameservers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["127.0.0.1"];
      };

      denylists = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {
          pro = [
            "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/pro.txt"
          ];
          tif = [
            "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/tif.txt"
          ];
        };
      };
    };

    config = {
      # ![Ad blocking recursive DNS for NixOS](https://web.archive.org/web/20251221144354/https://casualcompute.com/posts/ad-blocking-recursive-dns-for-nixos)
      networking = {
        nameservers = lib.mkForce config.blocky.nameservers;
        networkmanager.dns = lib.mkDefault "none";
      };

      services.unbound = {
        enable = true;
        resolveLocalQueries = false;

        settings.server = {
          interface = [config.blocky.unboundAddress];

          prefetch = true;
          prefetch-key = true;

          hide-identity = true;
          hide-version = true;
        };
      };

      services.blocky = {
        enable = true;

        settings = {
          ports.dns = "${config.blocky.listenAddress}:${toString config.blocky.port}";

          upstreams.groups.default = [config.blocky.unboundAddress];

          blocking = {
            denylists = config.blocky.denylists;
            clientGroupsBlock.default = builtins.attrNames config.blocky.denylists;
          };

          caching = {
            prefetching = true;
            minTime = "1m";
          };
        };
      };

      systemd.services.blocky = {
        after = ["unbound.service"];
        requires = ["unbound.service"];
      };
    };
  };
}
