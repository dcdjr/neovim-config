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
        local opts = {
          desc = desc,
          silent = true,
        }

        opts.buffer = bufnr

        vim.keymap.set(mode, lhs, rhs, opts)
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

      map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
      map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
      map("v", "<leader>gs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage selected hunk")
      map("v", "<leader>gr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset selected hunk")
      map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>gB", gitsigns.toggle_current_line_blame, "Toggle line blame")
      map("n", "<leader>gd", gitsigns.diffthis, "Diff this")
      map("n", "<leader>gD", function()
        gitsigns.diffthis("~")
      end, "Diff this against previous")
      map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select git hunk")
    end,
  },
}
