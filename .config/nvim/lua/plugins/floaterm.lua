return {
	"nvzone/floaterm",
	dependencies = { "nvzone/volt" },
	cmd = "FloatermToggle", -- lazy-load when first used
	opts = {
		border = true,
		size = { h = 90, w = 99 },

		terminals = {
			{ name = "Terminal" },
			{ name = "Opencode", cmd = "ollama launch opencode" },
		},

		mappings = {
			term = function(buf)
				-- Go to vim normal mode. -> then use toggle keybind to close terminal <leader>tt.
				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = buf, desc = "Exit terminal mode" })

				-- Next terminal
				vim.keymap.set({ "n", "t" }, "<C-h>", function()
					require("floaterm.api").cycle_term_bufs("prev")
				end, { buffer = buf, desc = "Previous Floaterm" })

				-- Previous terminal
				vim.keymap.set({ "n", "t" }, "<C-l>", function()
					require("floaterm.api").cycle_term_bufs("next")
				end, { buffer = buf, desc = "Next Floaterm" })
			end,
		},
	},
	keys = {
		{ "<leader>tt", "<cmd>FloatermToggle<CR>", desc = "Toggle Floaterm" },
	},
}
