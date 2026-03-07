-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = true
vim.api.nvim_set_option("clipboard", "unnamed")

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
		{ import = "plugins.lsp" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Write current filepath to clipboard
local function insertFullPath()
	local filepath = vim.fn.expand("%")
	vim.fn.setreg("+", filepath) -- write to clipboard
end

-- Set keybind for copying current filepath to clipboard
vim.keymap.set(
	"n",
	"<leader>cs",
	insertFullPath,
	{ noremap = true, silent = true, desc = "Copy filepath to clipboard" }
)

vim.keymap.set("n", "<leader>rs", "LspRestart<CR>", { desc = "Restart lsp" })

-- LSP keybinds
vim.keymap.set("n", "<leader>sD", vim.lsp.buf.declaration, { desc = "Show declaration" })
vim.keymap.set("n", "<leader>dd", vim.lsp.buf.hover, { desc = "Display docs" })
vim.keymap.set("n", "<C-l>", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<C-h>", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

-- Diagnostics keybinds
vim.keymap.set("n", "<leader>dp", vim.diagnostic.open_float, { desc = "Display diagnostics" })

-- Window management
-- vim.keymap.set("n", "<leader>n", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
vim.keymap.set("n", "<leader>n", "<C-w>w", { desc = "Move to next window" }) -- Move to next window
vim.keymap.set("n", "<leader>N", "<C-w>h", { desc = "Move to prev window" }) -- Move to next window
vim.keymap.set("n", "<leader>q", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Save current messages to a file
function LogMessages()
	local logfile = vim.fn.expand("~/tmp/nvim_messages.log")
	local f = io.open(logfile, "w")
	if f then
		f:write(vim.fn.execute("messages"))
		f:close()
	end
	print("Messages saved to " .. logfile)
end

vim.api.nvim_create_user_command("LogMessages", LogMessages, { desc = "Log error messages to ~/tpm/nvim_messages.log" })

-- Custom gofmt write file on filesave if conform or mason formatter breaks.
--[[
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.go", "*.mod", "*.gomod"},
  callback = function(ev)
    local file = vim.fn.expand("<afile>:p")  -- Get the full path of the file
    vim.fn.system("gofmt -w " .. file)       -- Run gofmt
    vim.cmd("checktime " .. file)            -- Reload the file if it changed
  end
})
--]]
