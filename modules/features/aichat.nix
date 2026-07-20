{
  den.aspects.agent.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.agent = {
      openaiTokenPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to the OpenAI API token file.";
      };
    };
    config = {
      home.packages = [
        (pkgs.writeShellScriptBin "ai" ''
          export OPENAI_API_KEY="$(${pkgs.coreutils}/bin/cat ${config.agent.openaiTokenPath})"
          exec ${pkgs.aichat}/bin/aichat "$@"
        '')
      ];
      programs.aichat = {
        enable = true;

        settings = {
          model = "openai:gpt-5.5";

          stream = true;
          save = true;

          wrap = 100;
          wrap_code = false;

          clients = [
            {
              type = "openai";
            }
          ];
        };

        agents = {
          nix = {
            model = "openai:gpt-5.5";

            instructions = ''
              You are a french NixOS and DEN expert.
              Prefer declarative and reproducible solutions.
            '';
          };

          aichatSyncModels = lib.hm.dag.entryAfter ["writeBoundary"] ''
            aichat="${pkgs.aichat}/bin/aichat"
            model="${config.programs.aichat.settings.model}"

            export OPENAI_API_KEY="$(${pkgs.coreutils}/bin/cat "${config.agent.openaiTokenPath}")"

            if ! "$aichat" --list-models 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qF "''${model}";
            then
              printf "aichat: model %s not found in local model list, syncing...\n" "''${model}"
              "$aichat" --sync-models || true
            fi
          '';
        };
      };
    };
  };
}
