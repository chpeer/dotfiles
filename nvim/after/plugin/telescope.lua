local actions = require('telescope.actions')
local telescope = require('telescope')
local builtin = require('telescope.builtin')
local layout = require('telescope.actions.layout')
local transform_mod = require('telescope.actions.mt').transform_mod
local entry_display = require('telescope.pickers.entry_display')

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
  pickers = {
    lsp_document_symbols = {
            entry_maker = function(entry)
        local displayer = entry_display.create({
          separator = ' ',
          items = {
            { width = 13 }, -- symbol type
            { remaining = true }, -- symbol name
          },
        })

        local make_display = function(entry)
          return displayer({
            { entry.symbol_type, 'CmpItemKind' .. entry.symbol_type },
            entry.symbol_name,
          })
        end

        return {
          valid = true,
          value = entry,
          ordinal = entry.text,
          display = make_display,
          filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr),
          lnum = entry.lnum,
          col = entry.col,
          symbol_name = entry.text:match('%[.+%]%s+(.*)'),
          symbol_type = entry.kind,
          start = entry.start,
          finish = entry.finish,
        }
      end,
    }
  }
})

-- use fuzzy finding
telescope.load_extension('fzf')

-- search for files <leader>pf
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
-- only search for git files
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
-- search for string
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
-- old files
vim.keymap.set('n', '<leader>pr', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols)
vim.keymap.set('n', 'gi', builtin.lsp_implementations)
vim.keymap.set('n', 'gd', builtin.lsp_definitions)
vim.keymap.set('n', 'gi', builtin.lsp_implementations)
vim.keymap.set('n', 'gr', function()
  builtin.lsp_references({ jump_type = 'never', include_current_line = true })
end)
