return {
  {
    "mbbill/undotree",
    config = function(_, _)
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end,
  }
}
