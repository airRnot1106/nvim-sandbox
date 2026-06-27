return {
    name = "nvim-surround",
    repo = "kylechui/nvim-surround",
    on_event = { "BufReadPre", "BufNewFile" },
    lua_source = function()
        require("nvim-surround").setup()
    end,
}
