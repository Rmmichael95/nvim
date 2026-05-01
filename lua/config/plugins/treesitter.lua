return {
	{
		"romus204/tree-sitter-manager.nvim",
		lazy = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
		-- Note: You must have the `tree-sitter` CLI and a C compiler installed on your system
		config = function()
			require("tree-sitter-manager").setup()
		end,
	},
	{
		"cameron-wags/rainbow_csv.nvim",
		config = true,
		ft = {
			"csv",
			"tsv",
			"csv_semicolon",
			"csv_whitespace",
			"csv_pipe",
			"rfc_csv",
			"rfc_semicolon",
		},
		cmd = {
			"RainbowDelim",
			"RainbowDelimSimple",
			"RainbowDelimQuoted",
			"RainbowMultiDelim",
		},
	},
}
