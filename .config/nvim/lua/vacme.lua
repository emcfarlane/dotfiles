vim.cmd('hi clear')

if vim.fn.exists("syntax_on") then
	vim.cmd('syntax reset')
end

vim.g.colors_name = 'vacme'
vim.o.background = 'light'

local vcolors = {
	-- whites
	w1 = { term = '15', hex = '#FFFFEC' },
	w2 = { term = '11', hex = '#EEEEA7' },
	w3 = { term = '7', hex = '#999957' },
	w4 = { term = '0', hex = '#424242' },

	-- reds
	r1 = { term = '9', hex = '#F2ACAA' },
	r2 = { term = '1', hex = '#B85C57' },

	-- greens
	g1 = { term = '193', hex = '#EFFEEC' },
	g2 = { term = '10', hex = '#98CE8F' },
	g3 = { term = '2', hex = '#57864E' },

	-- yellows
	y1 = { term = '187', hex = '#EAEBDB' },
	y2 = { term = '8', hex = '#B7B19C' },
	y3 = { term = '3', hex = '#8F7634' },

	-- blues
	b1 = { term = '195', hex = '#E2F1F8' },
	b2 = { term = '12', hex = '#A6DCF8' },
	b3 = { term = '4', hex = '#2A8DC5' },

	-- magentas
	m1 = { term = '13', hex = '#D0D0F7' },
	m2 = { term = '5', hex = '#8888C7' },

	-- cyans
	c1 = { term = '194', hex = '#EAFFFF' },
	c2 = { term = '14', hex = '#B0ECED' },
	c3 = { term = '6', hex = '#6AA7A8' },

	-- misc (accent)
	a1 = { term = '195', hex = '#030093' }
}
local vstyles = {
	normal = { fg = vcolors.w4, bg = vcolors.w1 },
	ghostly = { fg = vcolors.y3, bg = vcolors.w1 },
	hilited = { fg = vcolors.w4, bg = vcolors.w2 },
	justbold = { style = 'bold' },
	justuline = { style = 'underline' },
	justit = { style = 'italic' }
}

local function syntax(group, rule)
	vim.cmd(string.format("hi! %s term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE", group))
	local fg = ""
	if rule.fg then fg = string.format(' guifg=%s ctermfg=%s', rule.fg['hex'], rule.fg['term']) end
	local bg = ""
	if rule.bg then bg = string.format(' guibg=%s ctermbg=%s', rule.bg['hex'], rule.bg['term']) end
	local style = ""
	if rule.style then style = string.format(' gui=%s cterm=%s', rule.style, rule.style) end
	vim.cmd(string.format('hi! %s%s%s%s', group, fg, bg, style))
end

local function link(group, model)
	vim.cmd(string.format("hi! link %s %s", group, model))
end

-- nvim UI elements (cursors, searches, borders, etc.)
syntax('Normal', vstyles.normal)
syntax('Folded', vstyles.ghostly)
syntax('FoldColumn', vstyles.ghostly)
syntax('Terminal', vstyles.normal)
syntax('ToolbarButton', vstyles.normal)
syntax('ToolbarLine', vstyles.normal)
syntax('CursorLine', { bg = vcolors.g1 })
syntax('LineNr', { fg = vcolors.w3, bg = vcolors.y1 })
link('LineNrAbove', 'LineNr')
link('LineNrBelow', 'LineNr')
syntax('FloatBorder', { fg = vcolors.g3, bg = vcolors.g1 })
syntax('NormalFloat', { fg = vcolors.g3, bg = vcolors.g1 })
syntax('@text.literal', { fg = vcolors.w4 })
syntax('@markup.raw', { fg = vcolors.w4 })
syntax('DiffAdd', { fg = vcolors.w4, bg = vcolors.g2 })
syntax('DiffChange', { fg = vcolors.w4, bg = vcolors.c2 })
syntax('DiffDelete', { fg = vcolors.w4, bg = vcolors.r1 })
syntax('DiffText', { fg = vcolors.w4, bg = vcolors.g2 })
syntax('StatusLine', { fg = vcolors.w4, bg = vcolors.c1, style = 'bold,underline' })
syntax('StatusLineNC', { fg = vcolors.w4, bg = vcolors.c1 })
link('TabLine', 'StatusLineNC')
link('TabLineFill', 'StatusLineNC')
link('WinSeparator', 'StatusLineNC')
syntax('TabLineSel', { fg = vcolors.w1, bg = vcolors.m2 })
syntax('CursorLineNr', { fg = vcolors.w1, bg = vcolors.m2 })
syntax('NonText', { fg = vcolors.w3 })
syntax('SpecialKey', vstyles.justbold)
syntax('SpellBad', { fg = vcolors.r2, style = 'underline' })
syntax('SpellCap', vstyles.justuline)
syntax('SpellLocal', vstyles.justuline)
syntax('SpellRare', vstyles.justuline)
syntax('Title', vstyles.justbold)
syntax('ColorColumn', vstyles.hilited)
syntax('Conceal', vstyles.ghostly)
syntax('CursorColumn', { bg = vcolors.g1 })
syntax('Directory', vstyles.justbold)
syntax('EndOfBuffer', vstyles.ghostly)
syntax('ErrorMsg', vstyles.justbold)
syntax('IncSearch', { fg = vcolors.w1, bg = vcolors.m2 })
syntax('MatchParen', { bg = vcolors.w2, style = 'bold' })
syntax('ModeMsg', vstyles.justbold)
syntax('MoreMsg', vstyles.justbold)
syntax('Pmenu', { fg = vcolors.g3, bg = vcolors.g1 })
syntax('PmenuSbar', { fg = vcolors.g1, bg = vcolors.g3 })
syntax('PmenuSel', { fg = vcolors.w4, bg = vcolors.g2, style = 'underline' })
syntax('PmenuKindSel', { fg = vcolors.w4, bg = vcolors.g2 })
link('PmenuExtraSel', 'PmenuKindSel')
syntax('PmenuThumb', { fg = vcolors.g1, bg = vcolors.w4 })
syntax('Question', vstyles.justbold)
syntax('Search', vstyles.hilited)
link('SignColumn', 'LineNr')
syntax('Visual', vstyles.hilited)
syntax('VisualNOS', vstyles.hilited)
syntax('WarningMsg', vstyles.justbold)
syntax('WildMenu', { fg = vcolors.w1, bg = vcolors.m2 })
syntax('QuickFixLine', vstyles.justbold)

-- language syntax (comments, literals, identifiers, etc.)
syntax('Comment', vstyles.justbold)

syntax('Constant', vstyles.normal)
syntax('String', vstyles.normal)
syntax('Character', vstyles.normal)
syntax('Number', vstyles.normal)
syntax('Boolean', vstyles.normal)
syntax('Float', vstyles.normal)

syntax('Identifier', vstyles.normal)
syntax('Function', vstyles.normal)

syntax('Statement', vstyles.normal)
syntax('Conditional', vstyles.normal)
syntax('Repeat', vstyles.normal)
syntax('Label', vstyles.normal)
syntax('Operator', vstyles.normal)
syntax('Keyword', vstyles.normal)
syntax('Exception', vstyles.normal)

syntax('PreProc', vstyles.normal)
syntax('Include', vstyles.normal)
syntax('Define', vstyles.normal)
syntax('Macro', vstyles.normal)
syntax('PreCondit', vstyles.normal)

syntax('Type', vstyles.normal)
syntax('StorageClass', vstyles.normal)
syntax('Structure', vstyles.normal)
syntax('Typedef', vstyles.normal)

syntax('Special', vstyles.normal)
syntax('SpecialChar', vstyles.normal)
syntax('Tag', vstyles.justuline)
syntax('Delimiter', vstyles.normal)
syntax('SpecialComment', vstyles.normal)
syntax('Debug', vstyles.normal)

syntax('Underlined', vstyles.justuline)

syntax('Ignore', vstyles.justbold)

syntax('Error', vstyles.normal)

syntax('Todo', vstyles.hilited)

-- TreeSitter
link('TSAnnotation', 'Normal')
link('TSBoolean', 'Normal')
link('TSCharacter', 'Normal')
link('TSComment', 'Comment')
link('TSConditional', 'Normal')
link('TSConstant', 'Normal')
link('TSConstBuiltin', 'Normal')
link('TSConstMacro', 'Normal')
link('TSError', 'Error')
link('TSException', 'Normal')
link('TSField', 'Normal')
link('TSFloat', 'Normal')
link('TSFunction', 'Normal')
link('TSFuncBuiltin', 'Normal')
link('TSFuncMacro', 'Normal')
link('TSInclude', 'Normal')
link('TSKeyword', 'Normal')
link('TSLabel', 'Normal')
link('TSMethod', 'Normal')
link('TSNamespace', 'Normal')
link('TSNumber', 'Normal')
link('TSOperator', 'Normal')
link('TSParameterReference', 'Normal')
link('TSProperty', 'Normal')
link('TSPunctDelimiter', 'Normal')
link('TSPunctBracket', 'Normal')
link('TSPunctSpecial', 'Normal')
link('TSRepeat', 'Normal')
link('TSString', 'Normal')
link('TSStringRegex', 'Normal')
link('TSStringEscape', 'Normal')
link('TSStrong', 'Normal')
link('TSConstructor', 'Normal')
link('TSKeywordFunction', 'Normal')
link('TSLiteral', 'Normal')
link('TSParameter', 'Normal')
link('TSVariable', 'Normal')
link('TSVariableBuiltin', 'Normal')
link('TSTag', 'Normal')
link('TSTagDelimiter', 'Normal')
link('TSTitle', 'Normal')
link('TSType', 'Normal')
link('TSTypeBuiltin', 'Normal')
link('TSEmphasis', 'Normal')
