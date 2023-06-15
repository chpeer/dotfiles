-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero')
local telescope_builtin = require('telescope.builtin')
local lspconfig = require('lspconfig')
lsp.preset('recommended')

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.ensure_installed({
  'lua_ls',
  'gopls',
  'pyright',
})

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

lspconfig.gopls.setup({
  settings = {
    gopls = {
      directoryFilters = { '-plz-out' },
      linksInHover = false,
      analyses = {
        unusedparams = true,
      },
      semanticTokens = true,
      codelenses = {
        gc_details = true,
      },
      staticcheck = true,
    },
  },
 root_dir = function(fname)
    local go_mod = vim.fs.find('go.mod', { upward = true, path = vim.fs.dirname(fname) })[1]
    if go_mod then
      return vim.fs.dirname(go_mod)
    end
    local plzconfig = vim.fs.find('.plzconfig', { upward = true, path = vim.fs.dirname(fname) })[1]
    local src = vim.fs.find('src', { upward = true, path = vim.fs.dirname(fname) })[1]
    if plzconfig and src then
      vim.env.GOPATH = string.format('%s:%s/plz-out/go', vim.fs.dirname(src), vim.fs.dirname(plzconfig))
      vim.env.GO111MODULE = 'off'
    end
    return vim.fn.getcwd()
  end,
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

-- disable completion with tab
-- this helps with copilot setup
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})


vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol)
vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_next)
vim.keymap.set("n", "]d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename)
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help )
vim.keymap.set('n', '<leader>ds', telescope_builtin.lsp_document_symbols)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations)
vim.keymap.set('n', 'gr', function()
  telescope_builtin.lsp_references({
    jump_type = 'never',
  })
end)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true,
})
