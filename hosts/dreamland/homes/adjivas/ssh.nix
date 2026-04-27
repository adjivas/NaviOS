{ self, lib, config, ... }: {
  programs.ssh.matchBlocks = {
    "*" = {
      identityFile = [
        "${config.home.homeDirectory}/.ssh/yubikey-5a-adjivas"
        "${config.home.homeDirectory}/.ssh/yubikey-5c-adjivas"
      ];
      extraOptions = {
        AddKeysToAgent = "yes";
      };
    };
  };
}
