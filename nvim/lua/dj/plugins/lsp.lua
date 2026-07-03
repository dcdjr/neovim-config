return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },

  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",

    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },

  config = function()
    local cmp = require("cmp")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    vim.diagnostic.config({
      virtual_text = {
        prefix = ">",
        spacing = 2,
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("DjLspAttach", { clear = true }),
      callback = function(event)
        local function opts(desc)
          return {
            buffer = event.buf,
            silent = true,
            desc = desc,
          }
        end

        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover documentation"))
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("References"))

        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename symbol"))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
        vim.keymap.set("n", "<leader>k", vim.diagnostic.open_float, opts("Line diagnostics"))

        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump({ count = -1 })
        end, opts("Previous diagnostic"))

        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump({ count = 1 })
        end, opts("Next diagnostic"))
      end,
    })

    require("mason").setup()

    require("mason-lspconfig").setup({
      ensure_installed = {
        "clangd",
        "lua_ls",
        "pyright",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "yamlls",
      },
    })

    local servers = {
      clangd = {},

      pyright = {},

      ts_ls = {},

      html = {},

      cssls = {},

      jsonls = {},

      yamlls = {},

      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      },
    }

    for name, server_config in pairs(servers) do
      server_config.capabilities = vim.tbl_deep_extend(
        "force",
        {},
        capabilities,
        server_config.capabilities or {}
      )

      vim.lsp.config(name, server_config)
      vim.lsp.enable(name)
    end

    cmp.setup({
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),

        ["<CR>"] = cmp.mapping.confirm({
          select = false,
        }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
      }, {
        { name = "buffer" },
      }),
    })
  end,
}
