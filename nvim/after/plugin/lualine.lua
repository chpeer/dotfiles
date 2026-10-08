local lualine = require('lualine')

local function search_count()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local count = vim.fn.searchcount({ recompute = 1, maxcount = -1 })
  if count.total == 0 then
    return ''
  end
  return string.format('/%s [%d/%d]', vim.fn.getreg('/'), count.current, count.total)
end

lualine.setup({
  options = {
    theme = 'papercolor_dark',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      { 'branch', component_separators = { left = '' } },
      { 'diff', padding = { left = 0, right = 1 } },
    },
    lualine_c = {
      {
        'filetype',
        icon_only = true,
        component_separators = { left = '' },
        padding = { left = 1, right = 0 },
      },
      {
        'filename',
        path = 1,
      },
    },
    lualine_x = { search_count },
    lualine_y = {
      {
        'diagnostics',
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
        padding = { left = 0, right = 1 },
      },
    },
    lualine_z = {
      'location',
      { 'progress', padding = { left = 0, right = 1 } },
    },
  },
})

