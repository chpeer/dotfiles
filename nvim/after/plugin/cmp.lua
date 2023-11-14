local ok, cmp = pcall(require, 'cmp')
if not ok then
  return
end

cmp.setup({
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
})
      
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
