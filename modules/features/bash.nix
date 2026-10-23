{
  den.aspects.bash.homeManager = {
    config = {
      programs.bash = {
        enable = true;

        bashrcExtra = ''
          shopt -s autocd
        '';
        initExtra = ''
          cp() {
            if (( $# == 1 )); then
              command cp "$1" .
            else
              command cp "$@"
            fi
          }
          mv() {
            if (( $# == 1 )); then
              command mv "$1" .
            else
              command mv "$@"
            fi
          }
        '';
      };
    };
  };
}
