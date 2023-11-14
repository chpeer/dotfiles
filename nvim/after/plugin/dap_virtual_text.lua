local ok, virtual_text = pcall(require, 'nvim-dap-virtual-text')
if not ok then
  return
end

virtual_text.setup({})

