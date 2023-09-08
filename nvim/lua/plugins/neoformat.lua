return {
  {
    "sbdchd/neoformat",
    config = function(_, _)
      vim.g.neoformat_enabled_python = { "black" }
      vim.g.neoformat_enabled_lua = { "stylua" }
      vim.g.neoformat_enabled_go = { "goimports" }
      vim.g.neoformat_enabled_javascript = { "prettier" }
      vim.g.neoformat_try_node_exe = 1
    end,
  },
}
