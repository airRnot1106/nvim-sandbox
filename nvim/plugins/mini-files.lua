return {
    name = "mini.files",
    repo = "nvim-mini/mini.files",
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
    end,
}
