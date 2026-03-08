return {
	dir = vim.fn.expand("~/personal/proj/amadeus.nvim"), -- local plugin
	dev = true, -- enable dev mode
	dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim", "nvim-telescope/telescope.nvim" },

	config = function()
		require("amadeus").setup({
			log_level = "info",
			llm = {
				-- provider = "opencode",
				-- model = "zen/big-pickle",
				-- model = "zen/minimax-m2.5-free",
				-- model = "bailian-coding-plan/glm-5",

				-- dry_run = true,
				provider = "claude",
				model = "glm-5",
				providers = {
					{ name = "claude", models = { "glm-5" } },
					{
						name = "opencode",
						models = {
							"bailian-coding-plan/glm-5",
							"zen/big-pickle",
							"zen/minimax-m2.5-free",
							"opencode-go/minimax-m2.5",
							"opencode-go/kimi-k2.5",
						},
					},
				},
				-- model = "qwen3.5-plus",
				-- model = "kimi-k2.5",
			},
		})
	end,
}
