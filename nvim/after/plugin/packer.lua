local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local ok, packer = pcall(require, 'packer')
if not ok then
  print('Packer not installed')
  return
end

packer.startup({
	function(use)
		use({ 'wbthomason/packer.nvim' })

		use({
			'pappasam/papercolor-theme-slim',
			config = function()
				vim.cmd('colorscheme PaperColorSlim')
			end
		})

		use ({
			'nvim-telescope/telescope.nvim',
			requires = { {'nvim-lua/plenary.nvim'} }
		})
		use({
			'neovim/nvim-lspconfig',
			requires = {
				'williamboman/mason.nvim',
				'williamboman/mason-lspconfig.nvim',
			},
		})
		use({
			'hrsh7th/nvim-cmp',
			requires = {
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-cmdline",
			}
		})
		use ({
			"L3MON4D3/LuaSnip",
			-- follow latest release.
			tag = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			-- install jsregexp (optional!).
			run = "make install_jsregexp"
		})
		use ({'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })
		use({
      'nvim-treesitter/nvim-treesitter',
       run = function()
        local install = require('nvim-treesitter.install')
        install.update({ with_sync = true })()
      end,
    })
		use({ 'mbbill/undotree' })
		use({ 'tpope/vim-fugitive' })
		use({ 'christoomey/vim-tmux-navigator'})
		use({ 'windwp/nvim-autopairs' })
		use({ 'ray-x/lsp_signature.nvim' })
		use({
			'marcuscaisey/please.nvim',
			requires = {
				'nvim-treesitter/nvim-treesitter',
				'mfussenegger/nvim-dap',
			},
		})
		use({ 'mfussenegger/nvim-dap' })
		use({ 'theHamsta/nvim-dap-virtual-text' })
		use({ 'rcarriga/nvim-dap-ui',
		requires = {
			"mfussenegger/nvim-dap",
      },
    })
    use({
      'akinsho/git-conflict.nvim', tag = '*',
    })
    use({ 'numToStr/Comment.nvim' })
    use({
      'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    })
    use({'chentoast/marks.nvim'})
    use({
      "gbprod/cutlass.nvim",
      config = function()
        require("cutlass").setup({
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        })
      end
    })

    if bootstrap then
      vim.api.nvim_create_autocmd('User', {
        group = vim.api.nvim_create_augroup('packer', { clear = true }),
        pattern = 'PackerComplete',
        desc = 'Load plugins and configuration after installation',
        callback = function()
          vim.ui.select(
            { 'Yes', 'No' },
            { prompt = "Installed plugins won't be configured until nvim is restarted. Exit?" },
            function(choice)
              if choice == 'Yes' then
                vim.cmd.quitall()
              end
            end
          )
        end,
        once = true,
      })
      packer.install()
    end
  end,
})
