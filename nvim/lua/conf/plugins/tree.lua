return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
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
      if api.map and api.map.on_attach and api.map.on_attach.default then
        api.map.on_attach.default(bufnr)
      elseif api.config and api.config.mappings and api.config.mappings.default_on_attach then
        api.config.mappings.default_on_attach(bufnr)
      end

      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          nowait = true,
          noremap = true,
          silent = true,
        }
      end

      local function map(lhs, rhs, desc)
        if rhs then
          vim.keymap.set("n", lhs, rhs, opts(desc))
        end
      end

      map("?", api.tree.toggle_help, "Help")
      map("l", api.node.open.edit, "Open")
      map("h", api.node.navigate.parent_close, "Close directory")
      map("v", api.node.open.vertical, "Open vertical split")
      map("s", api.node.open.horizontal, "Open horizontal split")
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = {
          enable = true,
        },
      },
      view = {
        width = 32,
        preserve_window_proportions = true,
      },
      renderer = {
        group_empty = true,
        highlight_git = "name",
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
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = {
            enable = true,
          },
        },
      },
    })
  end,
}
