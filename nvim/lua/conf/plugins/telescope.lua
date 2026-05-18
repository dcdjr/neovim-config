local function is_git_repo()
  vim.fn.system({ "git", "rev-parse", "--is-inside-work-tree" })
  return vim.v.shell_error == 0
end

local function project_files()
  local builtin = require("telescope.builtin")

  if is_git_repo() then
    builtin.git_files({ show_untracked = true })
  else
    builtin.find_files({ hidden = true })
  end
end

local function command_runs(command)
  if not command or command == "" or vim.fn.executable(command) ~= 1 then
    return false
  end

  if not vim.system then
    vim.fn.system({ command, "--version" })
    return vim.v.shell_error == 0
  end

  local ok, result = pcall(function()
    return vim.system({ command, "--version" }, { text = true }):wait(1000)
  end)

  return ok and result and result.code == 0
end

local function working_ripgrep()
  local candidates = {}

  if vim.env.LOCALAPPDATA then
    vim.list_extend(candidates, vim.fn.glob(
      vim.env.LOCALAPPDATA
        .. "/Microsoft/WinGet/Packages/BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe/ripgrep-*/rg.exe",
      false,
      true
    ))
  end

  table.insert(candidates, "rg")

  for _, command in ipairs(candidates) do
    if command_runs(command) then
      return command
    end
  end

  return nil
end

local function live_grep()
  if not working_ripgrep() then
    vim.notify("ripgrep is not installed; live grep is unavailable", vim.log.levels.WARN)
    return
  end

  require("telescope.builtin").live_grep()
end

return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
      desc = "Find files",
    },
    { "<leader>fp", project_files, desc = "Find project files" },
    {
      "<leader>fg",
      live_grep,
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
      desc = "Find help",
    },
    {
      "<leader>fo",
      function()
        require("telescope.builtin").oldfiles()
      end,
      desc = "Recent files",
    },
    {
      "<leader>fd",
      function()
        require("telescope.builtin").diagnostics()
      end,
      desc = "Find diagnostics",
    },
  },

  config = function()
    local actions = require("telescope.actions")
    local telescope = require("telescope")
    local rg = working_ripgrep()

    if rg then
      vim.opt.grepprg = rg .. " --vimgrep --smart-case --hidden --glob !.git/"
    end

    local defaults = {
      prompt_prefix = "> ",
      selection_caret = "> ",
      path_display = { "truncate" },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          ["<Esc>"] = actions.close,
        },
        n = {
          ["q"] = actions.close,
        },
      },
    }

    if rg then
      defaults.vimgrep_arguments = {
        rg,
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob",
        "!.git/",
      }
    end

    telescope.setup({
      defaults = defaults,
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    })
  end,
}
