{ lib, config, ... }: {
  options = {
    starship.enable = lib.mkEnableOption "enable starship";
    starship.color = lib.mkOption {
      type = lib.types.str;
      default = "cyan";
    };
  };
  config = lib.mkIf config.starship.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;

      settings = {
        # This line replaces add_newline = false
        add_newline = false;
        format = "$username$hostname$directory$shell$shlvl$git_branch$nix_shell$git_commit$git_state$git_status$cmd_duration$jobs$status$character";

        cmd_duration = {
          disabled = false;
          min_time = 10000;
          format = "$duration";
          style = "bold yellow";
        };

        shlvl = {
          disabled = false;
          symbol = "$SHLVL:";
        };

        status = {
          format = "[$symbol$status]($style)";
          symbol = "";
          style = "bold red";
          pipestatus = true;
          map_symbol = true;
        };

        directory = {
          disabled = false;
        };

        git_branch = {
          format = "\\([$branch]($style)\\) ";
          style = "fg:${config.starship.color}";
        };

        git_status = {
          disabled = true;
        };

        hostname = {
          ssh_only = false;
          style = "fg:${config.starship.color}";
          format = "[$hostname]($style):";
        };

        line_break = {
          disabled = true;
        };

        nix_shell = {
          disabled = true;
        };

        time = {
          disabled = true;
        };

        jobs = {
          disabled = true;
        };

        username = {
          disabled = false;
          style_user = "fg:${config.starship.color}";
          format = "[$user]($style)@";
          show_always = true;
        };

        character = {
          success_symbol = "%";
          error_symbol = "!";
        };
      };
    };
  };
}
