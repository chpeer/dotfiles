local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
  return
end

configs.setup({
  -- A list of parser names, or "all" (the four listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "help" , "query", "go" },

  -- prevent error message saying parser not available for language help
  ignore_install = { "help" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,
  },
  indent = { 
    enable = true 
  },
})
