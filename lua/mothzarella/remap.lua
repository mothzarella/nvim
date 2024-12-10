vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- buffers
vim.keymap.set("n", "[b", "<cmd>bprev<CR>")
vim.keymap.set("n", "]b", "<cmd>bnext<CR>")

-- clear highlights on search when pressing <esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- force remap leap
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { noremap = false })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { noremap = false })
vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { noremap = false })

-- leap
-- force remap cuz s is used by vim by default:
-- s: delete char and enter insert mode
-- S: delete line and enter insert mode
-- gs: go to insert mode
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { noremap = false })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { noremap = false })
vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { noremap = false })

-- netrw
vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>")

-- yank (copy) to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

-- source netrw.vim
-- internal netrw remaps with vimscript
vim.cmd("source $HOME/.config/nvim/lua/mothzarella/netrw.vim")
