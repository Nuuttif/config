return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  flavour = "macchiato",
  config = function()
    require("catppuccin").setup()

    -- setup must be called before loading
    vim.cmd.colorscheme "catppuccin"
  end,
}

