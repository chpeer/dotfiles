local gh = function(repo)
  return 'https://github.com/' .. repo
end

-- Post-install/update build hooks
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack_hooks', { clear = true }),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind == 'install' or kind == 'update' then
      if name == 'telescope-fzf-native.nvim' then
        vim.system({ 'make' }, { cwd = ev.data.path })
      elseif name == 'LuaSnip' then
        vim.system({ 'make', 'install_jsregexp' }, { cwd = ev.data.path })
      elseif name == 'nvim-treesitter' then
        if not ev.data.active then
          vim.cmd.packadd('nvim-treesitter')
        end
        pcall(vim.cmd, 'TSUpdate')
      end
    end
  end,
})

-- Plugin specifications
vim.pack.add({
  -- Theme
  gh('pappasam/papercolor-theme-slim'),

  -- Navigation & UI
  gh('nvim-telescope/telescope.nvim'),
  gh('nvim-lua/plenary.nvim'),
  gh('nvim-telescope/telescope-fzf-native.nvim'),
  gh('christoomey/vim-tmux-navigator'),
  gh('nvim-lualine/lualine.nvim'),
  gh('nvim-tree/nvim-web-devicons'),
  gh('mbbill/undotree'),
  gh('chentoast/marks.nvim'),

  -- LSP & Completion
  gh('neovim/nvim-lspconfig'),
  gh('williamboman/mason.nvim'),
  gh('williamboman/mason-lspconfig.nvim'),
  gh('ray-x/lsp_signature.nvim'),
  gh('hrsh7th/nvim-cmp'),
  gh('hrsh7th/cmp-nvim-lua'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/cmp-buffer'),
  gh('hrsh7th/cmp-cmdline'),
  gh('saadparwaiz1/cmp_luasnip'),
  { src = gh('L3MON4D3/LuaSnip'), version = vim.version.range('2.0') },

  -- Treesitter
  gh('nvim-treesitter/nvim-treesitter'),

  -- Editing & Utilities
  gh('tpope/vim-fugitive'),
  gh('akinsho/git-conflict.nvim'),
  gh('windwp/nvim-autopairs'),
  gh('numToStr/Comment.nvim'),
  gh('gbprod/cutlass.nvim'),
  gh('olimorris/codecompanion.nvim'),
  gh('kevalin/mermaid.nvim'),

  -- Debugging & Build
  gh('mfussenegger/nvim-dap'),
  gh('rcarriga/nvim-dap-ui'),
  gh('nvim-neotest/nvim-nio'),
  gh('theHamsta/nvim-dap-virtual-text'),
  gh('marcuscaisey/please.nvim'),
})

-- Colorscheme configuration
vim.cmd('colorscheme PaperColorSlim')
vim.cmd('set guicursor=n-v-sm:block-Cursor,i-ci-c-ve:ver25-Cursor,r-cr-o:hor20-Cursor')
vim.opt.winborder = 'rounded'

-- Inline plugin setup
require('cutlass').setup({})
