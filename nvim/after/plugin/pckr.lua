local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

-- define plugins to load
require('pckr').add{
 {
	  'pappasam/papercolor-theme-slim',
	  config = function()
		  vim.cmd('colorscheme PaperColorSlim')
	  end
  };

  {
	  'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
	  requires = {'nvim-lua/plenary.nvim'},
  };

  {
	  'neovim/nvim-lspconfig',
	  requires = {
		  'williamboman/mason.nvim',
		  'williamboman/mason-lspconfig.nvim',
	  },
  };

  {
    'hrsh7th/nvim-cmp',
    requires = {
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
    },
  };

  {
    "L3MON4D3/LuaSnip",
    tag = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    run = "make install_jsregexp",
  };

  {
    'nvim-telescope/telescope-fzf-native.nvim', 
    run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
  };

  {
    'nvim-treesitter/nvim-treesitter', 
    run = ':TSUpdate',
  };

  'mbbill/undotree';
  'tpope/vim-fugitive';
  'christoomey/vim-tmux-navigator';
  'sbdchd/neoformat';
  'windwp/nvim-autopairs';
  'ray-x/lsp_signature.nvim';

  {
      'marcuscaisey/please.nvim',
      requires = {
          'nvim-treesitter/nvim-treesitter',
          'mfussenegger/nvim-dap',
      },
  };

  'mfussenegger/nvim-dap';
  'theHamsta/nvim-dap-virtual-text';

  { 
    'rcarriga/nvim-dap-ui',
    requires = {
       "mfussenegger/nvim-dap",
    },
  };

  {
    'akinsho/git-conflict.nvim',
    tag = '*',
  };

  'numToStr/Comment.nvim';

  {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  };

  'chentoast/marks.nvim';
}
