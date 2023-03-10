-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use({
	  'pappasam/papercolor-theme-slim',
	  config = function()
		  vim.cmd('colorscheme PaperColorSlim')
	  end
  })

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.1',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use('theprimeagen/harpoon')
  use('mbbill/undotree')
  use('tpope/vim-fugitive')
  use('christoomey/vim-tmux-navigator')
  use('sbdchd/neoformat')
  use('windwp/nvim-autopairs')
  use ('ray-x/lsp_signature.nvim')
  use({
      'marcuscaisey/please.nvim',
      requires = {
          'nvim-lua/plenary.nvim',
          'nvim-treesitter/nvim-treesitter',
          'mfussenegger/nvim-dap',
      },
  })
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v1.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},             -- Required
		  {'williamboman/mason.nvim'},           -- Optional
		  {'williamboman/mason-lspconfig.nvim'}, -- Optional

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},         -- Required
		  {'hrsh7th/cmp-nvim-lsp'},     -- Required
		  {'hrsh7th/cmp-buffer'},       -- Optional
		  {'hrsh7th/cmp-path'},         -- Optional
		  {'saadparwaiz1/cmp_luasnip'}, -- Optional
		  {'hrsh7th/cmp-nvim-lua'},     -- Optional

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},             -- Required
		  {'rafamadriz/friendly-snippets'}, -- Optional
	  }
  }
  use('mfussenegger/nvim-dap')
  use('theHamsta/nvim-dap-virtual-text')
  use { 'rcarriga/nvim-dap-ui',
    requires = {
       "mfussenegger/nvim-dap",
    },
  }
  use {
    'akinsho/git-conflict.nvim', tag = '*',
  }
  use('numToStr/Comment.nvim')
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
end)
