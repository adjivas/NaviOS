{pkgs, ...}: {
  system.stateVersion = "26.05";

  fonts.packages = [pkgs.adwaita-fonts pkgs.dejavu_fonts];
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.firefox.preferences = {
    "media.webrtc.camera.allow-pipewire" = true;
    "browser.startup.homepage" = "https://mozilla.github.io/webrtc-landing/gum_test.html";
    "datareporting.policy.firstRunURL" = "https://mozilla.github.io/webrtc-landing/gum_test.html";
  };
  environment.systemPackages = [
    pkgs.fastfetch
    pkgs.htop
    pkgs.wayland-utils
    pkgs.weston
    pkgs.waycheck
    pkgs.vulkan-tools
    pkgs.glmark2
    pkgs.mesa-demos
    pkgs.xorg.xeyes
    pkgs.xterm
    pkgs.vkquake
    # pkgs.veloren
    pkgs.kdePackages.kate
    pkgs.adwaita-icon-theme
    pkgs.amberol
    pkgs.bustle
    pkgs.d-spy
    pkgs.gnome-text-editor
    pkgs.ffmpeg-full
    pkgs.mpv
    pkgs.libva-utils
    pkgs.pipewire # cli
    pkgs.tailscale
    pkgs.zerotierone
    pkgs.localsend
    pkgs.ashpd-demo
    pkgs.nautilus
    pkgs.rewaita
    pkgs.wl-clipboard-rs
    pkgs.snapshot
    pkgs.pavucontrol
    pkgs.gst_all_1.gst-plugins-base
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gstreamer
  ];
}
