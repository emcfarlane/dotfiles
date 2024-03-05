return {
	'VonHeikemen/little-wonder',
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		local lw = require('little-wonder')
		local rubber = require('little-wonder.themes.rubber')

		local color = {
			white = { gui = '#DCE0DD', cterm = 249 },
		}

		local theme = rubber.update({
			globals = {
				type = 'dark',
				foreground = color.white,
				background = lw.NONE --> use the background of terminal
			},
		})

		lw.apply('custom', theme)

		---
		-- Custom rules
		---

		lw.highlight('TelescopeMatching', { gui = '#FFEB95' })

		--lw.highlight('lualine_a_replace', { gui = '#FFEB95' })
		--lw.highlight('lualine_b_replace', { gui = '#FFEB95' })
		--lw.highlight('lualine_a_visual', { gui = '#FFEB95' })
		--lw.highlight('lualine_b_visual', { gui = '#FFEB95' })
		--lw.highlight('lualine_a_normal', { gui = '#FFEB95' })
		--lw.highlight('lualine_c_normal', { gui = '#FFEB95' })
		--lw.highlight('lualine_b_normal', { gui = '#FFEB95' })
		--lw.highlight('lualine_a_insert', { gui = '#FFEB95' })
		--lw.highlight('lualine_b_insert', { gui = '#FFEB95' })
		--lw.highlight('lualine_a_inactive', { gui = '#FFEB95' })
		--lw.highlight('lualine_c_inactive', { gui = '#FFEB95' })
		--lw.highlight('lualine_b_inactive', { gui = '#FFEB95' })
	end,
}

-- lualine_b_inactive xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_c_inactive xxx ctermfg=254 ctermbg=233 guifg=#e6e1cf guibg=#0f1419
-- lualine_a_inactive xxx cterm=bold ctermfg=254 ctermbg=234 gui=bold guifg=#e6e1cf guibg=#14191f
-- lualine_a_replace xxx cterm=bold ctermfg=233 ctermbg=210 gui=bold guifg=#0f1419 guibg=#f07178
-- lualine_b_replace xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_b_normal xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_c_normal xxx ctermfg=239 ctermbg=233 guifg=#3e4b59 guibg=#0f1419
-- lualine_a_normal xxx cterm=bold ctermfg=233 ctermbg=74 gui=bold guifg=#0f1419 guibg=#36a3d9
-- lualine_a_insert xxx cterm=bold ctermfg=233 ctermbg=149 gui=bold guifg=#0f1419 guibg=#b8cc52
-- lualine_b_insert xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_a_visual xxx cterm=bold ctermfg=233 ctermbg=229 gui=bold guifg=#0f1419 guibg=#ffee99
-- lualine_b_visual xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_b_diff_added_normal xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_insert xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_visual xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_replace xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_command xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_terminal xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_inactive xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_modified_normal xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_insert xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_visual xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_replace xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_command xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_terminal xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_inactive xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_removed_normal xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_insert xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_visual xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191fualine_b_inactive xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_c_inactive xxx ctermfg=254 ctermbg=233 guifg=#e6e1cf guibg=#0f1419
-- lualine_a_inactive xxx cterm=bold ctermfg=254 ctermbg=234 gui=bold guifg=#e6e1cf guibg=#14191f
-- lualine_a_replace xxx cterm=bold ctermfg=233 ctermbg=210 gui=bold guifg=#0f1419 guibg=#f07178
-- lualine_b_replace xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_b_normal xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_c_normal xxx ctermfg=239 ctermbg=233 guifg=#3e4b59 guibg=#0f1419
-- lualine_a_normal xxx cterm=bold ctermfg=233 ctermbg=74 gui=bold guifg=#0f1419 guibg=#36a3d9
-- lualine_a_insert xxx cterm=bold ctermfg=233 ctermbg=149 gui=bold guifg=#0f1419 guibg=#b8cc52
-- lualine_b_insert xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_a_visual xxx cterm=bold ctermfg=233 ctermbg=229 gui=bold guifg=#0f1419 guibg=#ffee99
-- lualine_b_visual xxx ctermfg=254 ctermbg=234 guifg=#e6e1cf guibg=#14191f
-- lualine_b_diff_added_normal xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_insert xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_visual xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_replace xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_command xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_terminal xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_added_inactive xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diff_modified_normal xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_insert xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_visual xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_replace xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_command xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_terminal xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_modified_inactive xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diff_removed_normal xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_insert xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_visual xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_replace xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_command xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_terminal xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diff_removed_inactive xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_error_normal xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_error_insert xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_error_visual xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_error_replace xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_error_command xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_error_terminal xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_error_inactive xxx ctermfg=168 ctermbg=234 guifg=#e06c75 guibg=#14191f
-- lualine_b_diagnostics_warn_normal xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diagnostics_warn_insert xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diagnostics_warn_visual xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diagnostics_warn_replace xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diagnostics_warn_command xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diagnostics_warn_terminal xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diagnostics_warn_inactive xxx ctermfg=179 ctermbg=234 guifg=#d19a66 guibg=#14191f
-- lualine_b_diagnostics_info_normal xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diagnostics_info_insert xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diagnostics_info_visual xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diagnostics_info_replace xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diagnostics_info_command xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diagnostics_info_terminal xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diagnostics_info_inactive xxx ctermfg=74 ctermbg=234 guifg=#56b6c2 guibg=#14191f
-- lualine_b_diagnostics_hint_normal xxx ctermfg=253 ctermbg=234 guifg=#dce0dd guibg=#14191f
-- lualine_b_diagnostics_hint_insert xxx ctermfg=253 ctermbg=234 guifg=#dce0dd guibg=#14191f
-- lualine_b_diagnostics_hint_visual xxx ctermfg=253 ctermbg=234 guifg=#dce0dd guibg=#14191f
-- lualine_b_diagnostics_hint_replace xxx ctermfg=253 ctermbg=234 guifg=#dce0dd guibg=#14191f
-- lualine_b_diagnostics_hint_command xxx ctermfg=253 ctermbg=234 guifg=#dce0dd guibg=#14191f
-- lualine_b_diagnostics_hint_terminal xxx ctermfg=253 ctermbg=234 guifg=#dce0dd guibg=#14191f
-- lualine_b_diagnostics_hint_inactive xxx ctermfg=253 ctermbg=234 guifg=#dce0dd guibg=#14191f
