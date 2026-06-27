return {
    name = "nvim-autopairs",
    repo = "windwp/nvim-autopairs",
    on_event = { "BufReadPre", "BufNewFile" },
    lua_source = function()
        require("nvim-autopairs").setup()
    end,
}
