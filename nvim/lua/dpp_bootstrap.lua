local function State(base, config)
    local dpp = require "dpp"
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

        -- キャッシュ済み state を読み込み、startup.vim を source する
        -- load する state が無ければ true を返す
        load = function()
            return dpp.load_state(base)
        end,

        -- 監視中の設定ファイルが state より新しいか
        config_changed = function()
            return not vim.tbl_isempty(dpp.check_files(base))
        end,

        -- state を再生成する。ディスク上のキャッシュを更新する
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

    -- startup.vim（<unique> ダミーマッピングを定義する）を source できるのは
    -- 1 セッション 1 回だけ。2 回目を source すると E227 になる
    -- そのため state の再生成結果はセッション内に反映せず、再起動で取り込む
    local sourced = false
    local function source_once()
        if sourced then
            return
        end
        state.load()
        sourced = true
    end

    -- state 再生成の完了時
    --   初回（新規インストール時）はここで一度だけ startup.vim を反映し、
    --   不足プラグインを install する
    --   install 後の再生成や 2 回目以降は、再 source を避けて再起動を促すだけ
    vim.api.nvim_create_autocmd("User", {
        pattern = "Dpp:makeStatePost",
        callback = function()
            source_once()
            if not state.install_missing() then
                vim.notify "dpp: Setup complete. Please restart Neovim."
            end
        end,
    })

    -- clone/update 完了時 -> state を作り直す。次回起動で反映される
    vim.api.nvim_create_autocmd("User", {
        pattern = "Dpp:ext:installer:updateDone",
        callback = state.rebuild,
    })

    -- 起動時のメイン処理
    if state.is_broken() then
        state.discard()
    end

    local fresh = state.load()
    sourced = not fresh
    if fresh or state.config_changed() then
        -- state が無い or 設定が変わった -> 作り直して makeStatePost に委ねる
        state.rebuild()
    else
        -- state は最新 -> 未 clone のプラグインだけ入れる
        state.install_missing()
    end
end

return M
