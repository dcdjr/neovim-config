return {
  "numToStr/Comment.nvim",

  keys = {
    { "gc", mode = { "n", "v" }, desc = "Comment line/motion" },
    { "gb", mode = { "n", "v" }, desc = "Block comment" },
  },

  config = function()
    require("Comment").setup()
  end,
}
