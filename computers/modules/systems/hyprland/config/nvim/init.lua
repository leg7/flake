-- TODO:
-- Add local completion fallback when lsp not available
-- configure lua snippets
-- Fix 'gl' conflict between vim-lion and lsp
-- Fix split navigation confilct with oil
-- Add Harpoon
-- Use tmux + sessions
-- make better treesitter text objects to improve navigation

vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{
		'nvim-lualine/lualine.nvim',
		lazy = false,
		priority = 900,
		config = function()
			local lualine = require('lualine')

			local conditions = {
				buffer_not_empty = function()
					return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
				end,
				hide_in_width = function()
					return vim.fn.winwidth(0) > 80
				end,
				check_git_workspace = function()
					local filepath = vim.fn.expand('%:p:h')
					local gitdir = vim.fn.finddir('.git', filepath .. ';')
					return gitdir and #gitdir > 0 and #gitdir < #filepath
				end,
			}

			-- Config
			local config = {
				options = {
					-- Disable sections and component separators
					component_separators = '',
					section_separators = '',
					theme = 'auto',
				},
				sections = {
					-- these are to remove the defaults
					lualine_a = {},
					lualine_b = {},
					lualine_y = {},
					lualine_z = {},
					-- These will be filled later
					lualine_c = {},
					lualine_x = {},
				},
				inactive_sections = {
					-- these are to remove the defaults
					lualine_a = {},
					lualine_b = {},
					lualine_y = {},
					lualine_z = {},
					lualine_c = {},
					lualine_x = {},
				},
			}

			local function ins_left(component)
				table.insert(config.sections.lualine_c, component)
			end

			local function ins_right(component)
				table.insert(config.sections.lualine_x, component)
			end

			ins_left { 'filename', color = { gui = 'bold' }, cond = conditions.buffer_not_empty, }
			ins_left { 'progress', color = { gui = 'bold' } }
			ins_left { 'location', color = { gui = 'bold' } }

			-- Insert mid section. You can make any number of sections in neovim :)
			-- for lualine it's any number greater then 2
			ins_left { function() return '%=' end, }
			ins_left { 'filetype', icon_only = true }
			ins_left {
				-- Lsp server name .
				function()
					local msg = ''

					local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
					local clients = vim.lsp.get_active_clients()
					if next(clients) == nil then
						return msg
					end
					for _, client in ipairs(clients) do
						local filetypes = client.config.filetypes
						if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
							return client.name
						end
					end
					return msg
				end,
				color = { gui = 'bold' },
			}
			ins_left {
				'diagnostics',
				sources = { 'nvim_diagnostic' },
				symbols = { error = ' ', warn = ' ', info = ' ' },
			}

			ins_right {
				'branch',
				icon = '',
			}
			ins_right {
				'diff',
				-- Is it me or the symbol for modified us really weird
				symbols = { added = ' ', modified = ' ', removed = ' ' },
				cond = conditions.hide_in_width,
			}

			lualine.setup(config)
		end,
	},
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',

		config = function()

			local lsp_zero = require('lsp-zero')

			lsp_zero.on_attach(function(client, bufnr)
				lsp_zero.default_keymaps({buffer = bufnr})
			end)

			lsp_zero.setup_servers({
				'hls',

				'bashls',
				'ocamllsp',
				'clangd',
				'rnix',
				'lua_ls',
				'emmet_ls',
			})


			lsp_zero.set_sign_icons({
				error = '',
				warn = '',
				hint = '⚑',
				info = ''
			})

			require('mason').setup()
			require('mason-lspconfig').setup({
				ensure_installed = {
					'bashls',
					'ocamllsp',
					'clangd',
					'rnix',
					'lua_ls',
					'emmet_ls',
				},
				handlers = { lsp_zero.default_setup },
				automatic_installation = true,
			})
		end,

		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/nvim-cmp',
			'L3MON4D3/LuaSnip',
		},

		ft = {
			'haskell',

			'sh',
			'ocaml',
			'c', 'cpp',
			'nix',
			'lua',
			'html', 'js', 'php',
		},

		keys = {
			{ '<leader>f', mode = 'n', function() vim.lsp.buf.format() end, },
		}
	},
	{
		'nvim-treesitter/nvim-treesitter',
		lazy = false,
		config = function()
			require'nvim-treesitter.configs'.setup {
				highlight = { enable = true },

				indent = {
					disable = { 'bash', 'nix', 'haskell' },
					enable = true,
				},

				additional_vim_regex_highlighting = false,

				ensure_installed = {
					-- linux
					'bash', 'fish', 'awk',
					'make',
					'nix',
					'toml',
					'xml',
					'markdown', 'markdown_inline',
					'vim', 'vimdoc',
					'yaml',
					'query', 'regex',
					-- prog
					'c',
					'lua', 'luadoc', 'luap',
					'python',
					'ocaml',
					'haskell',
					'r',
					-- web
					'html',
					'javascript', 'jsdoc', 'json',
					'typescript', 'tsx',
					'php',
					'sql',
				},

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = '<c-space>',
						node_incremental = '<c-space>',
						scope_incremental = false,
						node_decremental = '<C-backspace>',
					},
				},
			}
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		lazy = false,
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
	},
	{
		-- neovim haskell indenatation is terrible
		'itchyny/vim-haskell-indent',
		ft = 'haskell',
	},
	{
		-- same for nix
		'LnL7/vim-nix',
		ft = 'nix',
	},
	{
		'NvChad/nvim-colorizer.lua',
		config = true,
		ft = { 'vim', 'lua', 'html', 'css', 'js', 'php', 'scss', 'dosini' },
	},
	{
		'windwp/nvim-autopairs',
		event = { 'InsertEnter', 'CmdlineEnter' },
		config = function()
			require('nvim-autopairs').setup({
				enable_check_bracket_line = false,
				ignored_next_char = "[%w%.]",
			})
		end,
	},
	{
		'windwp/nvim-ts-autotag',
		config = true,
		ft = { 'html', 'css', 'php', 'xml', 'js' },
		dependencies = 'nvim-treesitter/nvim-treesitter',
	},
	{
		'RRethy/nvim-treesitter-endwise',
		config = function()
			require('nvim-treesitter.configs').setup {
				endwise = { enable = true },
			}
		end,
		ft = { 'lua', 'ruby', 'vimscript', 'sh', 'elixir', 'fish', 'julia' },
		dependencies = 'nvim-treesitter/nvim-treesitter',
	},
	{
		'andymass/vim-matchup',
		lazy = false,
		dependencies = 'nvim-treesitter/nvim-treesitter',
		config = function()
			vim.g.matchup_surround_enabled = 1
			vim.g.matchup_transmute_enabled = 1
			vim.g.matchup_delim_stopline = 43
			require('nvim-treesitter.configs').setup {
				matchup = {
					enable = true,
					disable = {},
				},
			}
		end
	},
	{
		'kylechui/nvim-surround',
		version = '*',
		config = true,
		keys = { 'cs', 'ds', 'ys', { 'S', mode = 'x' } },
	},
	{
		'numToStr/Comment.nvim',
		config = true,
		keys = { 'gc', 'gb', { 'gc', mode = 'x' }, { 'gb', mode = 'x' } },
	},
	{
		'chrisgrieser/nvim-spider',
		keys = {
			{ 'e', mode = { 'n', 'o', 'x' }, function() require('spider').motion('e') end },
			{ 'w', mode = { 'n', 'o', 'x' }, function() require('spider').motion('w') end },
			{ 'b', mode = { 'n', 'o', 'x' }, function() require('spider').motion('b') end },
		},
	},
	{
		'gbprod/substitute.nvim',
		config = true,
		keys = {
			{ 's',  mode = 'n', function() require('substitute').operator() end, desc = 'Substitute' },
			{ 'ss', mode = 'n',  function() require('substitute').line() end, },
			{ 'S',  mode = 'n',  function() require('substitute').eol() end, },
			{ 's',  mode = 'x',  function() require('substitute').visual() end, },
			{ '<leader>s', mode = 'n',  function() require('substitute.range').operator() end,  },
			{ '<leader>s', mode = 'x',  function() require('substitute.range').visual() end,  },
			{ '<leader>ss', mode = 'n', function() require('substitute.range').word() end,  },
			{ 'sx',  mode ='n', function() require('substitute.exchange').operator() end,  },
			{ 'sxx', mode ='n', function() require('substitute.exchange').line() end,  },
			{ 'X',   mode ='x', function() require('substitute.exchange').visual() end,  },
			{ 'sxc', mode ='n', function() require('substitute.exchange').cancel() end,  },
		},
	},
	{
		'tommcdo/vim-lion',
		config = function()
			vim.g.lion_squeeze_spaces = 1
		end,
		keys = {
			{ 'ga', mode = { 'n', 'x' } },
			{ 'gA', mode = { 'n', 'x' } }
		},
	},
	{
		'mbbill/undotree',
		config = function()
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_WindowLayout = 3
		end,
		keys = {
			{ '<leader>u', mode = 'n', vim.cmd.UndotreeToggle, desc = 'Undo tree' },
		},
	},
	{
		'folke/flash.nvim',
		lazy = true,
		opts = {},
		keys = {
			-- { 's', mode = { 'n', 'o', 'x' }, function() require('flash').jump() end, desc = 'Flash' },
			-- { 'S', mode = { 'n', 'o', 'x' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
			{ 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
			{ 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
			{ '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
			'/', 'f', 'F', 't', 'T',
		},
	},
	{
		'ibhagwan/fzf-lua',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		keys = {
			{ '<c-f>', mode = 'n', function() require('fzf-lua').files() end, desc = 'Fzf' },
			{ '<c-b>', mode = 'n', function() require('fzf-lua').buffers() end, desc = 'Fzf buffers' },
			{ '<c-g>', mode = 'n', function() require('fzf-lua').live_grep() end, desc = 'Fzf grep' }
		},
	},
	{
		'stevearc/oil.nvim',
		lazy = false, -- Can't be lazy because you can do 'nvim /path/to/dir'
		config = function()
			require('oil').setup {
				keymaps = {
					['gt'] = 'actions.open_terminal'
				}
			}
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrw_Plugin = 1
		end,
		keys = {
			{ '-', mode = 'n', function() require('oil').open(nil) end, desc = 'Oil file manager' },
		},
		ft = { 'netrw', 'oil' },
		dependencies = { 'nvim-tree/nvim-web-devicons' },

	},
	{
		'folke/zen-mode.nvim',
		opts = {},
		keys = {
			{ '<leader>z', mode = 'n', function() require('zen-mode').toggle({window = {width = .35}}) end},
		},
	},
	{
		'milanglacier/yarepl.nvim',
		config = function()
			-- to send a multiline function declaration to ghci you need to
			-- surround it like so:
			-- 	:{
			-- 	code here
			-- 	more code
			-- 	:}
			-- this function formats your visual selection to send it to ghci
			function send_lines_ghci(lines)
				local i = 1
				local e = #lines

				while i <= e do
					while lines[i] == '' do
						i = i + 1
					end

					-- If there's more than 1 non empty line left
					if i < e then
						table.insert(lines, i, ':{')
						i = i + 1
						e = e + 1

						while i <= e and lines[i] ~= '' do
							i = i + 1
						end

						table.insert(lines, i, ':}')
						i = i + 1
						e = e + 1
					else -- if there's only 1 left skip it to end the loop
						i = i + 1
					end
				end
				table.insert(lines, '\n')

				return lines
			end

			local yarepl = require 'yarepl'
			yarepl.setup {
				wincmd = 'vertical topleft 80 split',
				metas = {
					ghci = { cmd = 'ghci', formatter = send_lines_ghci },
					cling = { cmd = 'cling', formatter = yarepl.formatter.bracketed_pasting } -- TODO: Doesn't work
				},
			}

			-- The `run_cmd_with_count` function enables a user to execute a command with
			-- count values in keymaps. This is particularly useful for `yarepl.nvim`,
			-- which heavily uses count values as the identifier for REPL IDs.
			local function run_cmd_with_count(cmd)
				return function()
					vim.cmd(string.format('%d%s', vim.v.count, cmd))
				end
			end

			local ft_to_repl = {
				haskell = 'ghci',
				sh = 'bash',
				fish = 'fish',
				c = 'cling',
				cpp = 'cling'
			}

			local keymap = vim.api.nvim_set_keymap
			local bufmap = vim.api.nvim_buf_set_keymap
			local autocmd = vim.api.nvim_create_autocmd

			autocmd('FileType', {
				pattern = { 'haskell', 'sh', 'fish', 'c', 'cpp' },
				desc = 'set up REPL keymap',
				callback = function()
					local repl = ft_to_repl[vim.bo.filetype]
					bufmap(0, 'n', '<leader>rs', '', {
						callback = run_cmd_with_count('REPLStart '.. repl),
						desc = 'Start default REPL',
					})
				end,
			})
		end,
		ft = { 'haskell', 'sh', 'fish', 'c', 'cpp' },
		keys = {
			{ '<leader>rs', mode = 'n' },
			{ '<leader>e', mode = 'x', '<cmd>REPLSendVisual<cr>' },
			{ '<leader>e', mode = 'n', '<cmd>REPLSendLine<cr>j' },
			{ '<leader>a', mode = 'n', "mzggVG<cmd>REPLSendVisual<cr>'z" }, -- TODO: fix this
			{ '<leader>rx', mode = 'n', '<cmd>REPLClose<cr>' },
		},
	},
	{
		'rktjmp/lush.nvim',
		lazy = false,
	},
	{
		dir = '~/.config/nvim/lush-template',
		config = function()
			vim.cmd('colorscheme lush_template')
		end,
		dependencies = 'rktjmp/lush.nvim',
		priority = 1000,
		lazy = false,
	},
},
{
	defaults = {
		lazy = true
	},
})



--------------
-- Settings --
--------------

vim.opt.fileencoding = 'UTF-8'
vim.opt.title = true
vim.opt.shortmess = 'a'
vim.opt.lazyredraw = true
vim.opt.scrolloff = 4

vim.opt.termguicolors = true
-- vim.cmd('hi Normal guibg=NONE ctermbg=NONE') -- idk how to do this in lua the documentation is so bad
vim.opt.cursorline = true
vim.opt.fillchars = { eob = ' ' }
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = '↳ '
vim.api.nvim_set_hl(0, 'NonText', { bold = true, fg = cyan })
-- vim.fn.matchadd('ColorColumn', [[\%80v]], 100) -- This doesn't work with splits whatever vim sucks

vim.opt.equalalways = false
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.infercase = true

-- These settings are great with auto-save.nvim. It makes it so you can't loose
-- code, it does increase the ammounts of write on your disk though so if
-- you're using a hard drive you might want to reconsider autosave
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.undolevels = 5000
vim.opt.undofile = true
vim.opt.autoread = true

vim.api.nvim_create_autocmd('BufWritePre', {
	desc = 'Remove trailing spaces',
	-- pattern = '^(.*.diff)', -- for `git add -p` when you edit to remove '-' lines TODO: fix
	callback = function()
		vim.cmd([[%s/\s\+$//e]])
	end
})

-- Indentation --

vim.opt.expandtab = false
vim.opt.smartindent = true

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
	desc = 'Set indentation settings for haskell',
	pattern = '*.hs',
	callback = function()
		vim.opt.expandtab = true
		vim.opt.smartindent = true
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
	end,
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
	desc = 'Set indentation settings for curly brace languages',
	pattern = { '*.c', '*.cpp','*.h','*.hpp','*.lua','*.js','*.php', '*.sh', '.y', '.yy', '.l', '.ll'},
	callback = function()
		vim.opt.expandtab = false
		vim.opt.cindent = true
		vim.opt.tabstop = 6
		vim.opt.shiftwidth = 6
	end,
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
	desc = 'Set indentation settings for web stuff',
	pattern = { '*.html', '*.css', '*.nix' },
	callback = function()
		vim.expandtab = false
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
	end,
})

-------------
-- Keymaps --
-------------
vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('n', '<esc>', '<cmd>noh<cr>', { noremap = true })
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<cr>')
vim.keymap.set( 't', '<esc>', '<c-\\><c-n>')

-- copy pasta
vim.keymap.set('x', '<leader>y', ":'<,'>w !wl-copy<cr><cr>", { silent = true, noremap = true })
vim.keymap.set('n', '<leader>p', '<cmd>r !wl-paste<cr>', { silent = true, noremap = true })
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"_d')

-- Better mnemonics
-- alternative function for i(ncrement) and d(ecrement)
vim.keymap.set('n', '<m-i>', '<c-a>')
vim.keymap.set('n', '<m-d>', '<c-x>')
vim.keymap.set('n', '<c-a>', 'ggVG')
-- vim.keymap.set('n', '<a-u>', '<c-r>')
vim.keymap.set('n', '<c-w>', ':w<cr>')

-- Center cursor
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'J', 'mzJ`z')

-- Splits / Navigation --

-- switch
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')
-- resize
vim.keymap.set('n', '<c-m-h>', '5<c-w><')
vim.keymap.set('n', '<c-m-j>', '5<c-w>-')
vim.keymap.set('n', '<c-m-k>', '5<c-w>+')
vim.keymap.set('n', '<c-m-l>', '5<c-w>>')
vim.keymap.set('n', '<c-m-e>', '5<c-w>=')
-- close/open
vim.keymap.set('n', '<c-x>', ':bd<cr>') -- X out of here
vim.keymap.set('n', '<c-s>', ':vs<cr>')
vim.keymap.set('n', '<c-t>', ':vs |:terminal<cr>') -- Conflicts with oil

-- Move the visual selection up and down with J and K respectively
-- I need to make this a continous action so that it doesn't pollute the
-- undo history and spams auto save
-- vim.keymap.set('x', '<a-j>', ":m '>+1<CR>gv=gv")
-- vim.keymap.set('x', '<a-k>', ":m '<-2<CR>gv=gv")

-- -- quickfix stuff
-- vim.keymap.set('n', '<c-k>', '<cmd>cnext<cr>')
-- vim.keymap.set('n', '<c-j>', '<cmd>cprev<cr>')
-- vim.keymap.set('n', '<leader>k', '<cmd>lnext<cr>')
-- vim.keymap.set('n', '<leader>j', '<cmd>lprev<cr>')

-- vim.keymap.set('x', '<leader>y', function() vim.opt.clipboard = vim.opt.clipboard .. 'unnamedplus')

-- Lushify new highligh groups
-- vim.cmd('highlight BooleanOperators NONE')
-- vim.cmd([[match BooleanOperators /&&\|||\|^\|!\|!=\|==\|>\|>=\|<\|<=\|<=>\|===/]])
-- vim.cmd([[match BooleanOperators /&&/]])
