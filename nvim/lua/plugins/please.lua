return {
  {
    "marcuscaisey/please.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
    },
    config = function(_, _)
      vim.keymap.set('n', '<leader>pj', require('please').jump_to_target)
      vim.keymap.set('n', '<leader>pb', require('please').build)
      vim.keymap.set('n', '<leader>pt', require('please').test)
      vim.keymap.set('n', '<leader>pct', function()
        require('please').test({ under_cursor = true })
      end)
      vim.keymap.set('n', '<leader>plt', function()
        require('please').test({ list = true })
      end)
      vim.keymap.set('n', '<leader>pft', function()
        require('please').test({ failed = true })
      end)
      vim.keymap.set('n', '<leader>pr', require('please').run)
      vim.keymap.set('n', '<leader>py', require('please').yank)
      vim.keymap.set('n', '<leader>pd', require('please').debug)
      vim.keymap.set('n', '<leader>pa', require('please').action_history)
      vim.keymap.set('n', '<leader>pp', require('please.runners.popup').restore)
    end, 
  },
}
