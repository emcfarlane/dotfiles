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
	end,
}
