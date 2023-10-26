local cmp = require('cmp')

return {
  {'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function ()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "go"},
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
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
        local gowork_or_gomod_dir = util.root_pattern('go.work')(fname) or util.root_pattern('go.mod')(fname)
        if gowork_or_gomod_dir then
          return gowork_or_gomod_dir
        end

        local plzconfig_dir = util.root_pattern('.plzconfig')(fname)
        if plzconfig_dir and vim.fs.basename(plzconfig_dir) == 'src' then
          vim.env.GOPATH = string.format('%s:%s/plz-out/go', vim.fs.dirname(plzconfig_dir), plzconfig_dir)
          vim.env.GO111MODULE = 'off'
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
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-cmdline",
  },
  opts = {
    -- the sources to use for autocompletion
    sources = {
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'buffer' },
      { name = 'luasnip' },
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
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
      ['<c-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<c-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<tab>'] = function(fallback)
        if cmp.visible() then
          cmp.abort()
        else
          fallback()
        end
      end,
      ['<c-n>'] = function()
        if cmp.visible() then
          cmp.select_next_item()
        end
      end,
      ['<c-p>'] = function()
        if cmp.visible() then
          cmp.select_prev_item()
        end
      end,
    },
    confirmation = {
      default_behavior = cmp.ConfirmBehavior.Replace,
    },
    config = function(_, _)
      -- `/` cmdline setup.
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
      -- `:` cmdline setup.
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' }
            }
          }
        })
      })
    end,
  },
},
{
  "L3MON4D3/LuaSnip",
  -- follow latest release.
  version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- install jsregexp (optional!).
  build = "make install_jsregexp"
},
}
