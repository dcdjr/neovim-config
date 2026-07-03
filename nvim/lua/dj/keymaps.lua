vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function map(mode, lhs, rhs, desc, extra_opts)
  local opts = vim.tbl_extend("force", {
    silent = true,
    desc = desc,
  }, extra_opts or {})

  vim.keymap.set(mode, lhs, rhs, opts)
end

map({ "n", "v" }, "<Space>", "<Nop>", "Leader")

-- Terminal helpers
local function open_horizontal_terminal()
  vim.cmd("belowright split")
  vim.cmd("resize 12")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

local function open_vertical_terminal()
  vim.cmd("belowright vsplit")
  vim.cmd("vertical resize 80")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-j>", "<C-w>j", "Move to lower window")
map("n", "<C-k>", "<C-w>k", "Move to upper window")
map("n", "<C-l>", "<C-w>l", "Move to right window")

-- Center after page movement
map("n", "<C-d>", "<C-d>zz", "Page down and center")
map("n", "<C-u>", "<C-u>zz", "Page up and center")

-- Terminal shortcuts
map("n", "<leader>t", open_horizontal_terminal, "Open horizontal terminal")
map("n", "<leader>T", open_vertical_terminal, "Open vertical terminal")
map("n", "<leader>tc", "<cmd>close<CR>", "Close terminal window")

-- Basic file/buffer actions
map("n", "<leader>w", "<cmd>w<CR>", "Write file")
map("n", "<leader>q", "<cmd>q<CR>", "Quit window")
map("n", "<leader>x", "<cmd>bdelete<CR>", "Delete buffer")

-- Resize with arrows
map("n", "<C-Up>", "<cmd>resize +1<CR>", "Increase window height")
map("n", "<C-Down>", "<cmd>resize -1<CR>", "Decrease window height")
map("n", "<C-Left>", "<cmd>vertical resize -1<CR>", "Decrease window width")
map("n", "<C-Right>", "<cmd>vertical resize +1<CR>", "Increase window width")

-- Buffer navigation
map("n", "<S-l>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<S-h>", "<cmd>bprevious<CR>", "Previous buffer")

-- Disable annoying Ex mode
map("n", "Q", "<nop>", "Disable Ex mode")

-- Toggles
map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled"))
end, "Toggle word wrap")

map("n", "<leader>ur", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
  vim.notify("Relative numbers " .. (vim.wo.relativenumber and "enabled" or "disabled"))
end, "Toggle relative numbers")

map("n", "<leader>uh", function()
  vim.o.hlsearch = not vim.o.hlsearch
  vim.notify("Search highlight " .. (vim.o.hlsearch and "enabled" or "disabled"))
end, "Toggle search highlight")

map("n", "<leader>uM", "<cmd>%s/\\r//g<CR>", "Remove carriage returns")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- Press jk quickly to exit insert mode
map("i", "jk", "<Esc>", "Exit insert mode")

-- Move text up/down and paste without yanking replaced text
map("v", "<A-j>", ":m .+1<CR>==", "Move selection down")
map("v", "<A-k>", ":m .-2<CR>==", "Move selection up")
map("v", "p", '"_dP', "Paste without yanking")

map("x", "J", ":move '>+1<CR>gv=gv", "Move block down")
map("x", "K", ":move '<-2<CR>gv=gv", "Move block up")
map("x", "<A-j>", ":move '>+1<CR>gv=gv", "Move block down")
map("x", "<A-k>", ":move '<-2<CR>gv=gv", "Move block up")
map("x", "p", '"_dP', "Paste without yanking")

-- Terminal navigation
map("t", "<C-h>", "<C-\\><C-N><C-w>h", "Move to left window")
map("t", "<C-j>", "<C-\\><C-N><C-w>j", "Move to lower window")
map("t", "<C-k>", "<C-\\><C-N><C-w>k", "Move to upper window")
map("t", "<C-l>", "<C-\\><C-N><C-w>l", "Move to right window")
map("t", "jk", "<C-\\><C-N>", "Exit terminal mode")
map("t", "<Esc>", "<C-\\><C-N>", "Exit terminal mode")
