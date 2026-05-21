return {

	{
		"johmsalas/text-case.nvim",
		keys = {
			{
				"crs",
				function()
					require("textcase").current_word("to_snake_case")
				end,
				desc = "snake_case",
			},
			{
				"crc",
				function()
					require("textcase").current_word("to_camel_case")
				end,
				desc = "camelCase",
			},
			{
				"crm",
				function()
					require("textcase").current_word("to_pascal_case")
				end,
				desc = "PascalCase",
			},
			{
				"cru",
				function()
					require("textcase").current_word("to_upper_case")
				end,
				desc = "UPPER_CASE",
			},
			{
				"cr-",
				function()
					require("textcase").current_word("to_dash_case")
				end,
				desc = "dash-case",
			},
		},
	},
}
