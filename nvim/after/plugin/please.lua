local ok, please = pcall(require, 'please')
if not ok then
  return
end

vim.keymap.set('n', '<leader>pj', please.jump_to_target)
vim.keymap.set('n', '<leader>pb', please.build)
vim.keymap.set('n', '<leader>pt', please.test)
vim.keymap.set('n', '<leader>pct', function()
    please.test({ under_cursor = true })
end)
vim.keymap.set('n', '<leader>plt', function()
    please.test({ list = true })
end)
vim.keymap.set('n', '<leader>pft', function()
    please.test({ failed = true })
end)
vim.keymap.set('n', '<leader>pr', please.run)
vim.keymap.set('n', '<leader>py', please.yank)
vim.keymap.set('n', '<leader>pd', please.debug)
vim.keymap.set('n', '<leader>pa', please.action_history)
vim.keymap.set('n', '<leader>pp', require('please.runners.popup').restore)

