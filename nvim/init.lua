if vim.loader and vim.loader.enable then
  vim.loader.enable()
end

-- =========================
-- Leader
-- =========================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function augroup(name)
  return vim.api.nvim_create_augroup("user-" .. name, { clear = true })
end

local function map(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if desc then
    opts.desc = desc
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

local command_cache = {}

local function command_works(cmd)
  local key = table.concat(cmd, "\0")
  if command_cache[key] ~= nil then
    return command_cache[key]
  end

  local ok = false
  if vim.fn.executable(cmd[1]) == 1 then
    local ran = pcall(vim.fn.system, cmd)
    ok = ran and vim.v.shell_error == 0
  end

  command_cache[key] = ok
  return ok
end

local function set_indent(width, use_tabs)
  vim.bo.expandtab = not use_tabs
  vim.bo.tabstop = width
  vim.bo.shiftwidth = width
  vim.bo.softtabstop = width
end

local function inside_git_repo()
  if vim.fs and vim.fs.find then
    return vim.fs.find(".git", {
      path = vim.fn.getcwd(),
      upward = true,
      type = "directory",
    })[1] ~= nil
  end

  return vim.fn.finddir(".git", ".;") ~= ""
end

local function telescope_find_command()
  if command_works({ "fd", "--version" }) then
    return { "fd", "--type", "f", "--strip-cwd-prefix" }
  end

  if command_works({ "fdfind", "--version" }) then
    return { "fdfind", "--type", "f", "--strip-cwd-prefix" }
  end

  if command_works({ "rg", "--version" }) then
    return { "rg", "--files", "--color", "never" }
  end

  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    return { "cmd.exe", "/c", "dir", "/s", "/b", "/a-d" }
  end

  if vim.fn.executable("find") == 1 then
    return { "find", ".", "-type", "f" }
  end
end

local function project_files()
  local builtin = require("telescope.builtin")

  if inside_git_repo() then
    local ok = pcall(builtin.git_files, {
      show_untracked = true,
      recurse_submodules = true,
    })

    if ok then
      return
    end
  end

  local find_command = telescope_find_command()
  if not find_command then
    vim.notify(
      "No project file search backend is available. Install fd or ripgrep for the best experience.",
      vim.log.levels.WARN
    )
    return
  end

  builtin.find_files({
    hidden = true,
    find_command = find_command,
  })
end

local function quickfix_grep(query)
  local pattern = vim.fn.escape(query, [[\/]])
  local ok = pcall(vim.cmd, ("silent noautocmd vimgrep /\\V%s/j **/*"):format(pattern))

  if not ok then
    vim.notify(("No matches found for %q"):format(query), vim.log.levels.INFO)
    return
  end

  local qf = vim.fn.getqflist({ size = 0 })
  if qf.size > 0 then
    vim.cmd("copen")
  else
    vim.notify(("No matches found for %q"):format(query), vim.log.levels.INFO)
  end
end

local function project_grep()
  if command_works({ "rg", "--version" }) then
    require("telescope.builtin").live_grep()
    return
  end

  local notify = vim.notify_once or vim.notify
  notify(
    "ripgrep is unavailable, falling back to Vim's quickfix grep.",
    vim.log.levels.WARN
  )

  vim.ui.input({ prompt = "Project grep > " }, function(input)
    if not input or input == "" then
      return
    end

    quickfix_grep(input)
  end)
end

local function setup_lsp_server(name, config)
  config = config or {}

  if vim.lsp.config and vim.lsp.enable then
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
    return
  end

  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok or not lspconfig[name] then
    return
  end

  lspconfig[name].setup(config)
end

local function diagnostic_jump(count)
  return function()
    if vim.diagnostic.jump then
      vim.diagnostic.jump({ count = count, float = true })
      return
    end

    if count < 0 then
      vim.diagnostic.goto_prev()
    else
      vim.diagnostic.goto_next()
    end
  end
end

local function enable_native_completion(client_id, bufnr)
  if not (vim.lsp.completion and vim.lsp.completion.enable) then
    return false
  end

  return pcall(vim.lsp.completion.enable, true, client_id, bufnr, {
    autotrigger = true,
  })
end

local function inlay_hints_enabled(bufnr)
  if not (vim.lsp.inlay_hint and vim.lsp.inlay_hint.is_enabled) then
    return false
  end

  local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
  if ok then
    return enabled
  end

  ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, bufnr)
  return ok and enabled or false
end

local function set_inlay_hints(enabled, bufnr, client_id)
  if not (vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable) then
    return false
  end

  local ok = pcall(vim.lsp.inlay_hint.enable, enabled, {
    bufnr = bufnr,
    client_id = client_id,
  })
  if ok then
    return true
  end

  ok = pcall(vim.lsp.inlay_hint.enable, bufnr, enabled)
  return ok
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
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true

opt.ignorecase = true
opt.smartcase = true

opt.swapfile = false
opt.backup = false
opt.confirm = true

-- Native completion menu behavior
opt.completeopt = { "menu", "menuone", "noselect" }

-- Rounded borders for all floating windows
if vim.fn.has("nvim-0.11") == 1 then
  vim.o.winborder = "rounded"
end

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
    focusable = false,
    source = "if_many",
  },
})

-- =========================
-- Autocmds
-- =========================
local indentation_group = augroup("indentation")

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank-highlight"),
  callback = function()
    vim.highlight.on_yank({ timeout = 120 })
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("equalize-splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indentation_group,
  pattern = { "lua", "vim", "vimdoc", "json", "jsonc", "yaml", "toml", "markdown", "sh", "bash", "zsh" },
  callback = function()
    set_indent(2, false)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indentation_group,
  pattern = { "c", "cpp", "cmake", "python" },
  callback = function()
    set_indent(4, false)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indentation_group,
  pattern = { "make" },
  callback = function()
    set_indent(4, true)
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
          project_files,
          desc = "Find files",
        },
        {
          "<leader>fg",
          project_grep,
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
            "cmake",
            "cpp",
            "diff",
            "git_config",
            "gitignore",
            "json",
            "jsonc",
            "lua",
            "luadoc",
            "make",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "toml",
            "vim",
            "vimdoc",
            "yaml",
          },
          auto_install = true,
          highlight = { enable = true },
          indent = {
            enable = true,
            disable = { "python" },
          },
        })
      end,
    },

    {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        if command_works({ "clangd", "--version" }) then
          setup_lsp_server("clangd", {
            cmd = { "clangd", "--background-index" },
          })
        end

        if command_works({ "lua-language-server", "--version" }) then
          setup_lsp_server("lua_ls", {
            cmd = { "lua-language-server" },
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                hint = {
                  enable = true,
                },
                workspace = {
                  checkThirdParty = false,
                },
              },
            },
          })
        end
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
  group = augroup("lsp-attach"),
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
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action", opts)
    map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics", opts)
    map("n", "[d", diagnostic_jump(-1), "Previous diagnostic", opts)
    map("n", "]d", diagnostic_jump(1), "Next diagnostic", opts)

    if client and client:supports_method("textDocument/formatting") then
      map("n", "<leader>lf", function()
        vim.lsp.buf.format({ async = true })
      end, "Format buffer", opts)
    end

    if client and client:supports_method("textDocument/completion") and enable_native_completion(client.id, args.buf) then
      map("i", "<C-Space>", function()
        if vim.lsp.completion and vim.lsp.completion.get then
          vim.lsp.completion.get()
        end
      end, "Trigger completion", opts)
    end

    if client and client:supports_method("textDocument/inlayHint") then
      set_inlay_hints(true, args.buf, client.id)

      map("n", "<leader>uh", function()
        set_inlay_hints(not inlay_hints_enabled(args.buf), args.buf, client.id)
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
