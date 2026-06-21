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

local dpp_config = vim.fn.stdpath("config") .. "/dpp.ts"

for _, s in ipairs({ denops_src, ext_installer_src, ext_lazy_src, protocol_git_src }) do
	vim.opt.runtimepath:prepend(s)
end

-- state.vim を source する前に、ディレクトリが消えたプラグインを検知して
-- state を事前削除する
local function drop_stale_state()
	local state_file = dpp_base .. "/nvim/state.vim"
	local ok, lines = pcall(vim.fn.readfile, state_file)
	if not ok or vim.tbl_isempty(lines) then
		return
	end
	local ok2, data = pcall(vim.fn.json_decode, lines[1])
	if not ok2 or type(data) ~= "table" or type(data[1]) ~= "table" then
		return
	end
	for _, p in pairs(data[1]) do
		if type(p) == "table" and type(p.path) == "string" and p.path ~= "" and vim.fn.isdirectory(p.path) == 0 then
			vim.fn.delete(state_file)
			vim.fn.delete(dpp_base .. "/nvim/startup.vim")
			return
		end
	end
end

-- 未インストールのプラグインをインストールする
local function install_missing()
	local missing = vim.tbl_filter(function(p)
		return vim.fn.isdirectory(p.rtp) == 0
	end, vim.tbl_values(dpp.get()))
	if #missing == 0 then
		return false
	end
	vim.fn["denops#server#wait_async"](function()
		dpp.async_ext_action("installer", "install")
	end)
	return true
end

-- state を再生成する
local function rebuild_state()
	vim.fn["denops#server#wait_async"](function()
		dpp.make_state(dpp_base, dpp_config)
	end)
end

-- make_state 完了時:
--   state を再ロードして未 clone のプラグインを install する
--   install が不要になった時点で「再起動してください」を通知する
--   install がある場合は updateDone → rebuild_state → ここに再度来て通知する
vim.api.nvim_create_autocmd("User", {
	pattern = "Dpp:makeStatePost",
	callback = function()
		dpp.load_state(dpp_base)
		if not install_missing() then
			vim.notify("dpp: Setup complete. Please restart Neovim.")
		end
	end,
})

-- clone/update 完了時:
--   clone 済みプラグインを runtimepath と startup.vim に反映するため state を再生成する
vim.api.nvim_create_autocmd("User", {
	pattern = "Dpp:ext:installer:updateDone",
	callback = rebuild_state,
})

-- 起動時のメイン処理
drop_stale_state()
local state_is_stale = dpp.load_state(dpp_base) or not vim.tbl_isempty(dpp.check_files(dpp_base))
if state_is_stale then
	-- state がない or 設定ファイルが変更された → makeStatePost で残りを処理
	rebuild_state()
else
	-- state は最新 → 未 clone のプラグインだけ処理
	install_missing()
end

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
