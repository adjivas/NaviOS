{
  den.aspects.switch.homeManager = {
    lib,
    pkgs,
    config,
    osConfig,
    ...
  }: {
    options.switch = {
      flake = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/Repositories/NaviOS";
      };
      evalWorkers = lib.mkOption {
        type = lib.types.int;
        default = 2;
      };
      evalMaxMemorySize = lib.mkOption {
        type = lib.types.int;
        default = 8192;
      };
    };
    config = let
      hostname = osConfig.networking.hostName;
      machine = "${config.switch.flake}#nixosConfigurations.${hostname}.config.system.build.toplevel";

      substituters = osConfig.nix.cache.client.substituters or [];
      extraSubstituters = osConfig.nix.cache.client.extraSubstituters or [];

      substitutersList = lib.escapeShellArgs (substituters ++ extraSubstituters);

      availableSubstitutersScript = pkgs.writeShellScript "available-substituters" ''
        set -euo pipefail

        available_substituters=()

        for substituter in "$@"; do
          url="''${substituter%%\?*}"
          url="''${url%/}"

          if ${pkgs.curl}/bin/curl -fsS --connect-timeout 10 "$url/nix-cache-info" >/dev/null 2>&1; then
            available_substituters+=("$substituter")
          fi
        done

        printf '%s ' "''${available_substituters[@]}"
      '';
    in {
      home.packages = [
        (pkgs.writeShellScriptBin "profile" ''
          set -euo pipefail

          substituters_arg="$(${availableSubstitutersScript} ${substitutersList})"
          if ! ${pkgs.nix-output-monitor}/bin/nom build "${machine}" \
            --fallback \
            --option connect-timeout 5 \
            --option stalled-download-timeout 20 \
            --option substituters "$substituters_arg" \
            --eval-profiler flamegraph \
            --eval-profile-file /tmp/dream00-eval.profile \
            --eval-profiler-frequency 99 \
            "$@"; then
            echo -e "\a" >&2
            exit 1
          fi

          ${pkgs.flamegraph}/bin/flamegraph -c flamegraph.pl /tmp/dream00-eval.profile > /tmp/dream00-flamegraph.svg
          echo -e "\a"
        '')
        (pkgs.writeShellScriptBin "switch" ''
          set -euo pipefail

          substituters_arg="$(${availableSubstitutersScript} ${substitutersList})"
          if ! ${pkgs.nix-output-monitor}/bin/nom build "${machine}" \
            --fallback \
            --option connect-timeout 5 \
            --option stalled-download-timeout 20 \
            --option substituters "$substituters_arg" \
            "$@"; then
            echo -e "\a" >&2
            exit 1
          fi

          echo -e "\a"
          echo "Press Enter to switch"
          read
          sudo ./result/bin/switch-to-configuration switch
        '')
        (pkgs.writeShellScriptBin "switch-fast-build" ''
          set -euo pipefail

          export TMPDIR="/nix/persistent/tmp"
          mkdir -p $TMPDIR

          substituters_arg="$(${availableSubstitutersScript} ${substitutersList})"
          if ! ${pkgs.nix-fast-build}/bin/nix-fast-build \
            --flake "${machine}" \
            --option connect-timeout 5 \
            --option stalled-download-timeout 20 \
            --option substituters "$substituters_arg" \
            --option fallback true \
            --eval-workers ${toString config.switch.evalWorkers} \
            --eval-max-memory-size ${toString config.switch.evalMaxMemorySize} \
            --no-nom \
            "$@" |& ${pkgs.nix-output-monitor}/bin/nom; then
            echo -e "\a" >&2
            exit 1
          fi
          SYS="$(readlink -f ./result-)"

          echo -e "\a"
          echo "Press Enter to switch"
          read
          sudo nix-env -p /nix/var/nix/profiles/system --set "$SYS"
          sudo $SYS/bin/switch-to-configuration switch
        '')
        (pkgs.writeShellScriptBin "switch-parallel-build" ''
          set -euo pipefail

          export TMPDIR="/nix/persistent/tmp"
          mkdir -p $TMPDIR

          substituters_arg="$(${availableSubstitutersScript} ${substitutersList})"
          if ! ${pkgs.nix-output-monitor}/bin/nom build \
            "${machine}" \
            --option connect-timeout 5 \
            --option stalled-download-timeout 20 \
            --option substituters "$substituters_arg" \
            --option fallback true \
            --option lazy-trees true \
            --option eval-cores ${toString config.switch.evalWorkers} \
            --option extra-experimental-features "parallel-eval" \
          "$@"; then
            echo -e "\a" >&2
            exit 1
          fi
          SYS="$(readlink -f ./result)"

          echo -e "\a"
          echo "Press Enter to switch"
          read
          sudo nix-env -p /nix/var/nix/profiles/system --set "$SYS"
          sudo $SYS/bin/switch-to-configuration switch
        '')
      ];
    };
  };
}
