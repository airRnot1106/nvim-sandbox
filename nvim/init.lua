-- Must be set before load_state() so startup.vim hooks expand <Leader> correctly
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local dpp_base = vim.fn.expand("~/.cache/dpp")
local gh = dpp_base .. "/repos/github.com"

local function src(env, fallback)
	return vim.env[env] or (gh .. fallback)
end

local dpp_src = src("DPP_VIM_SRC", "/Shougo/dpp.vim")
local denops_src = src("DPP_DENOPS_SRC", "/vim-denops/denops.vim")
local ext_installer_src = src("DPP_EXT_INSTALLER_SRC", "/Shougo/dpp-ext-installer")
local ext_lazy_src = src("DPP_EXT_LAZY_SRC", "/Shougo/dpp-ext-lazy")
local protocol_git_src = src("DPP_PROTOCOL_GIT_SRC", "/Shougo/dpp-protocol-git")

vim.opt.runtimepath:prepend(dpp_src)

local dpp = require("dpp")

if dpp.load_state(dpp_base) then
	for _, s in ipairs({ denops_src, ext_installer_src, ext_lazy_src, protocol_git_src }) do
		vim.opt.runtimepath:prepend(s)
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "DenopsReady",
		once = true,
		callback = function()
			dpp.make_state(dpp_base, vim.fn.stdpath("config") .. "/dpp.ts")
		end,
	})
end

vim.api.nvim_create_autocmd("User", {
	pattern = "Dpp:makeStatePost",
	once = true,
	callback = function()
		vim.notify("dpp: キャッシュ生成完了。再起動してください。")
	end,
})

vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.updatetime = 100
vim.opt.clipboard = "unnamedplus"

-- Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
