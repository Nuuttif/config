return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	build = "make BUILD_FROM_SOURCE=false",
	---@module 'avante'
	---@type avante.Config
	opts = {
		-- this file can contain specific instructions for your project
		-- instructions_file = "avante.md",
		-- for example
		-- provider = "copilot",
		enable_token_counting = true,
		provider = "ollama",
		auto_approve_tool_permissions = false,
		providers = {
			ollama = {

				model = "qwen2.5-coder-instruct-14b-16k",
				max_tokens = 4096,
				disable_tools = true,
			},
		},
		-- Define top-level key mappings for avante functionality
		mappings = {
			ask = "<Leader>aa",
			edit = "<Leader>ae",
			refresh = "<Leader>ar",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
		"folke/snacks.nvim", -- for input provider snacks
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
	keys = function(_, keys)
		---@type avante.Config
		local opts =
			require("lazy.core.plugin").values(require("lazy.core.config").spec.plugins["avante.nvim"], "opts", false)

		-- Default avante key mappings.
		local mappings = {
			{
				opts.mappings.ask,
				function()
					require("avante.api").ask()
				end,
				desc = "avante: ask",
				mode = { "n", "v" },
			},
			{
				opts.mappings.refresh,
				function()
					require("avante.api").refresh()
				end,
				desc = "avante: refresh",
				mode = "v",
			},
			{
				opts.mappings.edit,
				function()
					require("avante.api").edit()
				end,
				desc = "avante: edit",
				mode = { "n", "v" },
			},
			-- Define custom mappings here.
		}

		-- Filter out nil keys (for keys that return nil)
		mappings = vim.tbl_filter(function(m)
			return m[1] and #m[1] > 0
		end, mappings)

		return vim.list_extend(mappings, keys)
	end,
}
