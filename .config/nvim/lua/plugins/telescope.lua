return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	-- or                              , branch = '0.1.x',
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local fb_actions = require("telescope").extensions.file_browser.actions
		local telescope = require("telescope")
		telescope.setup({
			defaults = {},
			extensions = {
				file_browser = {
					hijack_netrw = true,
					mappings = {
						["i"] = {
							-- your custom insert mode mappings
							["C-r"] = fb_actions.rename,
						},
						["n"] = {
							-- your custom normal mode mappings
						},
					},
				},
			},
		})
	end,
}
