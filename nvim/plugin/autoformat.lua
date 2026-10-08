local augroup = vim.api.nvim_create_augroup('autoformat', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    if vim.fn.expand('%:e') == 'diff' then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd('keeppatterns keepjumps %s/\\s\\+$//e')
    vim.fn.winrestview(view)
  end,
  group = augroup,
  desc = 'Trim trailing whitespace',
})
