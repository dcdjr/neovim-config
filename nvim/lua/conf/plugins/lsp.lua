return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },

  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local function keymap_opts(bufnr, desc)
      local opts = {
        desc = desc,
        silent = true,
      }

      opts.buffer = bufnr

      return opts
    end

    local function diagnostic_jump(count)
      return function()
        if vim.diagnostic.jump then
          vim.diagnostic.jump({ count = count })
        elseif count > 0 then
          vim.diagnostic.goto_next()
        else
          vim.diagnostic.goto_prev()
        end
      end
    end

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

    local lsp_group = vim.api.nvim_create_augroup("ConfLspAttach", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = lsp_group,
      desc = "Configure LSP buffer actions",
      callback = function(event)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, keymap_opts(event.buf, desc))
        end

        map("K", vim.lsp.buf.hover, "LSP hover")
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("go", vim.lsp.buf.type_definition, "Go to type definition")
        map("gr", vim.lsp.buf.references, "Go to references")
        map("gs", vim.lsp.buf.signature_help, "Signature help")
        map("<leader>k", vim.diagnostic.open_float, "Line diagnostics")
        map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("<F2>", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<F4>", vim.lsp.buf.code_action, "Code action")
        map("[d", diagnostic_jump(-1), "Previous diagnostic")
        map("]d", diagnostic_jump(1), "Next diagnostic")
        map("<leader>dl", vim.diagnostic.setloclist, "Diagnostic location list")
        map("<leader>lf", function()
          local ok, conform = pcall(require, "conform")

          if ok then
            conform.format({
              async = true,
              bufnr = event.buf,
              lsp_format = "fallback",
            })
          else
            vim.lsp.buf.format({ async = true })
          end
        end, "Format buffer")
      end,
    })

    local servers = {
      clangd = {},
      cssls = {},
      html = {},
      jdtls = {},
      jsonls = {},
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
      pyright = {},
      ts_ls = {},
      yamlls = {
        filetypes = { "yaml" },
      },
    }

    local use_native_lsp = vim.lsp.config ~= nil and type(vim.lsp.enable) == "function"

    require("mason").setup()

    for server_name, server_config in pairs(servers) do
      server_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})

      if use_native_lsp then
        vim.lsp.config(server_name, server_config)
      else
        require("lspconfig")[server_name].setup(server_config)
      end
    end

    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(servers),
      automatic_enable = use_native_lsp,
    })

    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()

    local function expand_or_jumpable()
      if luasnip.expand_or_locally_jumpable then
        return luasnip.expand_or_locally_jumpable()
      end

      return luasnip.expand_or_jumpable()
    end

    local kind_labels = {
      Text = "Text",
      Method = "Method",
      Function = "Func",
      Constructor = "Ctor",
      Field = "Field",
      Variable = "Var",
      Class = "Class",
      Interface = "Iface",
      Module = "Module",
      Property = "Prop",
      Unit = "Unit",
      Value = "Value",
      Enum = "Enum",
      Keyword = "Key",
      Snippet = "Snip",
      Color = "Color",
      File = "File",
      Reference = "Ref",
      Folder = "Dir",
      EnumMember = "Enum",
      Constant = "Const",
      Struct = "Struct",
      Event = "Event",
      Operator = "Op",
      TypeParameter = "Type",
    }

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-1),
        ["<C-f>"] = cmp.mapping.scroll_docs(1),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
      }, {
        { name = "buffer" },
      }),
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = string.format("[%s]", kind_labels[vim_item.kind] or vim_item.kind)
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            buffer = "[Buffer]",
            path = "[Path]",
            luasnip = "[Snippet]",
          })[entry.source.name]
          return vim_item
        end,
      },
    })
  end,
}
