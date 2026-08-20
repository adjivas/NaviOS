{
  den.aspects.htop.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.htop = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.htop-vim;
        description = "htop packages";
      };
    };
    config = {
      programs.htop = {
        enable = true;
        package = config.htop.package;
        settings = {
          tree_view = 1;
          hide_userland_threads = 1;
          highlight_changes = 1;
          show_cpu_frequency = 1;
          show_cpu_temperature = 1;
          show_program_path = 0;
          highlight_base_name = 1;
        };
      };
    };
  };
}
