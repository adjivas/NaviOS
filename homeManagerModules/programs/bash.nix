{ pkgs, lib, config, ... }: {
  options = {
    bash.enable = lib.mkEnableOption "enable bash";
  };
  config = lib.mkIf config.bash.enable {
    programs.bash = {
      enable = true;
      # initExtra = ''
      #   if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      #     exec dbus-run-session sway &
      #   fi
      # '';
      # bashrcExtra = ''
      #   source "${pkgs.git}/share/bash-completion/completions/git-prompt.sh";
      #   export PS1="\u@\h:\W\$(__git_ps1 '(%s)') % ";
      # '';
    };
  };
}
