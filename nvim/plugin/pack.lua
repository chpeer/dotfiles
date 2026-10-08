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
  gh('hrsh7th/nvim-cmp'),
  gh('hrsh7th/cmp-nvim-lua'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/cmp-buffer'),
  gh('hrsh7th/cmp-path'),
  gh('hrsh7th/cmp-cmdline'),
  gh('saadparwaiz1/cmp_luasnip'),
  { src = gh('L3MON4D3/LuaSnip'), version = vim.version.range('2.0') },
  gh('rafamadriz/friendly-snippets'),

  -- Treesitter
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },

  -- Editing & Utilities
  gh('tpope/vim-fugitive'),
  gh('akinsho/git-conflict.nvim'),
  gh('lewis6991/gitsigns.nvim'),
  gh('windwp/nvim-autopairs'),
  gh('kevalin/mermaid.nvim'),
  gh('MeanderingProgrammer/render-markdown.nvim'),

  -- Debugging & Build
  gh('mfussenegger/nvim-dap'),
  gh('rcarriga/nvim-dap-ui'),
  gh('nvim-neotest/nvim-nio'),
  gh('theHamsta/nvim-dap-virtual-text'),
  gh('leoluz/nvim-dap-go'),
  gh('marcuscaisey/please.nvim'),
})
