return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile", "BufWritePre" },
  cmd = {
    "ConformInfo",
    "FormatDisable",
    "FormatEnable",
    "FormatToggle",
  },
  keys = {
    {
      "<leader>uf",
      "<cmd>FormatToggle<CR>",
      desc = "Toggle autoformat",
    },
  },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        css = { "prettier" },
        html = { "prettier" },
        java = { "google-java-format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "black" },
        scss = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        end

        local filetype = vim.bo[bufnr].filetype
        local lsp_format = (filetype == "c" or filetype == "cpp" or filetype == "objc" or filetype == "objcpp" or filetype == "cuda")
            and "never"
          or "fallback"

        return {
          timeout_ms = 1000,
          lsp_format = lsp_format,
          quiet = true,
        }
      end,
      notify_on_error = false,
      notify_no_formatters = false,
      formatters = {
        ["clang-format"] = {
          args = {
            "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
            "-assume-filename",
            "$FILENAME",
          },
          range_args = function(_, ctx)
            local util = require("conform.util")
            local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)

            return {
              "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
              "-assume-filename",
              "$FILENAME",
              "--offset",
              tostring(start_offset),
              "--length",
              tostring(end_offset - start_offset),
            }
          end,
        },
        clang_format = {
          args = {
            "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
            "-assume-filename",
            "$FILENAME",
          },
        },
      },
    })

    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.g.disable_autoformat = true
        vim.notify("Autoformat disabled globally")
      else
        vim.b.disable_autoformat = true
        vim.notify("Autoformat disabled for this buffer")
      end
    end, {
      bang = true,
      desc = "Disable format-on-save",
    })

    vim.api.nvim_create_user_command("FormatEnable", function(args)
      if args.bang then
        vim.g.disable_autoformat = false
        vim.notify("Autoformat enabled globally")
      else
        vim.b.disable_autoformat = false
        vim.notify("Autoformat enabled for this buffer")
      end
    end, {
      bang = true,
      desc = "Enable format-on-save",
    })

    vim.api.nvim_create_user_command("FormatToggle", function(args)
      if args.bang then
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Autoformat " .. (vim.g.disable_autoformat and "disabled" or "enabled") .. " globally")
      else
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify("Autoformat " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for this buffer")
      end
    end, {
      bang = true,
      desc = "Toggle format-on-save",
    })
  end,
}
