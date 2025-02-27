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

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader><Tab>", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>ss", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Telescope buffers" })

-- Telescope lsp
vim.keymap.set("n", "<leader>st", builtin.lsp_type_definitions, { desc = "Telescope type definitions" })
vim.keymap.set("n", "<leader>si", builtin.lsp_implementations, { desc = "Telescope implementations" })
vim.keymap.set("n", "<leader>sd", builtin.lsp_definitions, { desc = "Telescope definitions" })
vim.keymap.set("n", "<leader>sD", vim.lsp.buf.declaration, { desc = "Show declaration" })

vim.keymap.set("n", "<leader>dd", vim.lsp.buf.hover, { desc = "Display docs" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.open_float, { desc = "Display diagnostics" })
vim.keymap.set("n", "<leader>]p", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>[p", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

vim.keymap.set("n", "<leader>rs", "LspRestart<CR>", { desc = "Restart lsp" })

-- Telescope git
vim.keymap.set("n", "<leader>sg", builtin.git_status, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>b", builtin.git_branches, { desc = "Telescope buffers" })

-- Telescope file-browser
vim.keymap.set("n", "<space>sf", ":Telescope file_browser<CR>")

-- Display directory tree
vim.keymap.set("n", "<leader>t", function()
	vim.cmd("!tree")
end, { desc = "Show directory tree" })

-- File creation
vim.keymap.set("n", "<leader>cd", function()
	local file = vim.fn.input("Create dir: ")
	if file ~= "" then
		vim.cmd("!mkdir " .. file)
	end
end, { desc = "Create directory" })

vim.keymap.set("n", "<leader>cf", function()
	local file = vim.fn.input("Create file: ")
	if file ~= "" then
		vim.cmd("!touch " .. file)
	end
end, { desc = "Create file" })

-- window management
vim.keymap.set("n", "<leader>n", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
vim.keymap.set("n", "<leader>l", "<C-w>w", { desc = "Move to next window" }) -- Move to next window
vim.keymap.set("n", "<leader>j", "<C-w>w", { desc = "Move to next window" }) -- Move to next window
vim.keymap.set("n", "<leader>q", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

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
