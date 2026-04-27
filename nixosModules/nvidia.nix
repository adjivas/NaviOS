{ pkgs, lib, config, ... }: {
  options = {
    nvidia.enable = lib.mkEnableOption "enable nvidia";
    nvidia.nvidiaBusId = lib.mkOption {
      type = lib.types.str;
    };
    nvidia.intelBusId = lib.mkOption {
      type = lib.types.str;
    };
    nvidia.package = lib.mkOption {
      type = lib.types.package;
      default = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
  config = lib.mkIf config.nvidia.enable {
    services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;
    
      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      prime = { 
         offload.enable = true;
         offload.enableOffloadCmd = true;

         # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA 
         nvidiaBusId = config.nvidia.nvidiaBusId; 

         # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA 
         intelBusId = config.nvidia.intelBusId; 
       };

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.nvidia.package;
    };
  };
}
