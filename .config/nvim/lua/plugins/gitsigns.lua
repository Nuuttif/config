return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup()
		vim.keymap.set("n", "<leader>dg", ":Gitsigns preview_hunk<CR>", {})
		vim.keymap.set("n", "<leader>db", ":Gitsigns toggle_current_line_blame<CR>", {})
	end,
}
