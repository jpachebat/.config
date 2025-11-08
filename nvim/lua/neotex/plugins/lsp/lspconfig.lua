return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" }, -- Only load when a file is opened
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", event = "BufReadPost" }, -- Load when reading files
  },
  config = function()
    if not vim.lsp or type(vim.lsp.config) ~= "function" or type(vim.lsp.enable) ~= "function" then
      vim.notify("vim.lsp.config API is unavailable (requires Neovim 0.11+)", vim.log.levels.ERROR)
      return
    end

    -- Disable stylua LSP setup (using formatter instead via conform.nvim)
    -- This prevents the "Client stylua quit with exit code 2" error
    if vim.lsp.handlers and vim.lsp.handlers["textDocument/didOpen"] then
      local original_handler = vim.lsp.handlers["textDocument/didOpen"]
      vim.lsp.handlers["textDocument/didOpen"] = function(err, result, ctx, config)
        -- Skip stylua LSP client
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client and client.name == "stylua" then
          return
        end
        return original_handler(err, result, ctx, config)
      end
    end

    -- Prevent stylua from being started as an LSP server
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "stylua" then
          vim.lsp.stop_client(client.id)
        end
      end,
      desc = "Stop stylua LSP client (using formatter instead)"
    })

    -- Define diagnostics configuration before anything else
    local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = signs.Error,
          [vim.diagnostic.severity.WARN] = signs.Warn,
          [vim.diagnostic.severity.HINT] = signs.Hint,
          [vim.diagnostic.severity.INFO] = signs.Info,
        },
      },
      -- Optimize diagnostic updates - don't update in insert mode
      update_in_insert = false,
      -- Reduce diagnostic severity for better UX
      severity_sort = true,
    })

    -- On-attach function to set up keymaps when an LSP connects
    local on_attach = function(client, bufnr)
      -- Your existing on_attach code can go here
    end

    -- Minimal capabilities for LSP and optional blink.cmp integration
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local blink_ok, blink = pcall(require, "blink.cmp")
    if blink_ok then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    -- Helper to register + enable a server using the new vim.lsp.config API
    local function configure_server(name, opts)
      local config_opts = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach = on_attach,
      }, opts or {})

      vim.lsp.config(name, config_opts)
      vim.lsp.enable(name)
    end

    configure_server("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    configure_server("pyright", {})

    configure_server("texlab", {
      settings = {
        texlab = {
          build = { onSave = true },
          chktex = {
            onEdit = false,
            onOpenAndSave = false,
          },
          diagnosticsDelay = 300,
        },
      },
    })
  end,
}
