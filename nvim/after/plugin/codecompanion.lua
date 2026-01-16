local ok, ccomp = pcall(require,'codecompanion')
if not ok then
  return
end

ccomp.setup({
  interactions = {
    chat = {
      -- You can specify an adapter by name and model (both ACP and HTTP)
      adapter = {
        name = "gemini_cli",
      },
    },
    -- Or, just specify the adapter by name
    inline = {
      adapter = "gemini_cli",
    },
    cmd = {
      adapter = "gemini_cli",
    },
    background = {
      adapter = {
        name = "gemini_cli",
      },
    },
  },
})
