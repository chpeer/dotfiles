local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

mason.setup()
mason_lspconfig.setup({
  ensure_installed = { 'gopls', 'lua_ls', 'basedpyright' },
  -- servers are enabled explicitly below
  automatic_enable = false,
})

vim.lsp.config('please', {
  cmd = { 'plz', 'tool', 'lps' },
  filetypes = { 'please' },
  root_markers = { '.plzconfig' },
})

local augroup = vim.api.nvim_create_augroup('lspconfig_config', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/codeLens') then
      vim.lsp.codelens.enable(true, { bufnr = args.buf })
    end
    -- Neovim sets this to the LSP formatexpr, which breaks formatting with gq.
    vim.bo[args.buf].formatexpr = ''

    local function map(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf })
    end
    map('n', 'K', vim.lsp.buf.hover)
    map('n', '<leader>vws', vim.lsp.buf.workspace_symbol)
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action)
    map('n', '<leader>cr', vim.lsp.buf.rename)
    map('i', '<C-h>', vim.lsp.buf.signature_help)
  end,
  group = augroup,
})

vim.lsp.config('*', {
  capabilities = cmp_nvim_lsp.default_capabilities(),
})

-- setup Go language server
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      directoryFilters = { '-plz-out' },
      linksInHover = false,
      analyses = {
        unusedparams = true,
      },
      usePlaceholders = false,
      semanticTokens = true,
      codelenses = {
        gc_details = true,
      },
      staticcheck = true,
    }
  }
})


-- setup LUA language server
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      diagnostics = {
        -- Get the language server to recognize the 'vim' global
        globals = {'vim'},
      },
    },
  },
})

vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'basic',
      },
    },
  },
  ---@diagnostic disable-next-line: unused-local
  before_init = function(params, config)
    if not config.root_dir then
      return
    end
    if vim.uv.fs_stat(vim.fs.joinpath(config.root_dir, '.plzconfig')) then
      ---@diagnostic disable-next-line: param-type-mismatch
      config.settings.basedpyright = vim.tbl_deep_extend('force', config.settings.basedpyright, {
        analysis = {
          extraPaths = {
            vim.fs.joinpath(config.root_dir, 'plz-out/python/venv'),
          },
          exclude = { 'plz-out' },
        },
      })
    end
  end,
})

vim.lsp.log.set_level(vim.log.levels.WARN)

vim.lsp.enable({
  'gopls',
  'lua_ls',
  'please',
  'basedpyright',
})
