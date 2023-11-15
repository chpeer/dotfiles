vim.g.mapleader = " "

-- remap file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- show the errors for the current line in a popup
vim.keymap.set('n', 'dK', vim.diagnostic.open_float)

-- jump between warnings/errors
vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.WARN } })
end)
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.WARN } })
end)

-- jump between diagnostic messages (info, error, tips, etc)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
