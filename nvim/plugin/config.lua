-- Suppress third-party plugin deprecation warnings
vim.deprecate = function() end

vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.scrolloff = 5

vim.o.mouse = "a"

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.termguicolors = true

-- do not show mode in cmd line as it is shown by lualist  plugin
vim.o.showmode = false

-- use unnamed register for system clipboard
vim.o.clipboard = 'unnamed'

-- enable spell checking
vim.o.spelllang= 'en_gb'
vim.o.spell = true

