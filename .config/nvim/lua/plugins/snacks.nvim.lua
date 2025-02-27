return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		scope = { enabled = true },
		indent = { enabled = true },
		notifier = { enabled = true },
		input = { enabled = true },
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		-- picker = {
		-- 	enabled = true,
		-- 	ui_select = true, -- replace `vim.ui.select` with the snacks picker
		-- },
		-- explorer = { enabled = true },
		-- explorer = { enabled = true },
		-- dashboard = { enabled = true },
		-- bigfile = { enabled = true },
		-- input = { enabled = true },
		-- quickfile = { enabled = true },
		-- scroll = { enabled = true },
		-- statuscolumn = { enabled = true },
		-- words = { enabled = true },
	},
}
