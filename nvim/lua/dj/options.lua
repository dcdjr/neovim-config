-- Minimal Neovim options.
-- Keep this boring. Add complexity only when you understand the pain it solves.

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.cmdheight = 1
opt.scrolloff = 4
opt.sidescrolloff = 4
opt.wrap = false
opt.mouse = "a"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Editing
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.fileencoding = "utf-8"
opt.completeopt = { "menuone", "noselect" }
opt.timeoutlen = 1000
opt.updatetime = 300

-- Indentation defaults: 2 spaces for general files.
-- Filetype overrides live in autocmds.lua.
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.autoindent = true
opt.smartindent = false

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Let WezTerm's Catppuccin/Mica/transparency show through.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local groups = {
      "Normal",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "LineNr",
      "CursorLineNr",
      "EndOfBuffer",
    }

    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end
  end,
})

vim.cmd.colorscheme("habamax")
