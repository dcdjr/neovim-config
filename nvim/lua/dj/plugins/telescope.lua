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

return {
  "nvim-telescope/telescope.nvim",
  version = '*',
  dependencies = {
    "nvim-lua/plenary.nvim",
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
      desc = "Find files",
    },
    {
      "<leader>fp",
      project_files,
      desc = "Find project files",
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
      desc = "Find help",
    },
  },
  config = function()
    local actions = require("telescope.actions")

    require("telescope").setup({
      defaults = {
        prompt_prefix = "> ",
        selection_caret = "> ",
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<Esc>"] = actions.close,
          },
          n = {
            ["q"] = actions.close,
          },
        },
      },
    })
  end,
}
