{
  libkrunfw,
  variant ? null,
  ...
}: let
  libkrunfw' = libkrunfw.override {
    inherit variant;
  };

  configName =
    if variant == null
    then "config-libkrunfw_x86_64"
    else "config-libkrunfw-${variant}_x86_64";
in
  libkrunfw'.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        configFile="${configName}"

        if [ ! -f "$configFile" ]; then
          echo "Kernel configuration not found: $configFile" >&2
          exit 1
        fi

        setKernelConfig() {
          symbol="$1"
          value="$2"

          sed -i \
            -e "/^''${symbol}=/d" \
            -e "/^# ''${symbol} is not set$/d" \
            "$configFile"

          echo "''${symbol}=''${value}" >> "$configFile"
        }

        # USB.
        setKernelConfig CONFIG_USB_SUPPORT y
        setKernelConfig CONFIG_USB_COMMON y
        setKernelConfig CONFIG_USB y

        # USB/IP client.
        setKernelConfig CONFIG_USBIP_CORE y
        setKernelConfig CONFIG_USBIP_VHCI_HCD y

        # Input.
        setKernelConfig CONFIG_INPUT y
        setKernelConfig CONFIG_INPUT_EVDEV y
        setKernelConfig CONFIG_INPUT_JOYDEV y
        setKernelConfig CONFIG_INPUT_FF_MEMLESS y

        # HID.
        setKernelConfig CONFIG_HID y
        setKernelConfig CONFIG_HID_GENERIC y
        setKernelConfig CONFIG_HIDRAW y
        setKernelConfig CONFIG_USB_HID y
        setKernelConfig CONFIG_HID_PLAYSTATION y
        setKernelConfig CONFIG_HID_SONY y

        # Inspection depuis le guest.
        setKernelConfig CONFIG_IKCONFIG y
        setKernelConfig CONFIG_IKCONFIG_PROC y
      '';

    postBuild =
      (old.postBuild or "")
      + ''
        kernelConfig="$(find . -type f -name .config -print -quit)"

        if [ -z "$kernelConfig" ]; then
          echo "Final kernel .config not found" >&2
          exit 1
        fi

        echo "Final kernel configuration: $kernelConfig"

        grep -E \
          'CONFIG_(USB_SUPPORT|USB=|USB_COMMON|USBIP|USB_HID|HID_PLAYSTATION|HID_SONY|INPUT_EVDEV|IKCONFIG)' \
          "$kernelConfig" || true

        grep -q '^CONFIG_USB_SUPPORT=y$' "$kernelConfig"
        grep -q '^CONFIG_USB=y$' "$kernelConfig"
        grep -q '^CONFIG_USBIP_CORE=y$' "$kernelConfig"
        grep -q '^CONFIG_USBIP_VHCI_HCD=y$' "$kernelConfig"
        grep -q '^CONFIG_INPUT_EVDEV=y$' "$kernelConfig"
        grep -q '^CONFIG_USB_HID=y$' "$kernelConfig"

        echo "USB/IP and VHCI successfully enabled"
      '';
  })
