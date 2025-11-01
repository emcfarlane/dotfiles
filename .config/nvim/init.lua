-- Set mapleader before loading any plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.copilot_filetypes = { VimspectorPrompt = false }

vim.o.colorcolumn = '80'
vim.o.winborder = "rounded"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showtabline = 2
vim.o.signcolumn = "yes" -- Keep signcolumn on by default
vim.o.wrap = false
vim.o.cursorcolumn = false
vim.o.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.o.smartindent = true
vim.o.termguicolors = os.getenv('TERM_PROGRAM') ~= 'Apple_Terminal' -- Exclude Apple Terminal
vim.o.undofile = true -- Save undo history
vim.o.number = true
vim.wo.number = true -- Make line numbers default
vim.o.mouse = 'a'    -- Enable mouse mode

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
--vim.o.clipboard = 'unnamedplus'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect,popup'

-- Add cwd titles to ghostty windows
if vim.fn.getenv("TERM_PROGRAM") == "ghostty" then
	vim.opt.title = true
	vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}"
end

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.hl.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})

-- Set autoread for files changed outside of Vim
-- See :help autoread
vim.o.autoread = true
-- Issue: https://github.com/neovim/neovim/issues/1380
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	command = "if mode() != 'c' | checktime | endif",
	pattern = { "*" },
})

-- Diagnostic keymaps
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure Filetype ]]
vim.api.nvim_create_autocmd("FileType", {
	pattern = "html",
	command = "setlocal shiftwidth=2 tabstop=2 expandtab"
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "typescript",
	command = "setlocal shiftwidth=2 tabstop=2 expandtab"
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "proto",
	command = "setlocal shiftwidth=2 tabstop=2 expandtab"
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	command = "setlocal shiftwidth=2 tabstop=2 expandtab"
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "template",
	command = "setlocal shiftwidth=2 tabstop=2 expandtab"
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.wgsl",
	callback = function()
		vim.bo.filetype = "wgsl"
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "wgsl",
	command = "setlocal shiftwidth=4 tabstop=4 expandtab"
})

-- Terminal
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("CustomTermOpen", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<space>st", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 15)
end)

vim.pack.add({
	{ src = 'https://github.com/neovim/nvim-lspconfig' },             -- LSP Configuration & Plugins
	{ src = "https://github.com/tpope/vim-fugitive" },                -- Git commands in nvim
	{ src = "https://github.com/tpope/vim-rhubarb" },                 -- Enables `:Gbrowse` to open the current file on GitHub
	{ src = "https://github.com/tpope/vim-sleuth" },                  -- Automatically set the 'shiftwidth' and 'expandtab' options based on the current file
	{ src = "https://github.com/tpope/vim-surround" },                -- Surround text objects with symbols
	{ src = "https://github.com/tpope/vim-repeat" },                  -- Enable repeating of plugin commands with `.`
	{ src = "https://github.com/tpope/vim-dadbod" },                  -- Database interface
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },      -- UI for vim-dadbod
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" }, -- Completion source for vim-dadbod
	{ src = "https://github.com/github/copilot.vim" },                -- GitHub Copilot
	{ src = "https://github.com/stevearc/oil.nvim" },                 -- File explorer
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim",          version = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim"	},
	{ src = "https://github.com/saghen/blink.cmp"	},
})
local function pack_clean()
	local active_plugins = {}
	local unused_plugins = {}

	for _, plugin in ipairs(vim.pack.get()) do
		active_plugins[plugin.spec.name] = plugin.active
	end

	for _, plugin in ipairs(vim.pack.get()) do
		if not active_plugins[plugin.spec.name] then
			table.insert(unused_plugins, plugin.spec.name)
		end
	end

	if #unused_plugins == 0 then
		print("No unused plugins.")
		return
	end

	local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
	if choice == 1 then
		vim.pack.del(unused_plugins)
	end
end
vim.keymap.set("n", "<leader>pc", pack_clean)

-- Plugins
require("vacme")
require("hooks")
require("dapper")

vim.lsp.enable({
	"ts_ls",
	"clangd",
	"html",
	"jedi_language_server",
	"yamlls",
	"gopls",
	"rust_analyzer",
	"zls",
	"lua_ls",
	"wgsl_analyzer",
})
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
		},
	},
})

require("oil").setup {
	default_file_explorer = true,
	columns = { "icon" },
	use_default_keymaps = true,
	view_options = {
		show_hidden = true,
	},
}
-- Open parent directory in current window
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier" },
		template = { "prettierd", "prettier" },
	},
})

local telescope = require("telescope")
telescope.setup({
	defaults = {
		preview = { treesitter = false },
		color_devicons = true,
		sorting_strategy = "ascending",
		borderchars = {
			"─", -- top
			"│", -- right
			"─", -- bottom
			"│", -- left
			"┌", -- top-left
			"┐", -- top-right
			"┘", -- bottom-right
			"└", -- bottom-left
		},
		path_displays = { "smart" },
		layout_config = {
			height = 100,
			width = 400,
			prompt_position = "top",
			preview_cutoff = 40,
		}
	}
})
pcall(telescope.load_extension, "ui-select")

require("lualine").setup({
	options = {
		icons_enabled = false,
		theme = 'ayu',
		component_separators = '|',
		section_separators = '',
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diff', 'diagnostics' },
		lualine_c = {
			{ 'filename', path = 1 },
		},
		lualine_x = { 'encoding', 'fileformat', 'filetype' },
		lualine_y = { 'progress' },
		lualine_z = { 'location' }
	},
})

local map = vim.keymap.set
map({ "n" }, "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format current buffer" })

local builtin = require("telescope.builtin")
local function find_files()  builtin.find_files({ no_ignore = true }) end
map({ "n" }, "<leader>g", builtin.live_grep)
map({ "n" }, "<leader>sf", find_files)
map({ "n" }, "<leader>sg", builtin.git_files)
map({ "n" }, "<leader>sb", builtin.buffers)
map({ "n" }, "<leader>si", builtin.grep_string)
map({ "n" }, "<leader>so", builtin.oldfiles)
map({ "n" }, "<leader>sh", builtin.help_tags)
map({ "n" }, "<leader>sm", builtin.man_pages)
map({ "n" }, "<leader>sr", builtin.lsp_references)
map({ "n" }, "<leader>sd", builtin.diagnostics)
map({ "n" }, "<leader>si", builtin.lsp_implementations)
map({ "n" }, "<leader>sT", builtin.lsp_type_definitions)
map({ "n" }, "<leader>ss", builtin.current_buffer_fuzzy_find)
map({ "n" }, "<leader>st", builtin.builtin)
map({ "n" }, "<leader>sc", builtin.git_bcommits)
map({ "n" }, "<leader>sk", builtin.keymaps)
