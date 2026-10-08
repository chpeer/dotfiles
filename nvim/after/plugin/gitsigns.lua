require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buffer = bufnr })
    end
    map(']c', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gs.nav_hunk('next')
      end
    end)
    map('[c', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gs.nav_hunk('prev')
      end
    end)
    map('<leader>hs', gs.stage_hunk)
    map('<leader>hr', gs.reset_hunk)
    map('<leader>hp', gs.preview_hunk)
    map('<leader>hb', gs.blame_line)
  end,
})
