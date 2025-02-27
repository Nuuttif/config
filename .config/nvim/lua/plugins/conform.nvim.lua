return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				go = { "goimports", "gofumpt" },
				lua = { "stylua" },
				javascript = { "prettierd", "eslint_d" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				-- Conform will run multiple formatters sequentially
				-- python = { "isort", "black" },
				-- Conform will run the first available formatter
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})
	end,
}
