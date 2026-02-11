return {
	"andweeb/presence.nvim",
	event = "VeryLazy",
	config = function()
		require("presence"):setup({
			auto_update = true,
			neovim_image_text = "Neovim",
			workspace_text = "Coding",
			editing_text = "Editing files",
			reading_text = "Editing files",
			git_commit_text = "Writing commit messages",
			plugin_manager_text = "Managing plugins",

			-- enable buttons
			buttons = {
				{
					label = "My Dotfiles",
					url = "https://github.com/Nuuttif/config",
				},
				{
					label = "Neovim Docs",
					url = "https://neovim.io",
				},
			},
			debounce_timeout = 25,
		})
	end,
}
