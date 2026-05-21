return {
	{
		"folke/lazydev.nvim",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		ft = "lua",
		cmd = "LazyDev",
		opts = {
			library = {
				-- luvit/vim.uv types
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				-- LazyVim framework types
				{ path = "LazyVim", words = { "LazyVim" } },
				-- lazy.nvim plugin spec types
				{ path = "lazy.nvim", words = { "LazySpec", "LazyPlugin", "LazyConfig" } },
				-- snacks types
				{ path = "snacks.nvim", words = { "Snacks" } },
				-- DAP types
				{ path = "nvim-dap", words = { "dap" } },
				-- DAP-UI types
				{ path = "nvim-dap-ui", words = { "dapui" } },
				-- Your own config modules (self-referential completion)
				{ path = vim.fn.stdpath("config") .. "/lua" },
			},
		},
	},
	{
		"Bilal2453/luvit-meta",
		lazy = true,
	},
}
