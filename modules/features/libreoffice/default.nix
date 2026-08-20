{
  den.aspects.libreoffice.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.libreoffice = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.libreoffice-fresh;
      };

      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
      };
    };

    config = let
      texlive = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-small dvisvgm dvipng;
      };
      libreofficeWrapped = pkgs.writeShellScriptBin "libreoffice" ''
        export PATH="${lib.makeBinPath [texlive]}:$PATH"
        export GTK_THEME=Adwaita:dark

        export OCL_ICD_VENDORS="${pkgs.mesa.opencl}/etc/OpenCL/vendors"
        export LD_LIBRARY_PATH="${lib.makeLibraryPath [pkgs.ocl-icd]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

        exec ${config.libreoffice.package}/bin/libreoffice --nologo "$@"
      '';
    in {
      home.packages = [
        libreofficeWrapped
      ];

      home.activation.libreofficeExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${lib.concatMapStringsSep "\n" (extension: ''
            run ${config.libreoffice.package}/bin/unopkg add --force \
              ${lib.escapeShellArg (toString extension)}
          '')
          config.libreoffice.extensions}
      '';

      home.file.".config/libreoffice/4/user/registrymodifications.xcu".source = ./registrymodifications.xcu.xml;

      home.file.".config/libreoffice/4/user/config/javasettings_Linux_X86_64.xml".source = ./javasettings_Linux_X86_64.xml;

      xdg.desktopEntries.writer = {
        name = "LibreOffice Writer";
        genericName = "Word Processor";
        exec = "libreoffice --writer %U";
        icon = "libreoffice-writer";
        terminal = false;
        categories = ["Office" "WordProcessor"];
        mimeType = [
          "text/plain"
        ];
      };

      xdg.desktopEntries.calc = {
        name = "LibreOffice Calc";
        genericName = "Spreadsheet";
        exec = "libreoffice --calc %U";
        icon = "libreoffice-calc";
        terminal = false;
        categories = ["Office" "Spreadsheet"];
        mimeType = [
          "text/csv"
        ];
      };
    };
  };
}
