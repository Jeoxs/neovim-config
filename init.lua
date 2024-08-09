-- Set leader key
vim.g.mapleader = " "

-- Basic settings
vim.opt.number = true        -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 4          -- Number of spaces tabs count for
vim.opt.shiftwidth = 4       -- Number of spaces for autoindent
vim.opt.expandtab = true     -- Use spaces instead of tabs
vim.opt.smartindent = true   -- Smart indenting on new lines
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.mouse = "a"          -- Enable mouse support
vim.opt.ignorecase = true    -- Ignore case in search patterns
vim.opt.smartcase = true     -- Smart case
vim.opt.termguicolors = true -- True color support

-- Set up basic keybindings
vim.api.nvim_set_keymap("n", "<leader>e", ":Ex<CR>", { noremap = true })

-- Automatically install packer if not installed
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the init.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call to avoid errors on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    vim.notify("Packer.nvim is not installed!")
    return
end

-- Use a popup window for packer
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
}

-- Plugins installation
packer.startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Useful Lua functions used by lots of plugins
    use 'nvim-lua/plenary.nvim'

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    -- Treesitter for better syntax highlighting
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    -- LSP (Language Server Protocol) configurations
    use 'neovim/nvim-lspconfig'

    -- Autocompletion plugin
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp

    -- Snippets plugin
    use 'L3MON4D3/LuaSnip'

    -- Git integration
    use 'lewis6991/gitsigns.nvim'

    -- Statusline
    use 'nvim-lualine/lualine.nvim'

    -- File explorer
    use 'kyazdani42/nvim-tree.lua'

    -- Icons
    use 'kyazdani42/nvim-web-devicons'

    -- Gruvbox theme
    use 'morhetz/gruvbox'

    use {
        'akinsho/flutter-tools.nvim',
        requires = 'nvim-lua/plenary.nvim'
    }

    use {
        'mfussenegger/nvim-dap',
        'rcarriga/nvim-dap-ui',
    }
    use 'nvim-neotest/nvim-nio'

    use {
        'lalitmee/cobalt2.nvim',
        requires = 'tjdevries/colorbuddy.nvim'
    }
    use { "catppuccin/nvim", as = "catppuccin" }
end)

vim.cmd.colorscheme "catppuccin"


-- require('colorbuddy').colorscheme('cobalt2')


-- Set up LSP servers
local lspconfig = require('lspconfig')
local on_attach = function(client, bufnr)
   -- Key mappings for LSP functionality
   local opts = { noremap=true, silent=true }
   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
end

-- Enable language servers
lspconfig.pyright.setup{ on_attach = on_attach } -- Python
lspconfig.tsserver.setup{ on_attach = on_attach } -- TypeScript/JavaScript

-- Dart/Flutter LSP configuration
lspconfig.dartls.setup{
    on_attach = on_attach,
    filetypes = { "dart" },
    init_options = {
        closingLabels = true,
        flutterOutline = true,
        onlyAnalyzeProjectsWithOpenFiles = true,
        outline = true,
        suggestFromUnimportedLibraries = true
    }
}


-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"lua","python","javascript","typescript","dart","php","html","css"}, -- Install all maintained parsers
  highlight = {
    enable = true,              -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
}

-- Luasnip configuration
local luasnip = require 'luasnip'

-- Key bindings for snippets
vim.api.nvim_set_keymap("i", "<C-k>", "<cmd>lua require'luasnip'.expand_or_jump()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("s", "<C-k>", "<cmd>lua require'luasnip'.expand_or_jump()<CR>", { noremap = true, silent = true })

-- nvim-cmp setup
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

vim.cmd [[packadd nvim-tree.lua]]
require'nvim-tree'.setup {}

require("flutter-tools").setup{
  lsp = {
    on_attach = on_attach,  -- Configure LSP as usual
    capabilities = capabilities,  -- Optionally pass capabilities
  },
  widget_guides = {
    enabled = true,
  },
  closing_tags = {
    highlight = "Comment", -- Highlight closing tags
    prefix = "// ",         -- Prefix for closing tags
  },
  dev_log = {
    enabled = true,
    open_cmd = "tabedit", -- Command to open the log buffer
  },
  dev_tools = {
    autostart = true,         -- Automatically start DevTools server if not running
  },
  outline = {
    open_cmd = "30vnew",      -- Command to open the outline buffer
    auto_open = true          -- Automatically open the outline when you open a Dart file
  }
}

local dap = require('dap')

dap.adapters.dart = {
  type = "executable",
  command = "node",
  args = {"/path/to/flutter/dart_debug_adapter.js"}  -- Adjust this to your setup
}

dap.configurations.dart = {
  {
    type = "dart",
    request = "launch",
    name = "Launch Flutter",
    program = "${workspaceFolder}/lib/main.dart",
    cwd = "${workspaceFolder}",
    args = {"--flavor", "development"},  -- Additional args for Flutter
  },
}

require("dapui").setup()



vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

