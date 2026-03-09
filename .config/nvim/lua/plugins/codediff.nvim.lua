return {
	"esmuellert/codediff.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },
	cmd = "CodeDiff",
	opts = {
		keymaps = {
			view = {
				quit = "q", -- Close diff tab
				toggle_explorer = "t", -- Toggle explorer visibility (explorer mode only)
				focus_explorer = "<leader>e", -- Focus explorer panel (explorer mode only)
				next_hunk = "<C-l>", -- Jump to next change
				prev_hunk = "<C-h>", -- Jump to previous change
				next_file = "<leader>n", -- Next file in explorer/history mode
				prev_file = "<leader>N", -- Previous file in explorer/history mode
				diff_get = "do", -- Get change from other buffer (like vimdiff)
				diff_put = "dp", -- Put change to other buffer (like vimdiff)
				open_in_prev_tab = "gf", -- Open current buffer in previous tab (or create one before)
				close_on_open_in_prev_tab = false, -- Close codediff tab after gf opens file in previous tab
				toggle_stage = "-", -- Stage/unstage current file (works in explorer and diff buffers)
				stage_hunk = "<leader>s", -- Stage hunk under cursor to git index
				unstage_hunk = "<leader>u", -- Unstage hunk under cursor from git index
				discard_hunk = "<leader>hr", -- Discard hunk under cursor (working tree only)
				hunk_textobject = "ih", -- Textobject for hunk (vih to select, yih to yank, etc.)
				show_help = "<leader>?", -- Show floating window with available keymaps
				align_move = "gm", -- Temporarily align moved code blocks across panes
				toggle_layout = "<leader>t", -- Toggle between side-by-side and inline layout
			},
		},
	},
}
