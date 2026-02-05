return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		local stats = require("lazy").stats()

		-- Function to setup dashboard dynamically
		local function setup_dashboard()
			-- Header
			dashboard.section.header.val = {
				"Have a chill coding sesh! 󰖨 ",
			}

			-- Buttons
			dashboard.section.buttons.val = {
				dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
				dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
				dashboard.button("q", "  Quit", ":qa<CR>"),
			}

			-- Footer
			local total_plugins = stats.count
			dashboard.section.footer.val = (function()
				local footer_datetime = os.date("  %d-%m-%Y    %H:%M:%S")
				local version = vim.version()
				local nvim_version_info = "    v" .. version.major .. "." .. version.minor .. "." .. version.patch
				return footer_datetime .. "    Plugins " .. total_plugins .. nvim_version_info
			end)()

			-- Calculate dynamic padding to push footer to bottom
			local height = vim.o.lines
			local used_lines = #dashboard.section.header.val + #dashboard.section.buttons.val + 1
			local footer_padding = math.max(0, height - used_lines - 9)

			-- Rebuild layout
			dashboard.config.layout = {
				{ type = "padding", val = 2 },
				dashboard.section.header,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				{ type = "padding", val = footer_padding },
				dashboard.section.footer,
			}

			alpha.setup(dashboard.config)
		end

		-- Initial setup
		setup_dashboard()

		-- Recalculate layout on window resize
		vim.api.nvim_create_autocmd("VimResized", {
			callback = function()
				setup_dashboard()
			end,
		})
	end,
}
