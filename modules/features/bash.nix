{
  den.aspects.bash.homeManager = {
    config = {
      programs.bash = {
        enable = true;

        bashrcExtra = ''
          shopt -s autocd
        '';
      };
    };
  };
}
