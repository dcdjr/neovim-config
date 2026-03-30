-- =========================
-- Leader
-- =========================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if desc then
    opts.desc = desc
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

map({ "n", "v" }, "<Space>", "<Nop>")
map("i", "jk", "<Esc>", "Exit insert mode")
map("t", "jk", [[<C-\><C-n>]], "Exit terminal mode")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- =========================
-- Core options
-- =========================
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 200
opt.timeoutlen = 300
opt.undofile = true
opt.mouse = "a"

opt.clipboard = "unnamedplus"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.swapfile = false
opt.backup = false
opt.confirm = true

-- Native completion menu behavior
opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- Rounded borders for all floating windows
vim.o.winborder = "rounded"

-- =========================
-- Diagnostics
-- =========================
vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  underline = true,
  signs = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
})

-- =========================
-- Autocmds
-- =========================
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 120 })
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- =========================
-- lazy.nvim bootstrap
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    os.exit(1)
  end
end

opt.rtp:prepend(lazypath)

-- =========================
-- Plugins
-- =========================
require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd.colorscheme("tokyonight")
      end,
    },

    {
      "tpope/vim-sleuth",
      event = { "BufReadPre", "BufNewFile" },
    },

    {
      "numToStr/Comment.nvim",
      event = "VeryLazy",
      opts = {},
    },

    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {},
    },

    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {},
    },

    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      dependencies = { "nvim-lua/plenary.nvim" },
      keys = {
        {
          "<leader>ff",
          function()
            require("telescope.builtin").find_files()
          end,
          desc = "Find files",
        },
        {
          "<leader>fg",
          function()
            require("telescope.builtin").live_grep()
          end,
          desc = "Live grep",
        },
        {
          "<leader>fb",
          function()
            require("telescope.builtin").buffers()
          end,
          desc = "Find buffers",
        },
        {
          "<leader>fh",
          function()
            require("telescope.builtin").help_tags()
          end,
          desc = "Help tags",
        },
      },
      opts = {
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
        },
      },
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      cmd = "Neotree",
      keys = {
        {
          "<leader>e",
          "<cmd>Neotree toggle filesystem reveal left<cr>",
          desc = "Explorer",
        },
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
      end,
      opts = {
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
      },
    },

    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "bash",
            "c",
            "cpp",
            "cmake",
            "lua",
            "vim",
            "vimdoc",
            "json",
            "yaml",
            "markdown",
            "markdown_inline",
            "python",
            "make",
          },
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },

    {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        vim.lsp.config("clangd", {
          cmd = { "clangd", "--background-index" },
        })

        vim.lsp.enable("clangd")
      end,
    },
  },

  install = {
    colorscheme = { "tokyonight", "habamax" },
  },

  checker = { enabled = true },
  change_detection = { notify = false },
  rocks = { enabled = false },
})

-- =========================
-- LSP
-- =========================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(args)
    local client = nil
    if args.data and args.data.client_id then
      client = vim.lsp.get_client_by_id(args.data.client_id)
    end

    local opts = { buffer = args.buf }

    map("n", "gd", vim.lsp.buf.definition, "Go to definition", opts)
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration", opts)
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation", opts)
    map("n", "gr", vim.lsp.buf.references, "Find references", opts)
    map("n", "K", vim.lsp.buf.hover, "Hover docs", opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol", opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action", opts)
    map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics", opts)
    map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic", opts)
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic", opts)

    -- Small, native autocomplete
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = true,
      })

      map("i", "<C-Space>", function()
        vim.lsp.completion.get()
      end, "Trigger completion", opts)
    end

    -- Helpful but still native/lightweight
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, {
        bufnr = args.buf,
        client_id = client.id,
      })

      map("n", "<leader>uh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = args.buf })
      end, "Toggle inlay hints", opts)
    end
  end,
})

-- =========================
-- Extra keybindings
-- =========================
map("n", "<leader>t", function()
  vim.cmd("vsplit")
  vim.cmd("wincmd l")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, "Open terminal")
