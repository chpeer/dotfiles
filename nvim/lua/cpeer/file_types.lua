local file_types_utils = require("utils.file_types")

vim.filetype.add({
	extension = {
		build_defs = "please",
		build_def = "please",
		build = "please",
		plz = "please",
	},
	filename = {
		["BUILD"] = "please",
	},
})

file_types_utils.setup({
	lua = {
		text_width = 120,
		format_on_save = true,
	},
	python = {
		text_width = 100,
		format_on_save = true,
	},
	go = {
		text_width = 120,
		indent_with_tabs = true,
		format_on_save = true,
	},
	proto = {
		text_width = 100,
		format_on_save = true,
		spellcheck = true,
	},
	javascript = {
		text_width = 80,
		format_on_save = true,
		tab_size = 2,
	},
	gitcommit = {
		spellcheck = true,
	},
})

