local ok, mermaid = pcall(require, 'mermaid')
if not ok then
  return
end

mermaid.setup({
  preview = {
    port = 9090, -- fixed port so a single SSH -L forward always works
  },
})
