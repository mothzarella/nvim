-- mode is already in the status line
vim.o.showmode = false

-- make line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- enable mouse mode (can be useful for resizing)
vim.o.mouse = "a"

-- minimal number of screen lines to keep above and below the cursor
vim.o.scrolloff = 10

-- break indent
vim.o.breakindent = true

-- save undo history
vim.o.undofile = true

-- displays which-key popup sooner
vim.o.timeoutlen = 750

-- splits layout
vim.o.splitright = true
vim.o.splitbelow = true

-- enable nerd font
vim.g.have_nerd_font = true

-- current cursor line
vim.o.cursorline = true

vim.o.signcolumn = "yes:1"

-- tab width
local tab = 2

vim.o.tabstop = tab
vim.o.softtabstop = tab
vim.o.shiftwidth = tab
vim.o.expandtab = true

-- termguicolors
vim.o.termguicolors = true

-- vert splits fill charts
vim.o.fillchars = "vert:│"

-- status line always visible
vim.o.laststatus = 3

-- netrw remove bannerURL
vim.g.netrw_banner = 0

-- diagnostics
vim.diagnostic.config({
	virtual_text = true, -- show diagnostics in virtual text
	signs = true, -- show diagnostics in signs
	update_in_insert = true, -- update diagnostics in insert mode
	severity_sort = true, -- order by severity
})
