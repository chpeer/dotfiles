local ok, lspconfig = pcall(require, 'lspconfig')
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

-- setup Go language server
lspconfig.gopls.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
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
    },
  },
  root_dir = function(fname)
    local plzconfig_dir = util.root_pattern('.plzconfig')(fname)
    if plzconfig_dir and vim.fs.basename(plzconfig_dir) == 'src' then
      vim.env.GOPATH = string.format('%s:%s/plz-out/go', vim.fs.dirname(plzconfig_dir), plzconfig_dir)
    end

    local gowork_or_gomod_dir = util.root_pattern('go.work')(fname) or util.root_pattern('go.mod')(fname)
    if gowork_or_gomod_dir then
      return gowork_or_gomod_dir
    end

    return vim.fn.getcwd()
  end,
})

-- setup LUA language server
lspconfig.lua_ls.setup({
  capabilities = cmp_nvim_lsp.default_capabilities(),
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
})

lspconfig.pylsp.setup({
  settings = {
    pylsp = {
      plugins = {
        autopep8 = { enabled = false },
        flake8 = { enabled = true },
        mccabe = { enabled = false },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        yapf = { enabled = false },
        jedi_completion = { enabled = true },
      },
    },
  },
  on_new_config = function(config, root_dir)
    local plzconfig_dir = util.root_pattern('.plzconfig')(root_dir)
    if not plzconfig_dir then
      return
    end
    config.settings.pylsp.plugins.jedi = {
      extra_paths = {
        plzconfig_dir,
        vim.fs.joinpath(plzconfig_dir, 'plz-out/gen'),
      },
    }
  end,
})

vim.lsp.set_log_level(vim.log.levels.OFF)

vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename)
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help )
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action)

