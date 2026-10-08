local ok, please = pcall(require, 'please')
if not ok then
  return
end

vim.keymap.set('n', '<leader>Pb', please.build)
vim.keymap.set('n', '<leader>Pr', please.run)
vim.keymap.set('n', '<leader>Pt', please.test)
vim.keymap.set('n', '<leader>Pct', function()
  please.test({ under_cursor = true })
end)

vim.keymap.set('n', '<leader>Pd', please.debug)
vim.keymap.set('n', '<leader>Pcd', function()
  please.debug({ under_cursor = true })
end)

vim.keymap.set('n', '<leader>Ph', please.history)
vim.keymap.set('n', '<leader>Pch', please.clear_history)
vim.keymap.set('n', '<leader>Pp', please.set_profile)
vim.keymap.set('n', '<leader>Pm', please.maximise_popup)
vim.keymap.set('n', '<leader>Pj', please.jump_to_target)
vim.keymap.set('n', '<leader>Py', please.yank)

