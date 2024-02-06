-- https://github.com/leoluz/nvim-dap-go
return {
	'leoluz/nvim-dap-go',
	dependencies = {
		'mfussenegger/nvim-dap',
	},
	config = function(_, opts)
		require('dap-go').setup(opts)
	end,
}
