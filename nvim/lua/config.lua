local keymap = vim.keymap.set
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- appearance
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 2
vim.opt.showtabline = 2
vim.opt.cmdheight = 1
vim.opt.scrolloff = 12
vim.opt.termguicolors = true

autocmd("TextYankPost", {
    pattern = "*",
    group = augroup("highlight_yank", {}),
    callback = function()
        vim.hl.hl_op { higroup = "IncSearch", timeout = 200 }
    end,
})

-- indent
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- movement
vim.opt.wrap = true
vim.opt.whichwrap = "b,s,h,l,[,],<,>,~"

keymap("", "k", "gk", { silent = true })
keymap("", "j", "gj", { silent = true })
keymap("", "K", "10gk", { silent = true })
keymap("", "J", "10gj", { silent = true })
keymap("", "H", "0", { silent = true })
keymap("", "L", "$", { silent = true })

-- editing
vim.opt.virtualedit = "block"
vim.opt.showmatch = true

keymap("i", "jj", "<Esc>", { silent = true })
keymap("n", "<C-d>", "dd", { silent = true })
keymap("x", "<C-d>", "d", { silent = true })

-- clipboard
vim.opt.clipboard:append "unnamedplus"

keymap({ "n", "x" }, "x", '"_x', { silent = true })
keymap({ "n", "x" }, "s", '"_s', { silent = true })
keymap({ "n", "x" }, "c", '"_c', { silent = true })
keymap({ "n", "x" }, "d", '"_d', { silent = true })
keymap("n", "C", '"_C', { silent = true })
keymap("n", "D", '"_D', { silent = true })
keymap("n", "S", '"_S', { silent = true })
keymap("x", "p", '"_dP', { silent = true })

-- search
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })
keymap("n", "*", "*N", { silent = true })

-- files
vim.opt.fileencoding = "utf-8"
vim.opt.swapfile = false

keymap("", "<Leader>w", ":w<CR>", { silent = true })

-- misc
vim.opt.mouse = ""
vim.opt.wildoptions = "fuzzy"
vim.opt.helplang = "ja"
vim.opt.updatetime = 500
