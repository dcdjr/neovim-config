-- Filetype-specific indentation and small quality-of-life autocmds.

local function set_indent(width)
  vim.opt_local.expandtab = true
  vim.opt_local.shiftwidth = width
  vim.opt_local.softtabstop = width
  vim.opt_local.tabstop = width
end

-- Global indentation defaults live in options.lua:
--   2 spaces for normal files.
-- Only special cases belong here.

-- C/C++: 4 spaces
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("DjIndentCpp", { clear = true }),
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function()
    set_indent(4)
    vim.opt_local.cindent = true
  end,
})

-- Python: 4 spaces
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("DjIndentPython", { clear = true }),
  pattern = "python",
  callback = function()
    set_indent(4)
  end,
})

-- make
vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 0
  end,
})

-- Terminal buffers should feel like terminals, not code files.
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("DjTerminalSettings", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    vim.cmd("startinsert")
  end,
})

-- Stop auto-commenting new lines after comments.
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("DjFormatOptions", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
