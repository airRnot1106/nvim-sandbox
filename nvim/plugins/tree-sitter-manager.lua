return {
    name = "tree-sitter-manager",
    repo = "romus204/tree-sitter-manager.nvim",
    on_event = { "VimEnter" },
    lua_source = function()
        require("tree-sitter-manager").setup {
            ensure_installed = {
                "elixir",
                "gleam",
                "go",
                "javascript",
                "json",
                "kdl",
                "lua",
                "nix",
                "pkl",
                "python",
                "ruby",
                "rust",
                "toml",
                "typescript",
                "typst",
                "yaml",
            },
        }
    end,
}
