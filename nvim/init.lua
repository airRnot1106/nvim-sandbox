-- enable the lua module cache before requiring anything else
vim.loader.enable()

-- disable unused default runtime plugins
-- tohtml
vim.g.loaded_2html_plugin = true

-- archive file open and browse
vim.g.loaded_gzip = true
vim.g.loaded_tar = true
vim.g.loaded_tarPlugin = true
vim.g.loaded_zip = true
vim.g.loaded_zipPlugin = true

-- vimball
vim.g.loaded_vimball = true
vim.g.loaded_vimballPlugin = true

-- netrw (mini.files is used instead; gx is native since 0.10)
vim.g.loaded_netrw = true
vim.g.loaded_netrwPlugin = true
vim.g.loaded_netrwSettings = true
vim.g.loaded_netrwFileHandlers = true

-- getlatestvimscript
vim.g.loaded_getscript = true
vim.g.loaded_getscriptPlugin = true

-- misc
vim.g.loaded_spellfile_plugin = true
vim.g.loaded_tutor_mode_plugin = true
vim.g.did_install_default_menus = true
vim.g.did_install_syntax_menu = true
vim.g.skip_loading_mswin = true
vim.g.loaded_rrhelper = true

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
