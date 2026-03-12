{ pkgs, lib, config, ... }: {
  options = {
    nvf.enable = lib.mkEnableOption "enable nvf";
    nvf.mouse = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
  config  = lib.mkIf config.nvf.enable {
    programs.nvf = {
      enable = true;
      enableManpages = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;

          extraPackages = with pkgs; [
            wl-clipboard
          ];
          options = {
            mouse = config.nvf.mouse;
            autoindent = true;
            expandtab = true;
            smartindent = true;
            tabstop = 2;
            shiftwidth = 2;
            softtabstop = 2;
            number = true;
            relativenumber = false;
            swapfile = false;
          };

          globals.mapleader = " "; # Leader

          # extra luaConfig (entryAnywhere is necessary for nixos module merging behaviour)
          luaConfigRC.misc = ''
            vim.api.nvim_create_user_command('W', 'write', { bang = true })
            vim.api.nvim_create_user_command('Q', 'quit', { bang = true })
            vim.api.nvim_create_user_command('X', 'xit', { bang = true })
            vim.api.nvim_create_user_command('E', 'edit<bang> <args>', {
              bang = true,
              nargs = '?',
            })
          '';
          luaConfigRC.graphviz = ''
            vim.g.graphviz_viewer = '${pkgs.zathura}/bin/zathura --fork'

            local group = vim.api.nvim_create_augroup("GraphvizAutoCompile", { clear = true })
            vim.api.nvim_create_autocmd("BufWritePost", {
              group = group,
              pattern = { "*.dot", "*.gv" },
              callback = function()
                pcall(vim.cmd, "GraphvizCompile")
              end,
            })
          '';

          telescope.enable = true;
          autocomplete.nvim-cmp.enable = true;
          # lsp.enable = true;

          spellcheck = {
            enable = true;
          };
          
          git = {
            gitsigns.enable = true;
            gitsigns.codeActions.enable = false;
          };
          visuals = {
            nvim-scrollbar.enable = true;
            # indent-blankline.enable = true;
            # nvim-cursorline.enable = true;
          };
          ui = {
            colorizer.enable = true;
          };
          utility = {
            diffview-nvim.enable = true;
            images = {
              img-clip.enable = true;
              image-nvim = {
                enable = true;
                setupOpts = {
                  backend = "kitty";
                  editorOnlyRenderWhenFocused = false;
                  integrations = {
                    markdown = {
                      enable = true;
                      clearInInsertMode = true;
                      downloadRemoteImages = true;
                    };
                  };
                };
              };
            };
          };

          debugger = {
            nvim-dap = {
              enable = true;
              ui.enable = true;
            };
          };

          languages = {
            nix.enable = true;
          };

          extraPlugins = with pkgs.vimPlugins; {
            nvim-dap-go.package = nvim-dap-go;
            nvim-dap.package = nvim-dap;
            telescope-dap-nvim.package = telescope-dap-nvim;
            graphviz-vim.package = graphviz-vim;
          };
          maps.normal = {
            # Telescope
            "<leader>tf".action = "<cmd>Telescope find_files<CR>"; # Find files
            "<leader>tg".action = "<cmd>Telescope live_grep<CR>"; # Live grep
            #"<leader>fb".action = "<cmd>Telescope buffers<CR>"; # Buffers
            #"<leader>th".action = "<cmd>Telescope help_tags<CR>"; # Help tags
            #"<leader>tq".action = "<cmd>Telescope frecency<CR>"; # Frequent files
            #"<leader>tu".action = "<cmd>Telescope undo<CR>"; # Undo history
            #"<leader>tgc".action = "<cmd>Telescope git_commits<CR>"; # Git commits
            #"<leader>tgs".action = "<cmd>Telescope git_status<CR>"; # Git status

            # Debugger
            "<Leader>s".action = "<cmd>lua require'dap'.continue()<CR>"; # Start or continue debugging
            "<F5>".action = "<cmd>lua require'dap'.continue()<CR>"; # Start or continue debugging

            "<Leader>n".action = "<cmd>lua require'dap'.step_over()<CR>"; # Step over
            "<F9>".action = "<cmd>lua require'dap'.step_over()<CR>"; # Step over
            "<Leader>m".action = "<cmd>lua require'dap'.step_into()<CR>"; # Step over
            "<F11>".action = "<cmd>lua require'dap'.step_into()<CR>"; # Step into
            "<Leader>N".action = "<cmd>lua require'dap'.step_out()<CR>"; # Step out
            "<F10>".action = "<cmd>lua require'dap'.step_out()<CR>"; # Step out
            "<Leader>b".action = "<cmd>lua require'dap'.toggle_breakpoint()<CR>"; # Toggle breakpoint
            "<F6>".action = "<cmd>lua require'dap'.toggle_breakpoint()<CR>"; # Toggle breakpoint
            #"<Leader>Q".action = "<cmd>lua require'dap'.set_breakpoint()<CR>";
            #"<Leader>lp".action = "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>";
            #"<Leader>dr".action = "<cmd>lua require'dap'.repl.open()<CR>"; # Open DAP REPL
            "<Leader>r".action = "<cmd>lua require'dap'.run_last()<CR>"; # Rerun last debug session
            "<F7>".action = "<cmd>lua require'dap'.run_last()<CR>"; # Rerun last debug session
            #"<Leader>w".action = "<cmd>lua require'dap'.open()<CR>";
            #"<Leader>W".action = "<cmd>lua require'dap'.close()<CR>";

            # Telescope + Debugger
            "<Leader>tdc".action = "<cmd>lua require'telescope'.extensions.dap.commands()<CR>";
            "<Leader>tdC".action = "<cmd>lua require'telescope'.extensions.dap.configurations()<CR>";
            "<Leader>tdv".action = "<cmd>lua require'telescope'.extensions.dap.variables()<CR>";
            "<Leader>tdf".action = "<cmd>lua require'telescope'.extensions.dap.frames()<CR>";
          };
        };
      };
    };
  };
}
