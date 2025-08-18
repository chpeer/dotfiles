local ok, cutlass = pcall(require,'cutlass')
if not ok then
  return
end

cutlass.setup({
  -- by rather than sending to blackhole register, send to x instead
 registers = {
    select = "x",
    delete = "x",
    change = "x",
  },
})
