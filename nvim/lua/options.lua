local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ui
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

-- indentation
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- editing
vim.opt.wrap = true
vim.opt.whichwrap = "b,s,h,l,[,],<,>,~"
vim.opt.virtualedit = "block"
vim.opt.showmatch = true

-- files
vim.opt.fileencoding = "utf-8"
vim.opt.swapfile = false

-- input
vim.opt.clipboard:append "unnamedplus"
vim.opt.mouse = ""

-- completion & command line
vim.opt.wildoptions = "fuzzy"

-- misc
vim.opt.helplang = "ja"
vim.opt.updatetime = 500
