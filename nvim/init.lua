local source = debug.getinfo(1, "S").source

if source:sub(1, 1) == "@" then
  local config_dir = vim.fn.fnamemodify(source:sub(2), ":p:h")
  vim.opt.runtimepath:prepend(config_dir)
end

require "conf"
