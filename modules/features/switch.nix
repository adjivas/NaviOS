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
      mobileMachine = "${config.switch.flake}#nixosConfigurations.dream05.config.system.build.toplevel";

      nix-output-monitor = pkgs.nix-output-monitor.override {
        extraComposeFunctions = [
          (pkgs.haskell.lib.compose.appendPatch (
            pkgs.fetchpatch2 {
              url = "https://github.com/maralorn/nix-output-monitor/commit/3c2ae037013e840046ed9785c4da82aa1c628872.patch";
              relative = "nix-output-monitor";
              hash = "sha256-kwmbXQZI+UyOVCAngr6cYpwqIbbG48MJgHzFpCt138o=";
            }
          ))
        ];
      };

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
          if ! ${nix-output-monitor}/bin/nom build "${machine}" \
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
          if ! ${nix-output-monitor}/bin/nom build "${machine}" \
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
            "$@" |& ${nix-output-monitor}/bin/nom; then
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
        (pkgs.writeShellScriptBin "switch-mobile" ''
          set -euo pipefail

          BUILDER='ssh-ng://nix-builder@10.77.0.33:60022 aarch64-linux /run/agenix/dreamland-nix-builder 4 1 big-parallel - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUk5cHBWZnBaem5EQWpPaTBoVHJDaHNrZFZzbG5OWUpMNGUrTXN2KzFGL2IK'
          TARGET='adjivas@10.77.0.5'
          PORT=60022
          SIGNING_KEY=${lib.escapeShellArg config.age.secrets.dreamland-nix-trusted-key.path}

          if ! ${pkgs.nix}/bin/nix build \
            --print-build-logs \
            --builders "$BUILDER" \
            --max-jobs 0 \
            "${mobileMachine}" \
            "$@" |& ${nix-output-monitor}/bin/nom; then
            echo -e "\a" >&2
            exit 1
          fi

          RESULT="$(${pkgs.coreutils}/bin/readlink -f result)"

          ${pkgs.nix}/bin/nix store sign      --key-file "$SIGNING_KEY"      --recursive      "$RESULT"

          ${pkgs.nix}/bin/nix copy      --to "ssh-ng://$TARGET:$PORT"      "$RESULT"

          echo -e "\a"
          echo "Press Enter to switch"
          read

          ${pkgs.openssh}/bin/ssh -t      -p "$PORT"      "$TARGET"      "sudo nix-env --profile /nix/var/nix/profiles/system --set '$RESULT' &&
             sudo '$RESULT/bin/switch-to-configuration' switch &&
             echo '\nCurrent system: ' &&
             readlink -f /run/current-system"
        '')
      ];
    };
  };
}
