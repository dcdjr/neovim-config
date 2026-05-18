local options = {
  backup = false,
  clipboard = "unnamedplus",
  cmdheight = 1,
  completeopt = { "menuone", "noselect" },
  conceallevel = 0,
  fileencoding = "utf-8",
  hlsearch = true,
  incsearch = true,
  ignorecase = true,
  mouse = "a",
  pumheight = 10,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  termguicolors = true,
  timeoutlen = 1000,
  undofile = true,
  updatetime = 300,
  writebackup = false,
  expandtab = true,
  shiftwidth = 4,
  softtabstop = 4,
  tabstop = 4,
  cursorline = true,
  number = true,
  relativenumber = false,
  numberwidth = 4,
  signcolumn = "yes",
  wrap = false,
  scrolloff = 4,
  sidescrolloff = 4,
  guifont = "JetBrainsMono Nerd Font:h11",
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.opt.shortmess:append("c")

local indent_group = vim.api.nvim_create_augroup("ConfIndentSettings", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  group = indent_group,
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end

    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.cindent = true
  end,
})

local terminal_group = vim.api.nvim_create_augroup("ConfTerminalSettings", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = terminal_group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    vim.cmd("startinsert")
  end,
})

local format_options_group = vim.api.nvim_create_augroup("ConfFormatOptions", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = format_options_group,
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
