local ts = require('nvim-treesitter')

local parsers = { 'c', 'lua', 'vim', 'query', 'go', 'sql', 'mermaid', 'markdown', 'markdown_inline' }
ts.install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end
    -- install missing parser on demand (async), then start highlighting
    local function start()
      if vim.api.nvim_buf_is_valid(args.buf) and pcall(vim.treesitter.start, args.buf, lang) then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end
    if pcall(vim.treesitter.language.add, lang) then
      start()
    elseif vim.tbl_contains(ts.get_available(), lang) then
      ts.install(lang):await(start)
    end
  end,
})
