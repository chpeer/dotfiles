local telescope = require('telescope')

local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
local layout = require('telescope.actions.layout')
local transform_mod = require('telescope.actions.mt').transform_mod
local entry_display = require('telescope.pickers.entry_display')

local custom_actions = transform_mod({
  open_first_qf_item = function(_)
    vim.cmd.cfirst()
  end,
})

--- Shortens the given path by making it relative to the cwd, or replacing the home directory with ~ if not
---@param path string
---@return string
local function shorten_path(path)
  if path == vim.fn.getcwd() then
    return ''
  end
  return vim.fn.fnamemodify(path, ':~:.')
end

--- Builds an entry_maker which displays the given columns, each produced by `columns(entry)`.
---@param columns fun(entry: table): table[]
---@param ordinal fun(entry: table): string
---@return fun(entry: table): table
local function location_entry_maker(columns, ordinal)
  local displayer = entry_display.create({
    separator = ' ',
    items = { { remaining = true }, { remaining = true }, { remaining = true } },
  })
  return function(entry)
    return {
      valid = true,
      value = entry,
      ordinal = ordinal(entry),
      display = function()
        return displayer(columns(entry))
      end,
      bufnr = entry.bufnr,
      filename = entry.filename,
      lnum = entry.lnum,
      col = entry.col,
      text = entry.text,
      start = entry.start,
      finish = entry.finish,
    }
  end
end

local function file_line_dir(entry)
  return {
    vim.fs.basename(entry.filename),
    { entry.lnum .. ':' .. entry.col, 'TelescopeResultsLineNr' },
    { shorten_path(vim.fs.dirname(entry.filename)), 'TelescopeResultsLineNr' },
  }
end

local function file_and_text(entry)
  return entry.filename .. entry.text
end

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
        find_files = {
          layout_config = {
            width = 0.6,
            height = 0.9,
          },
          previewer = false,
        },
        oldfiles = {
          layout_config = {
            width = 0.6,
            height = 0.9,
          },
          previewer = false,
          cwd_only = true,
          path_display = function(_, path)
            return shorten_path(path)
          end,
        },
        buffers = {
          layout_config = {
            width = 0.6,
            height = 0.6,
          },
          previewer = false,
          sort_mru = true,
          ignore_current_buffer = true,
          mappings = {
            i = {
              ['<c-d>'] = 'delete_buffer',
            },
            n = {
              ['<c-d>'] = 'delete_buffer',
            },
          },
        },
        live_grep = {
          layout_config = {
            preview_width = 0.4,
          },
        },
        current_buffer_fuzzy_find = {
          layout_config = {
            preview_width = 0.4,
          },
        },
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
        },
        lsp_dynamic_workspace_symbols = {
          entry_maker = function(entry)
            local displayer = entry_display.create({
              separator = ' ',
              items = {
                { width = 13 }, -- symbol type
                { remaining = true }, -- symbol name
                { remaining = true }, -- filepath
              },
            })

            local make_display = function(entry)
              return displayer({
                { entry.symbol_type, 'CmpItemKind' .. entry.symbol_type },
                entry.symbol_name,
                { shorten_path(entry.filename), 'TelescopeResultsLineNr' },
              })
            end

            return {
              valid = true,
              value = entry,
              ordinal = entry.filename .. entry.text,
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
        },
        lsp_references = {
          entry_maker = location_entry_maker(file_line_dir, file_and_text),
        },
        lsp_implementations = {
          entry_maker = location_entry_maker(file_line_dir, file_and_text),
        },
        lsp_definitions = {
          entry_maker = location_entry_maker(function(entry)
            return {
              vim.fs.basename(entry.filename),
              { shorten_path(vim.fs.dirname(entry.filename)), 'TelescopeResultsLineNr' },
            }
          end, file_and_text),
        },
      }
})

-- use fuzzy finding
telescope.load_extension('fzf')

-- search for files <leader>pf
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
-- only search for git files
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
-- search for string across files
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
-- search for string in file with current focus
vim.keymap.set('n', '<leader>psf', builtin.current_buffer_fuzzy_find)
-- search for string in a files open in buffer
vim.keymap.set('n', '<leader>psb', function()
  builtin.live_grep({grep_open_files=true})
end)
-- old files
vim.keymap.set('n', '<leader>pr', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols)
vim.keymap.set('n', '<leader>ph', builtin.help_tags)
vim.keymap.set('n', '<leader>pd', builtin.diagnostics)
vim.keymap.set('n', '<leader>pk', builtin.keymaps)
vim.keymap.set('n', '<leader>p.', builtin.resume)
vim.keymap.set('n', 'gi', builtin.lsp_implementations)
vim.keymap.set('n', 'gd', builtin.lsp_definitions)
vim.keymap.set('n', 'gr', function()
  builtin.lsp_references({ jump_type = 'never', include_current_line = true })
end)

