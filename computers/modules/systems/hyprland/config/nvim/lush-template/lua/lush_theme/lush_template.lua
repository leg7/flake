----
-- Built with,
--
--        ,gggg,
--       d8" "8I                         ,dPYb,
--       88  ,dP                         IP'`Yb
--    8888888P"                          I8  8I
--       88                              I8  8'
--       88        gg      gg    ,g,     I8 dPgg,
--  ,aa,_88        I8      8I   ,8'8,    I8dP" "8I
-- dP" "88P        I8,    ,8I  ,8'  Yb   I8P    I8
-- Yb,_,d88b,,_   ,d8b,  ,d8b,,8'_   8) ,d8     I8,
--  "Y8P"  "Y888888P'"Y88P"`Y8P' "YY8P8P88P     `Y8
--

-- This is a starter colorscheme for use with Lush,
-- for usage guides, see :h lush or :LushRunTutorial

--
-- Note: Because this is a lua file, vim will append it to the runtime,
--       which means you can require(...) it in other lua code (this is useful),
--       but you should also take care not to conflict with other libraries.
--
--       (This is a lua quirk, as it has somewhat poor support for namespacing.)
--
--       Basically, name your file,
--
--       "super_theme/lua/lush_theme/super_theme_dark.lua",
--
--       not,
--
--       "super_theme/lua/dark.lua".
--
--       With that caveat out of the way...
--

-- Enable lush.ify on this file, run:
--
--  `:Lushify`
--
--  or
--
--  `:lua require('lush').ify()`

local lush = require('lush')
local hsl = lush.hsl

-- LSP/Linters mistakenly show `undefined global` errors in the spec, they may
-- support an annotation like the following. Consult your server documentation.
---@diagnostic disable: undefined-global
local theme = lush(function(injected_functions)
	local sym = injected_functions.sym
	local black = hsl(357,36, 14)
	local pink = hsl(337, 85, 70)
	local red = hsl(1, 60, 50)
	local green = hsl(160, 45, 50)
	local yellow = hsl(80, 50, 55)
	local blue = hsl(190, 39, 50)
	local orange = hsl(20, 46, 55)
	local white = pink.lighten(90).saturate(9)
	local highlight = black.lighten(7)
	return {
		-- The following are the Neovim (as of 0.8.0-dev+100-g371dfb174) highlight
		-- groups, mostly used for styling UI elements.
		-- Comment them out and add your own properties to override the defaults.
		-- An empty definition `{}` will clear all styling, leaving elements looking
		-- like the 'Normal' group.
		-- To be able to link to a group, it must already be defined, so you may have
		-- to reorder items as you go.
		--
		-- See :h highlight-groups
		--
		Normal         { bg = black, fg = pink }, -- Normal text
		ColorColumn    { Normal, bg = highlight }, -- Columns set with 'colorcolumn'
		Conceal        { Normal, fg = Normal.fg.darken(30) }, -- Placeholder characters substituted for concealed text (see 'conceallevel')
		Search         { bg = orange, fg = black, gui = 'NONE' }, -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
		CurSearch      { Search }, -- Highlighting a search pattern under the cursor (see 'hlsearch')
		IncSearch      { bg = red, fg = black }, -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
		Substitute     { bg = red, fg = black, gui = 'bold' }, -- |:substitute| replacement text highlighting
		Cursor         { bg = red }, -- Character under the cursor
		lCursor        { Cursor}, -- Character under the cursor when |language-mapping| is used (see 'guicursor')
		CursorIM       { bg = red }, -- Like Cursor, but used when in IME mode |CursorIM|
		CursorColumn   { bg = red }, -- Screen-column at the cursor, when 'cursorcolumn' is set.
		CursorLine     { bg = highlight }, -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
		Directory      { fg = blue }, -- Directory names (and other special names in listings)
		DiffAdd        { fg = green }, -- Diff mode: Added line |diff.txt|
		DiffChange     { fg = yellow }, -- Diff mode: Changed line |diff.txt|
		DiffDelete     { fg = red }, -- Diff mode: Deleted line |diff.txt|
		DiffText       { fg = orange }, -- Diff mode: Changed text within a changed line |diff.txt|
		EndOfBuffer    { }, -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
		TermCursor     { bg = white }, -- Cursor in a focused terminal
		TermCursorNC   {}, -- Cursor in an unfocused terminal
		-- ErrorMsg       { }, -- Error messages on the command line
		Folded         { }, -- Line used for closed folds
		FoldColumn     { }, -- 'foldcolumn'
		SignColumn     { }, -- Column where |signs| are displayed
		LineNr         { fg = black.li(15) }, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
		-- LineNrAbove    { }, -- Line number for when the 'relativenumber' option is set, above the cursor line
		-- LineNrBelow    { }, -- Line number for when the 'relativenumber' option is set, below the cursor line
		CursorLineNr   { Normal }, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
		-- CursorLineFold { }, -- Like FoldColumn when 'cursorline' is set for the cursor line
		-- CursorLineSign { }, -- Like SignColumn when 'cursorline' is set for the cursor line
		MatchParen     { fg = red, gui = 'bold' }, -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
		-- ModeMsg        { }, -- 'showmode' message (e.g., "-- INSERT -- ")
		-- MsgArea        { }, -- Area for messages and cmdline
		-- MsgSeparator   { }, -- Separator for scrolled messages, `msgsep` flag of 'display'
		MoreMsg        { fg = green }, -- |more-prompt|
		NonText        {}, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
		NormalFloat    { Normal, bg = Normal.bg.li(10) }, -- Normal text in floating windows.
		-- FloatBorder    { Normal, fg = white }, -- Border of floating windows.
		-- FloatTitle     { }, -- Title of floating windows.
		-- NormalNC       { }, -- normal text in non-current windows
		Pmenu          { NormalFloat }, -- Popup menu: Normal item.
		PmenuSel       { NormalFloat, bg = NormalFloat.bg.li(10) }, -- Popup menu: Selected item.
		-- PmenuKind      { bg = red }, -- Popup menu: Normal item "kind"
		-- PmenuKindSel   { }, -- Popup menu: Selected item "kind"
		PmenuExtra     { PmenuSel, bg = PmenuSel.bg.li(10) }, -- Popup menu: Normal item "extra text"
		PmenuExtraSel  { PmenuExtra, bg = PmenuExtra.bg.li(10) }, -- Popup menu: Selected item "extra text"
		PmenuSbar      { Pmenu }, -- Popup menu: Scrollbar.
		PmenuThumb     { Pmenu, bg = black.li(5) }, -- Popup menu: Thumb of the scrollbar.
		Question       { fg = green }, -- |hit-enter| prompt and yes/no questions
		QuickFixLine   { Substitute }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
		-- SpecialKey     { }, -- Unprintable characters: text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Wbold hitespace|
		-- SpellBad       { }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
		-- SpellCap       { }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
		-- SpellLocal     { }, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
		-- SpellRare      { }, -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
		StatusLine     { Normal, bg = Normal.bg.li(5) }, -- Status line of current window
		StatusLineNC   { Normal }, -- Status lines of not-current windows. Note: If this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
		TabLine        { StatusLine }, -- Tab pages line, not active tab page label
		TabLineFill    { Normal }, -- Tab pages line, where there are no labels
		TabLineSel     { StatusLine }, -- Tab pages line, active tab page label
		Title          { fg = yellow }, -- Titles for output from ":set all", ":autocmd" etc.
		Visual         { CursorLine }, -- Visual mode selection
		VisualNOS      { Visual }, -- Visual mode selection when vim is "Not Owning the Selection".
		-- WarningMsg     { }, -- Warning messages
		Whitespace     { Normal }, -- "nbsp", "space", "tab" and "trail" in 'listchars'
		VertSplit      { Normal }, -- Column separating vertically split windows
		Winseparator   { Normal }, -- Separator between window splits. Inherts from |hl-VertSplit| by default, which it will replace eventually.
		WildMenu       { Normal }, -- Current match in 'wildmenu' completion
		-- WinBar         { }, -- Window bar of current window
		-- WinBarNC       { }, -- Window bar of not-current windows

		-- Common vim syntax groups used for all kinds of code and markup.
		-- Commented-out groups should chain up to their preferred (*) group
		-- by default.
		--
		-- See :h group-name
		--
		-- Uncomment and edit if you want more specific syntax highlighting.

		Comment        { fg = yellow }, -- Any comment

		Constant       { fg = green }, -- (*) Any constant
		String         { Constant }, --   A string constant: "this is a string"
		Character      { Constant }, --   A character constant: 'c', '\n'
		Number         { Constant }, --   A number constant: 234, 0xff
		Boolean        { Constant }, --   A boolean constant: TRUE, false
		Float          { Constant }, --   A floating point constant: 2.3e10

		Identifier     { }, -- (*) Any variable name
		Function       { }, --   Function name (also: methods for classes)

		Statement      { fg = white }, -- (*) Any statement
		Conditional    { Statement }, --   if, then, else, endif, switch, etc.
		Repeat         { Statement }, --   for, do, while, etc.
		Label          { Statement }, --   case, default, etc.
		Operator       { fg = pink.saturate(95).da(10) }, --   "sizeof", "+", "*", etc.
		Keyword        { fg = blue }, --   any other keyword
		Exception      { Statement }, --   try, catch, throw

		PreProc        { fg = pink }, -- (*) Generic Preprocessor
		Include        { PreProc }, --   Preprocessor #include
		Define         { fg = green }, --   Preprocessor #define
		Macro          { fg = green }, --   Same as Define
		PreCondit      { Statement }, --   Preprocessor #if, #else, #endif, etc.

		Type           { fg = blue }, -- (*) int, long, char, etc.
		StorageClass   { Type }, --   static, register, volatile, etc.
		Structure      { Type }, --   struct, union, enum, etc.
		Typedef        { Type }, --   A typedef

		Special        { fg = green }, -- (*) Any special symbol
		SpecialChar    { fg = yellow }, --   Special character in a constant
		Tag            {}, --   You can use CTRL-] on this
		Delimiter      { fg = Operator.fg.de(15).da(10) }, --   Character that needs attention
		SpecialComment { SpecialChar }, --   Special things inside a comment (e.g. '\n')
		Debug          { SpecialChar }, --   Debugging statements

		Underlined     { gui = "underline" }, -- Text that stands out, HTML links
		Ignore         { }, -- Left blank, hidden |hl-Ignore| (NOTE: May be invisible here in template)
		Error          { fg = red }, -- Any erroneous construct
		Todo           { fg = red }, -- Anything that needs extra attention; mostly the keywords TODO FIXME and XXX

		-- These groups are for the native LSP client and diagnostic system. Some
		-- other LSP clients may use these groups, or use their own. Consult your
		-- LSP client's documentation.

		-- See :h lsp-highlight, some groups may not be listed, submit a PR fix to lush-template!
		--
		-- LspReferenceText            { } , -- Used for highlighting "text" references
		-- LspReferenceRead            { } , -- Used for highlighting "read" references
		-- LspReferenceWrite           { } , -- Used for highlighting "write" references
		-- LspCodeLens                 { } , -- Used to color the virtual text of the codelens. See |nvim_buf_set_extmark()|.
		-- LspCodeLensSeparator        { } , -- Used to color the seperator between two or more code lens.
		-- LspSignatureActiveParameter { } , -- Used to highlight the active parameter in the signature help. See |vim.lsp.handlers.signature_help()|.

		-- See :h diagnostic-highlights, some groups may not be listed, submit a PR fix to lush-template!
		--
		DiagnosticError            { fg = red } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
		DiagnosticWarn             { fg = orange } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
		DiagnosticInfo             { fg = blue } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
		DiagnosticHint             { fg = highlight } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
		DiagnosticOk               { fg = green } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
		DiagnosticVirtualTextError { fg = red } , -- Used for "Error" diagnostic virtual text.
		DiagnosticVirtualTextWarn  { fg = orange } , -- Used for "Warn" diagnostic virtual text.
		DiagnosticVirtualTextInfo  { fg = blue } , -- Used for "Info" diagnostic virtual text.
		DiagnosticVirtualTextHint  { fg = highlight } , -- Used for "Hint" diagnostic virtual text.
		DiagnosticVirtualTextOk    { fg = green } , -- Used for "Ok" diagnostic virtual text.
		DiagnosticUnderlineError   { fg = red } , -- Used to underline "Error" diagnostics.
		DiagnosticUnderlineWarn    { fg = orange } , -- Used to underline "Warn" diagnostics.
		DiagnosticUnderlineInfo    { fg = blue } , -- Used to underline "Info" diagnostics.
		DiagnosticUnderlineHint    { fg = highlight } , -- Used to underline "Hint" diagnostics.
		DiagnosticUnderlineOk      { fg = green } , -- Used to underline "Ok" diagnostics.
		DiagnosticFloatingError    { fg = red } , -- Used to color "Error" diagnostic messages in diagnostics float. See |vim.diagnostic.open_float()|
		DiagnosticFloatingWarn     { fg = orange } , -- Used to color "Warn" diagnostic messages in diagnostics float.
		DiagnosticFloatingInfo     { fg = blue } , -- Used to color "Info" diagnostic messages in diagnostics float.
		DiagnosticFloatingHint     { fg = highlight } , -- Used to color "Hint" diagnostic messages in diagnostics float.
		DiagnosticFloatingOk       { fg = green } , -- Used to color "Ok" diagnostic messages in diagnostics float.
		DiagnosticSignError        { fg = red } , -- Used for "Error" signs in sign column.
		DiagnosticSignWarn         { fg = orange } , -- Used for "Warn" signs in sign column.
		DiagnosticSignInfo         { fg = blue } , -- Used for "Info" signs in sign column.
		DiagnosticSignHint         { fg = highlight } , -- Used for "Hint" signs in sign column.
		DiagnosticSignOk           { fg = green } , -- Used for "Ok" signs in sign column.

		-- Tree-Sitter syntax groups.
		--
		-- See :h treesitter-highlight-groups, some groups may not be listed,
		-- submit a PR fix to lush-template!
		--
		-- Tree-Sitter groups are defined with an "@" symbol, which must be
		-- specially handled to be valid lua code, we do this via the special
		-- sym function. The following are all valid ways to call the sym function,
		-- for more details see https://www.lua.org/pil/5.html
		--
		-- sym("@text.literal")
		-- sym('@text.literal')
		-- sym"@text.literal"
		-- sym'@text.literal'
		--
		-- For more information see https://github.com/rktjmp/lush.nvim/issues/109

		sym'@text.literal'      { Comment }, -- Comment
		sym'@comment'           { Comment }, -- Comment
		sym'@text.reference'    { Identifier }, -- Identifier
		sym'@text.title'        { Title }, -- Title
		sym'@text.uri'          { Underlined }, -- Underlined
		sym'@text.underline'    { Underlined }, -- Underlined
		sym'@text.todo'         { Todo }, -- Todo
		sym'@punctuation'       { Delimiter }, -- Delimiter
		sym'@constant'          { Constant }, -- Constant
		sym'@constant.builtin'  { Special }, -- Special
		sym'@constant.macro'    { Define }, -- Define
		sym'@define'            { Define }, -- Define
		sym'@macro'             { Macro }, -- Macro
		sym'@string'            { String }, -- String
		sym'@character'         { String }, -- Character
		sym'@string.special'    { SpecialChar }, -- SpecialChar
		sym'@string.escape'     { SpecialChar }, -- SpecialChar
		sym'@character.special' { SpecialChar }, -- SpecialChar
		sym'@number'            { Number }, -- Number
		sym'@boolean'           { Boolean }, -- Boolean
		sym'@float'             { Float }, -- Float
		sym'@function'          { Function }, -- Function
		sym'@function.builtin'  { Special }, -- Special
		sym'@function.macro'    { Macro }, -- Macro
		sym'@parameter'         { Identifier }, -- Identifier
		sym'@method'            { Function }, -- Function
		sym'@field'             { Identifier }, -- Identifier
		sym'@property'          { Identifier }, -- Identifier
		sym'@constructor'       { Type }, -- Special
		sym'@conditional'       { Conditional }, -- Conditional
		sym'@repeat'            { Repeat }, -- Repeat
		sym'@label'             { Label }, -- Label
		sym'@operator'          { Operator }, -- Operator
		sym'@keyword'           { Keyword }, -- Keyword
		sym'@exception'         { Exception }, -- Exception
		sym'@variable'          { Identifier }, -- Identifier
		sym'@type'              { Type }, -- Type
		sym'@type.definition'   { Type }, -- Typedef
		sym'@storageclass'      { Type }, -- StorageClass
		sym'@structure'         { Type }, -- Structure
		sym'@namespace'         { Identifier }, -- Identifier
		sym'@include'           { Include }, -- Include
		sym'@preproc'           { PreProc }, -- PreProc
		sym'@debug'             { Debug }, -- Debug
		sym'@tag'               { Tag }, -- Tag
	}
end)

-- Return our parsed theme for extension or use elsewhere.
return theme

-- vi:nowrap
