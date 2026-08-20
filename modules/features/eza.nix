{
  den.aspects.eza.homeManager = {
    config = {
      programs.eza = {
        enable = true;
        enableBashIntegration = true;
        git = true;
        icons = "auto";

        extraOptions = [
          "--group-directories-first"
          "--no-quotes"
          "--header"
          "--git"
          "--icons=auto"
          "--classify"
        ];
      };
    };
  };
}
