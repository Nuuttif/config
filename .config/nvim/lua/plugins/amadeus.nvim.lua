return {
	dir = vim.fn.expand("~/personal/proj/amadeus.nvim"), -- local plugin
	dev = true, -- enable dev mode
	dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim", "nvim-telescope/telescope.nvim" },

	config = function()
		require("amadeus").setup({
			llm = {
				-- provider = "opencode",
				-- model = "zen/big-pickle",
				-- model = "zen/minimax-m2.5-free",
				-- model = "bailian-coding-plan/glm-5",

				provider = "claude",
				model = "qwen3.5-plus",
				-- model = "kimi-k2.5",
			},
		})
	end,
}
