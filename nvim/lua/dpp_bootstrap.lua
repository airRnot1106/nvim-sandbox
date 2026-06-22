local function State(base, config)
	local dpp = require("dpp")
	local state_file = base .. "/nvim/state.vim"
	local startup_file = base .. "/nvim/startup.vim"

	-- denops サーバの準備完了後に f を実行する
	local function when_ready(f)
		vim.fn["denops#server#wait_async"](f)
	end

	return {
		-- state.vim が、もう存在しないプラグインのディレクトリを指しているか
		-- そのまま source するとエラーになるので、load する前に検知する
		is_broken = function()
			local ok, lines = pcall(vim.fn.readfile, state_file)
			if not ok or vim.tbl_isempty(lines) then
				return false
			end
			local ok2, data = pcall(vim.fn.json_decode, lines[1])
			if not ok2 or type(data) ~= "table" or type(data[1]) ~= "table" then
				return false
			end
			for _, p in pairs(data[1]) do
				if
					type(p) == "table"
					and type(p.path) == "string"
					and p.path ~= ""
					and vim.fn.isdirectory(p.path) == 0
				then
					return true
				end
			end
			return false
		end,

		-- 壊れた state を捨てる
		discard = function()
			vim.fn.delete(state_file)
			vim.fn.delete(startup_file)
		end,

		-- キャッシュが陳腐化しているか
		-- load する state が無い、または監視中の設定ファイルが変更された場合に true を返す
		is_stale = function()
			local load_failed = dpp.load_state(base) ~= nil
			return load_failed or not vim.tbl_isempty(dpp.check_files(base))
		end,

		-- キャッシュ済み state を読み直す
		reload = function()
			dpp.load_state(base)
		end,

		-- state を再生成する
		rebuild = function()
			when_ready(function()
				dpp.make_state(base, config)
			end)
		end,

		-- 未 clone のプラグインをインストールする。開始したら true を返す
		install_missing = function()
			local missing = vim.tbl_filter(function(p)
				return vim.fn.isdirectory(p.rtp) == 0
			end, vim.tbl_values(dpp.get()))
			if #missing == 0 then
				return false
			end
			when_ready(function()
				dpp.async_ext_action("installer", "install")
			end)
			return true
		end,
	}
end

local M = {}

-- opts.base   … dpp のキャッシュディレクトリ
-- opts.config … dpp.ts のパス
function M.setup(opts)
	local state = State(opts.base, opts.config)

	-- state の再生成は非同期なので、フローはイベント駆動になる
	--
	--   rebuild() ──makeStatePost──▶ reload() + install_missing()
	--        ▲                                    │
	--        └─────────── updateDone ─────────────┘
	--
	--   install_missing() が false を返したら完了 → 再起動を促す

	vim.api.nvim_create_autocmd("User", {
		pattern = "Dpp:makeStatePost",
		callback = function()
			state.reload()
			if not state.install_missing() then
				vim.notify("dpp: Setup complete. Please restart Neovim.")
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "Dpp:ext:installer:updateDone",
		callback = state.rebuild,
	})

	-- 起動時のメイン処理
	if state.is_broken() then
		state.discard()
	end
	if state.is_stale() then
		state.rebuild()
	else
		state.install_missing()
	end
end

return M
