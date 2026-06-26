-- Must be set before load_state() so startup.vim hooks expand <Leader> correctly
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local dpp_base = vim.fn.expand "~/.cache/dpp"
local gh = dpp_base .. "/repos/github.com"

local function src(env, fallback)
    return vim.env[env] or (gh .. fallback)
end

for _, s in ipairs {
    src("DPP_VIM_SRC", "/Shougo/dpp.vim"),
    src("DPP_DENOPS_SRC", "/vim-denops/denops.vim"),
    src("DPP_EXT_INSTALLER_SRC", "/Shougo/dpp-ext-installer"),
    src("DPP_EXT_LAZY_SRC", "/Shougo/dpp-ext-lazy"),
    src("DPP_PROTOCOL_GIT_SRC", "/Shougo/dpp-protocol-git"),
} do
    vim.opt.runtimepath:prepend(s)
end

require("dpp_bootstrap").setup {
    base = dpp_base,
    config = vim.fn.stdpath "config" .. "/dpp.ts",
}

vim.cmd "filetype indent plugin on"
vim.cmd "syntax on"

-- Options & keymaps
require "config"
