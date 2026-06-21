return {
    name = "hop.nvim",
    repo = "smoka7/hop.nvim",
    on_map = { nv = { "<Leader>hw", "<Leader>hl", "<Leader>hc" } },
    lua_source = function()
        require("hop").setup()
        vim.keymap.set({ "n", "v" }, "<Leader>hw", function()
            require("hop").hint_words()
        end, { desc = "Hop to word" })
        vim.keymap.set({ "n", "v" }, "<Leader>hl", function()
            require("hop").hint_lines()
        end, { desc = "Hop to line" })
        vim.keymap.set({ "n", "v" }, "<Leader>hc", function()
            require("hop").hint_char1()
        end, { desc = "Hop to char" })
    end,
}
