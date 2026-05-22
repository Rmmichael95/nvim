-- lua/overseer/template/cmake.lua
-- Two-step: configure (cmake -B build) then build (cmake --build build)
return {
	name = "cmake",

	params = {
		subcommand = {
			type = "enum",
			choices = { "build", "configure", "clean", "test" },
			default = "build",
			desc = "CMake task",
			order = 1,
		},
		build_type = {
			type = "enum",
			choices = { "Debug", "Release", "RelWithDebInfo" },
			default = "Debug",
			desc = "CMAKE_BUILD_TYPE",
			order = 2,
		},
		jobs = {
			type = "number",
			default = 0, -- 0 = auto (nproc)
			desc = "Parallel jobs (0 = auto)",
			optional = true,
			order = 3,
		},
	},

	builder = function(params)
		local build_dir = "build"
		local j = params.jobs > 0 and tostring(params.jobs) or tostring(vim.fn.system("nproc"):gsub("%s+", ""))

		local cmd, cmd_args

		if params.subcommand == "configure" then
			cmd = "cmake"
			cmd_args = { "-B", build_dir, "-DCMAKE_BUILD_TYPE=" .. params.build_type }
		elseif params.subcommand == "build" then
			cmd = "cmake"
			cmd_args = { "--build", build_dir, "--parallel", j }
		elseif params.subcommand == "clean" then
			cmd = "cmake"
			cmd_args = { "--build", build_dir, "--target", "clean" }
		elseif params.subcommand == "test" then
			cmd = "ctest"
			cmd_args = { "--test-dir", build_dir, "--output-on-failure", "-j", j }
		end

		return {
			cmd = { cmd },
			args = cmd_args,
			components = {
				{
					"on_output_quickfix",
					open_on_match = true,
					set_diagnostics = true,
					-- clang/gcc: file.cpp:10:5: error: ...
					errorformat = "%f:%l:%c: %t%*[^ ] %m,%f:%l: %t%*[^ ] %m",
				},
				"on_result_diagnostics",
				{ "on_complete_notify", statuses = { "FAILURE" } },
				"default",
			},
		}
	end,

	condition = {
		callback = function()
			return vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 1
		end,
	},
}
