return {
	"folke/snacks.nvim",
	keys = {
		{
			"<leader>i",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>I",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
	},
	opts = {
		scratch = {
			name = "Notes",
		},
	},
}
