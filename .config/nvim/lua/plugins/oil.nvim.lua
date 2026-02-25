return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		default_file_explorer = true, -- replace netrw
		delete_to_trash = false,
		skip_confirm_for_simple_edits = false,

		view_options = {
			show_hidden = true,
		},
	},

	dependencies = {
		{ "nvim-tree/nvim-web-devicons", opts = {} },
	},

	lazy = false,

	config = function(_, opts)
		require("oil").setup(opts)

		-- Open parent directory with "-"
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

		-- Open Oil at project root (LSP/Git/startup)
		vim.keymap.set("n", "<leader>sf", function()
			local root = nil

			-- Try LSP root first
			for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
				local lsp_root = client.config.root_dir
				if lsp_root and vim.loop.fs_stat(lsp_root) then
					root = lsp_root
					break
				end
			end

			-- Try Git root if LSP root not found
			if not root then
				local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if git_root and vim.loop.fs_stat(git_root) then
					root = git_root
				end
			end

			-- Fallback to CWD if nothing else
			root = root or vim.fn.getcwd(-1, -1)

			require("oil").open(root)
		end, { desc = "Open Oil at project root (LSP → Git → CWD)" })
	end,
}
