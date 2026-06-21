return {
	name = "mini.files",
	repo = "echasnovski/mini.files",
	lua_source = function()
		require("mini.files").setup()
	end,
	lua_add = function()
		vim.keymap.set("n", "<Leader>e", function()
			require("mini.files").open()
		end)
	end,
}
