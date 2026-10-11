{
  den.aspects.dream05-power-button.nixos = {
    config,
    lib,
    ...
  }: {
    options.dream05-power-button = {
      shortPress = lib.mkOption {
        type = lib.types.enum ["ignore" "suspend" "poweroff"];
        default = "ignore";
        description = ''
          Action to perform on short power button press.

          Options:
          - "ignore": Do nothing.
          - "suspend": Suspend the system immediately.
          - "poweroff": Power off the system immediately.

          Default is "ignore", which lets GNOME handle it (turns off screen).
        '';
      };

      longPress = lib.mkOption {
        type = lib.types.enum ["ignore" "suspend" "poweroff"];
        default = "poweroff";
        description = ''
          Action to perform on long power button press.

          Options:
          - "ignore": Do nothing.
          - "suspend": Suspend the system.
          - "poweroff": Power off the system.

          Default is "poweroff" for emergency shutdown capability.
        '';
      };
    };

    config = {
      services.logind.settings.Login = {
        # Handle power button with custom behavior.
        HandlePowerKey = config.dream05-power-button.shortPress;
        HandlePowerKeyLongPress = config.dream05-power-button.longPress;
      };
    };
  };
}
