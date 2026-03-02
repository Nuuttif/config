return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local telescope = require("telescope")

		telescope.setup({
			defaults = {
				layout_strategy = "vertical",
				layout_config = {
					vertical = {
						preview_cutoff = 0,
						preview_height = 0.6,
					},
					height = 0.95,
					width = 0.95,
				},
			},
			extensions = {
				file_browser = {
					hijack_netrw = true,
					mappings = {
						["i"] = {
							-- your custom insert mode mappings
						},
						["n"] = {
							-- your custom normal mode mappings
						},
					},
				},
			},
		})

		-- Telescope
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader><Tab>", builtin.find_files, { desc = "Telescope find files" })
		vim.keymap.set("n", "<leader>ss", builtin.live_grep, { desc = "Telescope live grep" })
		vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Telescope buffers" })

		-- Telescope lsp
		vim.keymap.set("n", "<leader>st", builtin.lsp_type_definitions, { desc = "Telescope type definitions" })
		vim.keymap.set("n", "<leader>si", builtin.lsp_implementations, { desc = "Telescope implementations" })
		vim.keymap.set("n", "<leader>sd", builtin.lsp_definitions, { desc = "Telescope definitions" })

		-- Telescope git
		vim.keymap.set("n", "<leader>sg", builtin.git_status, { desc = "Telescope git status" })
		vim.keymap.set("n", "<leader>b", builtin.git_branches, { desc = "Telescope git branches" })
	end,
}
