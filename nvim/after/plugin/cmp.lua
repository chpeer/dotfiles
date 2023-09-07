local cmp = require('cmp')

cmp.setup({
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
})
