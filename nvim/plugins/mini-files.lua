return {
    name = "mini.files",
    repo = "nvim-mini/mini.files",
    depends = { "snacks" },
    lazy = false,
    lua_source = function()
        require("mini.files").setup {
            mappings = {
                go_in_plus = "<CR>",
            },
            windows = {
                preview = true,
            },
        }
    end,
    lua_add = function()
        vim.keymap.set("n", "<Leader>e", function()
            require("mini.files").open()
        end)

        local snacks = require "snacks"
        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesActionRename",
            callback = function(event)
                snacks.rename.on_rename_file(event.data.from, event.data.to)
            end,
        })
    end,
}
