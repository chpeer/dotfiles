local actions = require('telescope.actions')
local telescope = require('telescope')
local builtin = require('telescope.builtin')
local layout = require('telescope.actions.layout')
local transform_mod = require('telescope.actions.mt').transform_mod

local custom_actions = transform_mod({
  open_first_qf_item = function(_)
    vim.cmd.cfirst()
  end,
})

telescope.setup({
  defaults = {
    mappings = {
        i = {
            ['<c-h>'] = layout.toggle_preview,
            ['<c-q>'] = actions.smart_send_to_qflist + actions.open_qflist + custom_actions.open_first_qf_item,
        },
        n = {
            ['<c-h>'] = layout.toggle_preview,
            ['<c-c>'] = actions.close,
            ['<c-n>'] = actions.move_selection_next,
            ['<c-p>'] = actions.move_selection_previous,
            ['<c-q>'] = actions.smart_send_to_qflist + actions.open_qflist + custom_actions.open_first_qf_item,
        },
    },
  },
})

-- search for files <leader>pf
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
-- only search for git files
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
-- search for string
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
-- old files
vim.keymap.set('n', '<leader>pr', builtin.oldfiles, {})

