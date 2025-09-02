local ok = pcall(require, 'lspconfig')
if not ok then
  return
end

local ok, mason = pcall(require, 'mason')
if not ok then
  return
end

local ok, mason_lspconfig = pcall(require,'mason-lspconfig')
if not ok then
  return
end

local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not ok then
  return
end

local util = require('lspconfig.util')
local configs = require('lspconfig.configs')

mason.setup()
mason_lspconfig.setup({
  automatic_installation = true,
})

util.default_config = vim.tbl_deep_extend('force', util.default_config, {
  capabilities = cmp_nvim_lsp.default_capabilities(),
})

configs.please = {
  default_config = {
    cmd = { 'plz', 'tool', 'lps' },
    filetypes = { 'please' },
    root_dir = util.root_pattern('.plzconfig'),
  },
}

-- codelense autocmd
local augroup = vim.api.nvim_create_augroup('lspconfig_config', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.codeLensProvider then
      vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'BufWritePost', 'CursorHold' }, {
        callback = vim.lsp.codelens.refresh,
        group = augroup,
        buffer = args.buf,
        desc = 'Refresh codelenses automatically in this buffer',
      })
    end
  end,
  group = augroup,
})

vim.lsp.enable({
  'gopls',
  'lua_ls',
  'please',
  'basedpyright',
})


-- setup Go language server
vim.lsp.config.gopls = {
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
}


-- setup LUA language server
vim.lsp.config.lua_ls = {
  on_attach = function(_, bufnr)
    -- This gets set automatically by nvim which breaks formatting with gq.
    vim.bo[bufnr].formatexpr = ''
  end,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
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
}

vim.lsp.basedpyright = {
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
}


vim.lsp.config('*', {
  capabilities = cmp_nvim_lsp.default_capabilities(),
})

vim.lsp.set_log_level(vim.log.levels.OFF)

vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename)
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help )
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action)

