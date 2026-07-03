return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  config = function()
    local wk = require("which-key")

    wk.setup({})

    wk.add({
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>t", group = "terminal" },
      { "<leader>u", group = "toggles" },
      { "<leader>l", group = "lsp" },
      { "<leader>d", group = "diagnostics" },
    })
  end,
}
