-- dapper.lua
-- NOTE: dap and debug are invalid filenames.
return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'rcarriga/nvim-dap-ui',
		'leoluz/nvim-dap-go',
	},
	config = function()
		-- See `:help dap.txt`
		-- See `:help dap-configuration`
		local dap, dapui, dapgo = require("dap"), require("dapui"), require("dap-go")

		vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
		vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
		vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
		vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
		vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
		vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
		vim.keymap.set('n', '<leader>B', function()
			dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
		end, { desc = 'Debug: Set Breakpoint' })

		dapui.setup({
			controls = {
				element = "repl",
				enabled = true,
				icons = {
					disconnect = "🔌",
					pause = "⏸️",
					play = "▶️",
					run_last = "🔁",
					step_back = "⬅️",
					step_into = "↘️",
					step_out = "↗️",
					step_over = "➡️",
					terminate = "⏹️",
				}
			},
			element_mappings = {},
			expand_lines = true,
			floating = {
				border = "single",
				mappings = {
					close = { "q", "<Esc>" }
				}
			},
			force_buffers = true,
			icons = {
				collapsed = "►",
				current_frame = "*",
				expanded = "▼"
			},
			layouts = { {
				elements = { {
					id = "scopes",
					size = 0.25
				}, {
					id = "breakpoints",
					size = 0.25
				}, {
					id = "stacks",
					size = 0.25
				}, {
					id = "watches",
					size = 0.25
				} },
				position = "left",
				size = 40
			}, {
				elements = { {
					id = "repl",
					size = 0.5
				}, {
					id = "console",
					size = 0.5
				} },
				position = "bottom",
				size = 10
			} },
			mappings = {
				edit = "e",
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				repl = "r",
				toggle = "t"
			},
			render = {
				indent = 1,
				max_value_lines = 100
			}
		})
		dap.listeners.before.attach["dapui_config"] = dapui.open
		dap.listeners.before.launch["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		dapgo.setup()

		-- Custom function to run a specific go test
		function DebugGoTest(testpath, testname)
			dap.run({
				type = "go",
				name = testname,
				request = "launch",
				mode = "test",
				program = testpath,
				args = { "-test.run", "^" .. testname .. "$" },
				buildFlags = "",
			})
		end
	end,
}
