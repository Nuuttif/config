return {
	dir = vim.fn.expand("~/personal/proj/amadeus.nvim"), -- local plugin
	dev = true, -- enable dev mode
	dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
	config = function()
		require("amadeus").setup({
			llm = {
				model = "zen/minimax-m2.5-free",
			},
		})
	end,
}
