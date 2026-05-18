return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",

  config = function()
    local parsers = {
      "c",
      "cpp",
      "css",
      "html",
      "java",
      "javascript",
      "json",
      "lua",
      "markdown",
      "matlab",
      "python",
      "typescript",
      "tsx",
      "vim",
      "vimdoc",
      "yaml",
    }

    local filetypes = parsers
    local ok_configs, configs = pcall(require, "nvim-treesitter.configs")

    if not ok_configs then
      local ok_treesitter, treesitter = pcall(require, "nvim-treesitter")

      if ok_treesitter and treesitter.setup then
        treesitter.setup()
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ConfTreesitterHighlight", { clear = true }),
        pattern = filetypes,
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      return
    end

    configs.setup({
      ensure_installed = {},
      sync_install = false,
      auto_install = false,

      autopairs = {
        enable = true,
      },

      highlight = {
        enable = true,
      },

      indent = {
        enable = false,
      },
    })
  end,
}
