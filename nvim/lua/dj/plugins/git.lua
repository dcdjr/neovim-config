return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },

  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
      untracked = { text = "?" },
    },

    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
          buffer = bufnr,
          silent = true,
          desc = desc,
        })
      end

      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next git hunk")

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Previous git hunk")

      map("n", "<leader>gp", gitsigns.preview_hunk, "Preview git hunk")

      map("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")

      map("n", "<leader>gd", gitsigns.diffthis, "Diff this file")
    end,
  },
}
