return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  cmd = {
    "NvimTreeToggle",
    "NvimTreeFocus",
    "NvimTreeFindFile",
  },
  keys = {
    {
      "<leader>e",
      "<cmd>NvimTreeToggle<CR>",
      desc = "Toggle file tree",
    },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    local api = require("nvim-tree.api")

    local function on_attach(bufnr)
      api.config.mappings.default_on_attach(bufnr)

      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          nowait = true,
          noremap = true,
          silent = true,
        }
      end

      vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close directory"))
      vim.keymap.set("n", "v", api.node.open.vertical, opts("Open vertical split"))
      vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open horizontal split"))
      vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
    end

    require("nvim-tree").setup({
      on_attach = on_attach,

      sync_root_with_cwd = true,
      respect_buf_cwd = true,

      update_focused_file = {
        enable = true,
        update_root = true,
      },

      view = {
        width = 32,
        preserve_window_proportions = true,
      },

      renderer = {
        group_empty = true,
        highlight_git = true,
        indent_markers = {
          enable = true,
        },
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },

      filters = {
        dotfiles = false,
        custom = { "^.git$" },
      },

      git = {
        enable = true,
        ignore = false,
      },

      filesystem_watchers = {
        enable = false,
      },
    })
  end,
}
