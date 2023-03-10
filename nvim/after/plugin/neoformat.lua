local file_types_utils = require("utils.file_types")

vim.g.neoformat_enabled_python = { "black" }
vim.g.neoformat_enabled_lua = { "stylua" }
vim.g.neoformat_enabled_go = { "goimports" }
vim.g.neoformat_enabled_javascript = { "prettier" }
vim.g.neoformat_try_node_exe = 1

local auto_formatting_enabled = true

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		if file_types_utils.auto_format_file_types[vim.o.filetype] and auto_formatting_enabled then
			vim.cmd("Neoformat")
		end
	end,
	group = vim.api.nvim_create_augroup("neoformat", { clear = true }),
})

--- Toggles Neoformat auto-formatting on save
local function toggle_auto_neoformatting()
	if auto_formatting_enabled then
		auto_formatting_enabled = false
		print("Neoformat: disabled autoformatting")
	else
		auto_formatting_enabled = true
		print("Neoformat: enabled autoformatting")
	end
end

return {
	toggle_auto_neoformatting = toggle_auto_neoformatting,
}

