{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON
      pyright
      rust-analyzer
      gopls

      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      black
      rustfmt

      # Tools
      ripgrep
      fd
      tree-sitter
    ];

    plugins = with pkgs.vimPlugins; [
      # Theme
      {
        plugin = nord-nvim;
        type = "lua";
        config = ''
          require('nord').set()
          vim.cmd('colorscheme nord')
        '';
      }

      # File explorer
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          require('nvim-tree').setup({
            view = { width = 30 },
            filters = { dotfiles = false },
          })
          vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
        '';
      }
      nvim-web-devicons

      # Status line
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup({
            options = {
              theme = 'nord',
              component_separators = { left = '', right = '' },
              section_separators = { left = '', right = '' },
            },
          })
        '';
      }

      # Buffer line
      {
        plugin = bufferline-nvim;
        type = "lua";
        config = ''
          require('bufferline').setup({
            options = {
              diagnostics = 'nvim_lsp',
              show_buffer_close_icons = false,
              show_close_icon = false,
            },
          })
          vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
          vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')
        '';
      }

      # Treesitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup({
            highlight = { enable = true },
            indent = { enable = true },
          })
        '';
      }

      # LSP
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local lspconfig = require('lspconfig')
          local capabilities = require('cmp_nvim_lsp').default_capabilities()

          -- LSP servers
          lspconfig.lua_ls.setup({ capabilities = capabilities })
          lspconfig.nil_ls.setup({ capabilities = capabilities })
          lspconfig.ts_ls.setup({ capabilities = capabilities })
          lspconfig.pyright.setup({ capabilities = capabilities })
          lspconfig.rust_analyzer.setup({ capabilities = capabilities })
          lspconfig.gopls.setup({ capabilities = capabilities })

          -- Keymaps
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
          vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
        '';
      }

      # Completion
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require('cmp')
          cmp.setup({
            snippet = {
              expand = function(args)
                require('luasnip').lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<Tab>'] = cmp.mapping.select_next_item(),
              ['<S-Tab>'] = cmp.mapping.select_prev_item(),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              { name = 'buffer' },
              { name = 'path' },
            }),
          })
        '';
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      # Telescope
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local telescope = require('telescope')
          telescope.setup({
            defaults = {
              file_ignore_patterns = { 'node_modules', '.git' },
            },
          })
          vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
          vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
          vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')
          vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>')
        '';
      }
      plenary-nvim

      # Git
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup()
        '';
      }

      # Utilities
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require('which-key').setup()
        '';
      }
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require('Comment').setup()
        '';
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require('nvim-autopairs').setup()
        '';
      }
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = ''
          require('ibl').setup()
        '';
      }
    ];

    extraLuaConfig = ''
      -- Leader key
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

      -- Options
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.mouse = 'a'
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = true
      vim.opt.wrap = false
      vim.opt.breakindent = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.signcolumn = 'yes'
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.sidescrolloff = 8
      vim.opt.clipboard = 'unnamedplus'
      vim.opt.undofile = true
      vim.opt.cursorline = true

      -- Keymaps
      vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>')
      vim.keymap.set('n', '<leader>w', ':w<CR>')
      vim.keymap.set('n', '<leader>q', ':q<CR>')
      vim.keymap.set('n', '<leader>x', ':bd<CR>')

      -- Window navigation
      vim.keymap.set('n', '<C-h>', '<C-w>h')
      vim.keymap.set('n', '<C-j>', '<C-w>j')
      vim.keymap.set('n', '<C-k>', '<C-w>k')
      vim.keymap.set('n', '<C-l>', '<C-w>l')

      -- Move lines
      vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
      vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
    '';
  };
}
