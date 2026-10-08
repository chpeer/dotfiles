local augroup = vim.api.nvim_create_augroup('autocmds', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
  desc = 'Highlight yanked text',
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = 'Restore cursor position',
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  callback = function()
    vim.opt_local.formatoptions:remove('o')
  end,
  desc = 'Do not continue comments with o/O',
})

vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<cr>')
