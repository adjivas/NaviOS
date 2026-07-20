{
  den.aspects.nvf.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.nvf = {
      mouse = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
    config = {
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
              tex.enable = true;
            };

            extraPlugins = with pkgs.vimPlugins; {
              nvim-dap-go.package = nvim-dap-go;
              nvim-dap.package = nvim-dap;
              telescope-dap-nvim.package = telescope-dap-nvim;
              graphviz-vim.package = graphviz-vim;
            };
            keymaps = [
              # Telescope
              {
                key = "<leader>tf";
                mode = "n";
                action = "<cmd>Telescope find_files<CR>";
              }
              {
                key = "<leader>tg";
                mode = "n";
                action = "<cmd>Telescope live_grep<CR>";
              }
              # { key = "<leader>fb"; mode = "n"; action = "<cmd>Telescope buffers<CR>"; } # Buffers
              # { key = "<leader>th"; mode = "n"; action = "<cmd>Telescope help_tags<CR>"; } # Help tags
              # { key = "<leader>tq"; mode = "n"; action = "<cmd>Telescope frecency<CR>"; } # Frequent files
              # { key = "<leader>tu"; mode = "n"; action = "<cmd>Telescope undo<CR>"; } # Undo history
              # { key = "<leader>tgc"; mode = "n"; action = "<cmd>Telescope git_commits<CR>"; } # Git commits
              # { key = "<leader>tgs"; mode = "n"; action = "<cmd>Telescope git_status<CR>"; } # Git status

              # Debugger
              {
                key = "<Leader>s";
                mode = "n";
                action = "<cmd>lua require'dap'.continue()<CR>";
              }
              {
                key = "<F5>";
                mode = "n";
                action = "<cmd>lua require'dap'.continue()<CR>";
              }
              {
                key = "<Leader>n";
                mode = "n";
                action = "<cmd>lua require'dap'.step_over()<CR>";
              }
              {
                key = "<F9>";
                mode = "n";
                action = "<cmd>lua require'dap'.step_over()<CR>";
              }
              {
                key = "<Leader>m";
                mode = "n";
                action = "<cmd>lua require'dap'.step_into()<CR>";
              }
              {
                key = "<F11>";
                mode = "n";
                action = "<cmd>lua require'dap'.step_into()<CR>";
              }
              {
                key = "<Leader>N";
                mode = "n";
                action = "<cmd>lua require'dap'.step_out()<CR>";
              }
              {
                key = "<F10>";
                mode = "n";
                action = "<cmd>lua require'dap'.step_out()<CR>";
              }
              {
                key = "<Leader>b";
                mode = "n";
                action = "<cmd>lua require'dap'.toggle_breakpoint()<CR>";
              }
              {
                key = "<F6>";
                mode = "n";
                action = "<cmd>lua require'dap'.toggle_breakpoint()<CR>";
              }
              {
                key = "<Leader>r";
                mode = "n";
                action = "<cmd>lua require'dap'.run_last()<CR>";
              }
              {
                key = "<F7>";
                mode = "n";
                action = "<cmd>lua require'dap'.run_last()<CR>";
              }
              # { key = "<Leader>lp"; mode = "n"; action = "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>"; }
              # { key = "<Leader>dr"; mode = "n"; action = "<cmd>lua require'dap'.repl.open()<CR>"; } # Open DAP REPL
              # { key = "<Leader>Q"; mode = "n"; action = "<cmd>lua require'dap'.set_breakpoint()<CR>"; }
              # { key = "<Leader>w"; mode = "n"; action = "<cmd>lua require'dap'.open()<CR>"; }
              # { key = "<Leader>W"; mode = "n"; action = "<cmd>lua require'dap'.close()<CR>"; }

              # Telescope + Debugger
              {
                key = "<Leader>tdc";
                mode = "n";
                action = "<cmd>lua require'telescope'.extensions.dap.commands()<CR>";
              }
              {
                key = "<Leader>tdC";
                mode = "n";
                action = "<cmd>lua require'telescope'.extensions.dap.configurations()<CR>";
              }
              {
                key = "<Leader>tdv";
                mode = "n";
                action = "<cmd>lua require'telescope'.extensions.dap.variables()<CR>";
              }
              {
                key = "<Leader>tdf";
                mode = "n";
                action = "<cmd>lua require'telescope'.extensions.dap.frames()<CR>";
              }
            ];
          };
        };
      };
    };
  };
}
