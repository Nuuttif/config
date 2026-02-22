return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"emmet_ls",
				"ts_ls",
				"gopls",
				"jdtls",
				-- "basedpyright",
			},
			automatic_installation = true,
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettierd", -- prettier formatter
				"eslint_d",
				"stylua", -- lua formatter
				"goimports",
				"gofumpt",
				"google-java-format",
				-- "isort", -- python import sorter
				-- "black", -- python formatter
			},
			-- integrations = {
			-- 	["mason-lspconfig"] = true,
			-- 	["mason-null-ls"] = true,
			-- 	["mason-nvim-dap"] = true,
			-- },
		})
	end,
}
