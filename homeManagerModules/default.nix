{ lib, ... }: {
  imports = [
    ./stylix.nix

    ./services/kanshi.nix
    ./services/mako.nix
    ./services/gnome-keyring.nix
    ./services/wlsunset.nix

    ./programs/nvf.nix
    ./programs/sway.nix
    ./programs/swaylock.nix
    ./programs/waybar.nix
    ./programs/bemenu.nix
    ./programs/rofi.nix
    ./programs/newsboat.nix
    ./programs/virt-manager.nix
    ./programs/inkscape.nix
    ./programs/gnome-control-center.nix
    ./programs/telegram.nix
    ./programs/thunderbird.nix
    ./programs/libreoffice.nix
    ./programs/luanti.nix
    ./programs/sm64ex.nix
    ./programs/xonotic.nix
    ./programs/supertuxkart.nix
    ./programs/pcsx2.nix
    ./programs/rust.nix
    ./programs/wl-kbptr.nix
    ./programs/ssh.nix
    ./programs/firefox.nix
    ./programs/ripgrep.nix
    ./programs/kitty.nix
    ./programs/git.nix
    ./programs/fzf.nix
    ./programs/zathura.nix
    ./programs/bash.nix
    ./programs/starship.nix
    ./programs/htop.nix
    ./programs/dissent.nix
    ./programs/password-store.nix
    ./programs/mangohud.nix
    ./programs/lan-mouse.nix
  ];

  kanshi.enable = lib.mkDefault false;
  mako.enable = lib.mkDefault false;
  wlsunset.enable = lib.mkDefault false;
  gnome-keyring.enable = lib.mkDefault false;

  nvf.enable = lib.mkDefault false;
  sway.enable = lib.mkDefault false;
  swaylock.enable = lib.mkDefault false;
  waybar.enable = lib.mkDefault false;
  bemenu.enable = lib.mkDefault false;
  rofi.enable = lib.mkDefault false;
  newsboat.enable = lib.mkDefault false;
  virt-manager.enable = lib.mkDefault false;
  inkscape.enable = lib.mkDefault false;
  gnome-control-center.enable = lib.mkDefault false;
  telegram.enable = lib.mkDefault false;
  thunderbird.enable = lib.mkDefault false;
  libreoffice.enable = lib.mkDefault false;
  luanti.enable = lib.mkDefault false;
  sm64ex.enable = lib.mkDefault false;
  xonotic.enable = lib.mkDefault false;
  supertuxkart.enable = lib.mkDefault false;
  rust.enable = lib.mkDefault false;
  wl-kbptr.enable = lib.mkDefault false;
  firefox.enable = lib.mkDefault false;
  ripgrep.enable = lib.mkDefault false;
  kitty.enable = lib.mkDefault false;
  git.enable = lib.mkDefault false;
  fzf.enable = lib.mkDefault false;
  zathura.enable = lib.mkDefault false;
  ssh.enable = lib.mkDefault false;
  bash.enable = lib.mkDefault false;
  starship.enable = lib.mkDefault false;
  htop.enable = lib.mkDefault false;
  dissent.enable = lib.mkDefault false;
  password-store.enable = lib.mkDefault false;
  mangohud.enable = lib.mkDefault false;
  lan-mouse.enable = lib.mkDefault false;
}
