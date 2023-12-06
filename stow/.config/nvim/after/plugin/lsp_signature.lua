local ok, lsp_signature = pcall(require, 'lsp_signature')
if not ok then
  return
end

local cfg = {
   on_attach = function(client, bufnr)
    require "lsp_signature".on_attach({
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      handler_opts = {
        border = "rounded"
      }
    }, bufnr)
  end,
}  -- add your config here
lsp_signature.setup(cfg)

