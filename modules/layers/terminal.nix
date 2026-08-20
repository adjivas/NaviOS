{den, ...}: {
  den.aspects.terminal = {
    includes = [
      den.aspects.bash
      den.aspects.fzf
      den.aspects.htop
      den.aspects.ripgrep
      den.aspects.starship
      den.aspects.nvf
      den.aspects.git
      den.aspects.ssh
      den.aspects.gpg
      den.aspects.eza
    ];
  };
}
