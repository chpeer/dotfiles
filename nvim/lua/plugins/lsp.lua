local cmp = require('cmp')

return {
  {'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSUpdateSync" },
  ---@type TSConfig
  opts = {
    -- A list of parser names, or "all" (the four listed parsers should always be installed)
    ensure_installed = { "c", "lua", "vim"},

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = {
      -- `false` will disable the whole extension
      enable = true,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
  },
  config = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      ---@type table<string, boolean>
      local added = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if added[lang] then
          return false
        end
        added[lang] = true
        return true
      end, opts.ensure_installed)
    end
    require("nvim-treesitter.configs").setup(opts)
  end,
},
{
  'ray-x/lsp_signature.nvim',
  opts = {
    on_attach = function(_, bufnr)
      require "lsp_signature".on_attach({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = "rounded"
        }
      }, bufnr)
    end,
  },
},
{
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
  config = function(_, _)
    local lspconfig = require('lspconfig')
    local mason = require('mason')
    local mason_lspconfig = require('mason-lspconfig')
    local cmp_nvim_lsp = require('cmp_nvim_lsp')

    mason.setup()
    mason_lspconfig.setup({
      automatic_installation = true,
    })

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
        local go_mod = vim.fs.find('go.mod', { upward = true, path = vim.fs.dirname(fname) })[1]
        if go_mod then
          return vim.fs.dirname(go_mod)
        end

        -- Set GOPATH if we're in a directory called 'src' containing a .plzconfig
        local plzconfig_path = vim.fs.find('.plzconfig', { upward = true, path = vim.fs.dirname(fname) })[1]
        if plzconfig_path then
          local plzconfig_dir = vim.fs.dirname(plzconfig_path)
          if plzconfig_dir and vim.fs.basename(plzconfig_dir) == 'src' then
            vim.env.GOPATH = string.format('%s:%s/plz-out/go', vim.fs.dirname(plzconfig_dir), plzconfig_dir)
          end
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

    vim.lsp.set_log_level(vim.log.levels.OFF)

    vim.diagnostic.config({
      float = {
        source = 'always',
      },
      severity_sort = true,
    })

    vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticError' })
    vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticWarn' })
    vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticInfo' })
    vim.fn.sign_define('DiagnosticSignHint', { text = '󰌵', texthl = 'DiagnosticHint' })

    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help )
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
    vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action)
  end,
},
{
  'hrsh7th/nvim-cmp',
  dependencies = {
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
  },
  opts = {
    -- the sources to use for autocompletion
    sources = {
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'buffer' },
    },
    -- update the default sorting order so results don't magically jump around when the autocompletion window is open
    sorting = {
      comparators = {
        cmp.config.compare.sort_text,
        cmp.config.compare.score,
      },
    },
    mapping = {
      ['<c-space>'] = cmp.mapping.complete(),
      ['<cr>'] = cmp.mapping.confirm({ select = true }),
    }
  },
},
}
