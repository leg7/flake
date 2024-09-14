-- TODO:
-- Add local completion fallback when lsp not available
-- configure lua snippets
-- Fix 'gl' conflict between vim-lion and lsp
-- make better treesitter text objects to improve navigation

vim.g.mapleader = ','

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
				lsp_zero.default_keymaps({buffer = bufnr, exclude = 'gl'})
			end)

			lsp_zero.setup_servers({
				'zls',
				'hls',
				'asm_lsp',
				'bashls',
				'ocamllsp',
				'clangd',
				'nixd',
				'lua_ls',
				'emmet_ls',
				'rust_analyzer',
			})


			lsp_zero.set_sign_icons({
				error = '',
				warn = '',
				hint = '⚑',
				info = ''
			})

			require('mason').setup()
			require('mason-lspconfig').setup({
				handlers = { lsp_zero.default_setup },
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
			'asm',
			'sh',
			'ocaml',
			'c', 'cpp',
			'nix',
			'lua',
			'html', 'js', 'php',
			'zig',
			'rust',
		},

		keys = {
			{ '<leader>i', mode = 'n', function() vim.diagnostic.open_float() end, },
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
					'rust',
					'zig',
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
						init_selection = '<space>',
						node_incremental = '<space>',
						scope_incremental = false,
						node_decremental = '<backspace>',
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
			{ 'gl', mode = { 'n', 'x' } },
			{ 'gL', mode = { 'n', 'x' } }
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
			{ '<leader>z', mode = 'n', function() require('zen-mode').toggle({window = {width = 120}, plugins = {options = {laststatus = 3}} }) end},
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
			{ '<leader>rs', mode = 'n', desc = 'REPL Start' },
			{ '<leader>re', mode = 'x', '<cmd>REPLSendVisual<cr>', desc = 'REPL execute visual selection' },
			{ '<leader>re', mode = 'n', '<cmd>REPLSendLine<cr>j', desc = 'REPL execute line' },
			{ '<leader>ra', mode = 'n', "mzggVG<cmd>REPLSendVisual<cr>'z", desc = 'REPL execute file' }, -- TODO: fix this
			{ '<leader>rx', mode = 'n', '<cmd>REPLClose<cr>', desc = 'REPL close' },
		},
	},
	{ 'rktjmp/lush.nvim', lazy = false, },
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000, lazy = false },
	{
		dir = '~/.config/nvim/lush-template',
		config = function()
			vim.cmd('colorscheme lush_template')
		end,
		dependencies = 'rktjmp/lush.nvim',
		priority = 1000,
		lazy = false,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			labels = "crstneiawlypfouqjvdhbgkzmx",
			modes = {
				search = { enabled = false, },
				char = { enabled = false, },
				treesitter = {
					labels = "crstneiawlypfouqjvdhbgkzmx",
					jump = { pos = "range" },
					search = { incremental = false },
					label = { before = true, after = true, style = "inline" },
					highlight = {
						backdrop = false,
						matches = false,
					},
				},
				treesitter_search = {
					jump = { pos = "range" },
					search = { multi_window = true, wrap = true, incremental = false },
					remote_op = { restore = true },
					label = { before = true, after = true, style = "inline" },
				},
			},
		},
		keys = {
			{ "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "<CR>", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			-- Idk what these do
			-- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
			-- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
		},
	},
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup {
				on_attach = function(bufnr)
					local gitsigns = require('gitsigns')

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map('n', ']c', function()
						if vim.wo.diff then
							vim.cmd.normal({']c', bang = true})
						else
							gitsigns.nav_hunk('next')
						end
					end)

					map('n', '[c', function()
						if vim.wo.diff then
							vim.cmd.normal({'[c', bang = true})
						else
							gitsigns.nav_hunk('prev')
						end
					end)

					-- Actions
					map('n', '<leader>hs', gitsigns.stage_hunk)
					map('n', '<leader>hr', gitsigns.reset_hunk)
					map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
					map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
					map('n', '<leader>hS', gitsigns.stage_buffer)
					map('n', '<leader>hu', gitsigns.undo_stage_hunk)
					map('n', '<leader>hR', gitsigns.reset_buffer)
					map('n', '<leader>hp', gitsigns.preview_hunk)
					map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
					map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
					map('n', '<leader>hd', gitsigns.diffthis)
					map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
					map('n', '<leader>td', gitsigns.toggle_deleted)

					-- Text object
					map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
				end
			}
		end,
		lazy = false,
	},
	{
		"https://git.sr.ht/~swaits/zellij-nav.nvim",
		lazy = false,
		keys = {
			{ "<a-h>", "<cmd>ZellijNavigateLeft<cr>",  { silent = true, desc = "navigate left"  } },
			{ "<a-j>", "<cmd>ZellijNavigateDown<cr>",  { silent = true, desc = "navigate down"  } },
			{ "<a-k>", "<cmd>ZellijNavigateUp<cr>",    { silent = true, desc = "navigate up"    } },
			{ "<a-l>", "<cmd>ZellijNavigateRight<cr>", { silent = true, desc = "navigate right" } },
		},
		opts = {},
	},
	{
		'ThePrimeagen/harpoon',
		branch = 'harpoon2',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			local harpoon = require('harpoon')
			harpoon:setup()
		end,
		keys = {
			{ '<leader>a', mode = 'n', function() require('harpoon'):list():add() end, desc = 'Harpoon add' },
			{ '<leader>e', mode = 'n', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Harpoon quick-menu' },
			{ '<leader>h', mode = 'n', function() require('harpoon'):list():select(1) end, desc = 'Harpoon select 1' },
			{ '<leader>t', mode = 'n', function() require('harpoon'):list():select(2) end, desc = 'Harpoon select 2' },
			{ '<leader>n', mode = 'n', function() require('harpoon'):list():select(3) end, desc = 'Harpoon select 3' },
			{ '<leader>s', mode = 'n', function() require('harpoon'):list():select(4) end, desc = 'Harpoon select 4' },
		},
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
vim.cmd('hi Normal guibg=NONE ctermbg=NONE') -- idk how to do this in lua the documentation is so bad
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
vim.keymap.set({'x', 'n'}, '<leader>y', '"cy<cmd>call system("wl-copy", @c)<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>p', '<cmd>r !wl-paste<cr>', { silent = true, noremap = true })
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"_d')

vim.keymap.set('n', '<a-a>', 'ggVG')
vim.keymap.set('n', '<c-w>', ':w<cr>')

-- Center cursor
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('i', '<esc>', '<esc>l')

-- Splits / Navigation --

-- switch handeled by zellij
-- resize
vim.keymap.set('n', '<c-h>', '5<c-w>>')
vim.keymap.set('n', '<c-j>', '5<c-w>+')
vim.keymap.set('n', '<c-k>', '5<c-w>-')
vim.keymap.set('n', '<c-l>', '5<c-w><')
vim.keymap.set('n', '<c-e>', '5<c-w>=')
-- close/open
vim.keymap.set('n', '<c-x>', ':close<cr>') -- X out of here
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

-- Lushify new highligh groups
-- vim.cmd('highlight BooleanOperators NONE')
-- vim.cmd([[match BooleanOperators /&&\|||\|^\|!\|!=\|==\|>\|>=\|<\|<=\|<=>\|===/]])
-- vim.cmd([[match BooleanOperators /&&/]])
