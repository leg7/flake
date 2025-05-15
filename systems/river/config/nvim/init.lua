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
		'neovim/nvim-lspconfig',
		dependencies = 'hrsh7th/cmp-nvim-lsp',
		config = function()

			local lspconfig_defaults = require('lspconfig').util.default_config
			lspconfig_defaults.capabilities = vim.tbl_deep_extend(
				'force',
				lspconfig_defaults.capabilities,
				require('cmp_nvim_lsp').default_capabilities()
			)

			local lspconfig = require('lspconfig')
			lspconfig.zls.setup({})
			lspconfig.hls.setup({
				-- TODO: figure out how to disable certain hints
			})
			lspconfig.asm_lsp.setup({})
			lspconfig.bashls.setup({})
			lspconfig.ocamllsp.setup({})
			lspconfig.clangd.setup({})
			lspconfig.nixd.setup({})
			lspconfig.lua_ls.setup({})
			lspconfig.emmet_ls.setup({})
			lspconfig.rust_analyzer.setup({})
			lspconfig.jdtls.setup({})
			lspconfig.pylsp.setup({})
		end,
		ft = {
			'zig',
			'haskell',
			'asm',
			'sh',
			'ocaml',
			'c', 'cpp',
			'nix',
			'lua',
			'html', 'js', 'php',
			'rust',
			'java',
			'python',
		},
		keys = {
			{ 'gd',      mode = 'n',        '<cmd>lua vim.lsp.buf.definition()<cr>',           desc = 'lsp: Go to definition of symbol' },
			{ 'gD',      mode = 'n',        '<cmd>lua vim.lsp.buf.declaration()<cr>',          desc = 'lsp: Go to declaration of symbol' },
			{ 'gi',      mode = 'n',        '<cmd>lua vim.lsp.buf.implementation()<cr>',       desc = 'lsp: Go to implementation of symbol' },
			{ 'go',      mode = 'n',        '<cmd>lua vim.lsp.buf.type_definition()<cr>',      desc = 'lsp: Go to type definition of symbol' },
			-- { 'gr',   mode = 'n',        '<cmd>lua vim.lsp.buf.references()<cr>',           desc = 'lsp: Find references of symbol' },
			{ 'gs',      mode = 'n',        '<cmd>lua vim.lsp.buf.signature_help()<cr>',       desc = 'lsp: Show signature help for function' },
			{ '<c-s>',   mode = 'i',        '<cmd>lua vim.lsp.buf.signature_help()<cr>',       desc = 'lsp: Show signature help for function' },
			{ 'gh',      mode = 'n',        '<cmd>lua vim.lsp.buf.hover()<cr>',       		   desc = 'lsp: Show information about symbol under the cursor' },
			{ 'gr',      mode = 'n',        '<cmd>lua vim.lsp.buf.rename()<cr>',               desc = 'lsp: Rename symbol under cursor' },
			{ 'gF',      mode = {'n', 'x'}, '<cmd>lua vim.lsp.buf.format({async = true})<cr>', desc = 'lsp: Format buffer (async)' },
			{ 'ga',      mode = 'n',        '<cmd>lua vim.lsp.buf.code_action()<cr>',          desc = 'lsp: Show code actions for symbol' },
		},
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = 'L3MON4D3/LuaSnip',
		event = 'InsertEnter',
		config = function()
			local cmp = require('cmp')
			cmp.setup({
				sources = {
					{name = 'nvim_lsp'},
				},
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				mapping = require('cmp').mapping.preset.insert({}),

			})
		end,
	},
	{
		'L3MON4D3/LuaSnip',
		event = 'InsertEnter',
	},
	{
		-- Configuring signs through nvim doesn't work so I have to use this
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v4.x',
		lazy = false,
		config = function()
			local lsp_zero = require('lsp-zero')
			lsp_zero.ui({
				float_border = 'rounded',
				sign_text = {
					error = '✘',
					warn = '▲',
					hint = '⚑',
					info = '»',
				},
			})
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		tag = "v0.9.3",
		event = 'BufEnter',
		config = function()
			require'nvim-treesitter.configs'.setup {
				highlight = { enable = true },

				indent = {
					disable = { 'bash', 'nix', 'haskell' },
					enable = true,
				},

				additional_vim_regex_highlighting = false,
				auto_install = true,

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
		event = 'BufEnter',
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
		opts = {},
		ft = { 'vim', 'lua', 'html', 'css', 'js', 'php', 'scss', 'dosini' },
	},
	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		opts = {
			enable_check_bracket_line = false,
			ignored_next_char = "[%w%.]",
		},
	},
	{
		'windwp/nvim-ts-autotag',
		opts = {},
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
		event = 'BufEnter',
		dependencies = 'nvim-treesitter/nvim-treesitter',
		init = function()
			vim.g.matchup_surround_enabled = 1
			vim.g.matchup_transmute_enabled = 1
			vim.g.matchup_delim_stopline = 43
		end,
		config = function()
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
		opts = {},
		keys = { 'cs', 'ds', 'ys', { 'S', mode = 'x' } },
	},
	{
		'numToStr/Comment.nvim',
		opts = {},
		keys = { 'gc', 'gb', { 'gc', mode = 'x' }, { 'gb', mode = 'x' } },
	},
	{
		'gbprod/substitute.nvim',
		opts = {},
		keys = {
			{ 's',  mode = 'n', function() require('substitute').operator() end, desc = 'Substitute' },
			{ 'ss', mode = 'n',  function() require('substitute').line() end, },
			{ 'S',  mode = 'n',  function() require('substitute').eol() end, },
			{ 's',  mode = 'x',  function() require('substitute').visual() end, },
			-- { '<leader>s', mode = 'n',  function() require('substitute.range').operator() end,  },
			-- { '<leader>s', mode = 'x',  function() require('substitute.range').visual() end,  },
			-- { '<leader>ss', mode = 'n', function() require('substitute.range').word() end,  },
			{ 'sx',  mode ='n', function() require('substitute.exchange').operator() end,  },
			{ 'sxx', mode ='n', function() require('substitute.exchange').line() end,  },
			{ 'X',   mode ='x', function() require('substitute.exchange').visual() end,  },
			{ 'sxc', mode ='n', function() require('substitute.exchange').cancel() end,  },
		},
	},
	{
		'tommcdo/vim-lion',
		init = function()
			vim.g.lion_squeeze_spaces = 1
		end,
		keys = {
			{ 'gl', mode = { 'n', 'x' } },
			{ 'gL', mode = { 'n', 'x' } }
		},
	},
	{
		'mbbill/undotree',
		init = function()
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
		config = function()
			require('fzf-lua').register_ui_select()
		end,
		keys = {
			{ '<c-f>', mode = 'n', function() require('fzf-lua').files() end, desc = 'Fzf' },
			{ '<c-b>', mode = 'n', function() require('fzf-lua').buffers() end, desc = 'Fzf buffers' },
			{ '<c-g>', mode = 'n', function() require('fzf-lua').live_grep() end, desc = 'Fzf grep' }
		},
	},
	{
		-- 'rmagatti/auto-session',
		-- I'm using this fork because the guy fixed my issue with oil and terminal restore
		'cameronr/auto-session',
		dependencies = { 'ibhagwan/fzf-lua' },
		lazy = false,

		init = function()
			vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
		end,
		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { '~/', '/' },
			auto_create = false, -- TODO: Auto create if I spent more than an hour in the session
			use_git_branch = true,
			-- log_level = 'debug',
		},
		keys = {
			{ '<leader>sf', mode = 'n', '<cmd>Autosession search<cr>', desc = "Find a session to open" },
			{ '<leader>sd', mode = 'n', '<cmd>Autosession delete<cr>', desc = "Find a session to delete" },
			{ '<leader>ss', mode = 'n', '<cmd>SessionSave<cr>', desc = "Save current session" },
		},
	},
	{
		'stevearc/oil.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		lazy = false,
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrw_Plugin = 1
		end,
		opts = {
			keymaps = {
				['gt'] = 'actions.open_terminal'
			},
		},
		keys = {
			{ '-', mode = 'n', function() require('oil').open(nil) end, desc = 'Oil file manager' },
		},
		ft = { 'netrw', 'oil' },
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
				-- For auto-session to restore repls properly
				format_repl_buffers_names = false,
				metas = {
					ghci = { cmd = 'ghci -Wall -Wno-unused-do-bind', formatter = send_lines_ghci },
					cling = { cmd = 'cling', formatter = yarepl.formatter.bracketed_pasting }, -- TODO: Doesn't work
					swipl = { cmd = 'swipl', formatter = yarepl.formatter.bracketed_pasting }, -- TODO: Make a formatter that wraps every line in `assert().` + make an action that loads the currently focused file
					python = { cmd = 'python', formatter = yarepl.formatter.bracketed_pasting }, -- TODO: Make a formatter that wraps every line in `assert().` + make an action that loads the currently focused file
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
				cpp = 'cling',
				prolog = 'swipl',
				python = 'python',
			}

			local bufmap = vim.api.nvim_buf_set_keymap
			local autocmd = vim.api.nvim_create_autocmd

			autocmd('FileType', {
				pattern = { 'haskell', 'sh', 'fish', 'c', 'cpp', 'prolog', 'python' },
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
		ft = { 'haskell', 'sh', 'fish', 'c', 'cpp', 'prolog', 'python' },
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
		opts = {}
	},
	{
		'lewis6991/gitsigns.nvim',
		opts = {
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
				map('n', '<leader>gs', gitsigns.stage_hunk)
				map('n', '<leader>gr', gitsigns.reset_hunk)
				map('v', '<leader>gs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
				map('v', '<leader>gr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
				map('n', '<leader>gS', gitsigns.stage_buffer)
				map('n', '<leader>gu', gitsigns.undo_stage_hunk)
				map('n', '<leader>gR', gitsigns.reset_buffer)
				map('n', '<leader>gp', gitsigns.preview_hunk)
				map('n', '<leader>gb', function() gitsigns.blame_line{full=true} end)
				map('n', '<leader>gtb', gitsigns.toggle_current_line_blame)
				map('n', '<leader>gd', gitsigns.diffthis)
				map('n', '<leader>gD', function() gitsigns.diffthis('~') end)
				map('n', '<leader>gtd', gitsigns.toggle_deleted)

				-- Text object
				map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
			end
		},
		event = 'BufEnter';
	},
	{
		'ThePrimeagen/harpoon',
		branch = 'harpoon2',
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = {},
		keys = {
			{ '<leader>a', mode = 'n', function() require('harpoon'):list():add() end, desc = 'Harpoon add' },
			{ '<leader>e', mode = 'n', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Harpoon quick-menu' },
			{ '<leader>n', mode = 'n', function() require('harpoon'):list():select(1) end, desc = 'Harpoon select 1' },
			{ '<leader>h', mode = 'n', function() require('harpoon'):list():select(2) end, desc = 'Harpoon select 2' },
			{ '<leader>.', mode = 'n', function() require('harpoon'):list():select(3) end, desc = 'Harpoon select 3' },
			{ '<leader>/', mode = 'n', function() require('harpoon'):list():select(4) end, desc = 'Harpoon select 4' },
		},
	},
	{
		'mrjones2014/smart-splits.nvim',
		opts = {
			cursor_follows_swapped_bufs = true,
		},
		keys = {
			-- Moving
			{ '<c-k>', mode = 'n', function() require('smart-splits').move_cursor_up()    end, desc = "Smart split move up" },
			{ '<c-j>', mode = 'n', function() require('smart-splits').move_cursor_down()  end, desc = "Smart split move down" },
			{ '<c-h>', mode = 'n', function() require('smart-splits').move_cursor_left()  end, desc = "Smart split move left" },
			{ '<c-l>', mode = 'n', function() require('smart-splits').move_cursor_right() end, desc = "Smart split move right" },
			-- Swapping
			{ '<a-k>', mode = 'n', function() require('smart-splits').swap_buf_up()    end, desc = "Smart split move up" },
			{ '<a-j>', mode = 'n', function() require('smart-splits').swap_buf_down()  end, desc = "Smart split move down" },
			{ '<a-h>', mode = 'n', function() require('smart-splits').swap_buf_left()  end, desc = "Smart split move left" },
			{ '<a-l>', mode = 'n', function() require('smart-splits').swap_buf_right() end, desc = "Smart split move right" },
			-- Resizing
			{ '<a-r>', mode = 'n', function() require('smart-splits').start_resize_mode() end, noremap = true, desc = "Smart split resize mode" },
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
vim.opt.lazyredraw = false
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
	pattern = { '*.c','*.cc','*.cpp','*.h','*.hh','*.hpp','*.lua','*.js','*.php','*.sh','.y','.yy','.l','.ll' },
	callback = function()
		vim.opt.expandtab = false
		vim.opt.cindent = true
		vim.opt.tabstop = 4
		vim.opt.shiftwidth = 4
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

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
	desc = 'Setup prolog filetype',
	pattern = { '*.pro', '*.P' },
	callback = function()
		vim.o.filetype = 'prolog'
	end,
})

vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		if vim.g.neovide then
			vim.opt.lazyredraw = false
			vim.o.guifont = "monospace:h14"
			-- vim.g.neovide_cursor_vfx_mode = "pixiedust"
			vim.g.neovide_transparency = 0.96
			vim.g.transparency = vim.g.neovide_transparency
			vim.g.neovide_floating_blur_amount_x = 0
			vim.g.neovide_floating_blur_amount_y = 0
			vim.g.neovide_floating_shadow = false

			vim.keymap.set({ "n", "v" }, "<C-+>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>")
			vim.keymap.set({ "n", "v" }, "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>")
			vim.keymap.set({ "n" , "v" }, "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>")

			local alpha = function()
				return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
			end
			vim.g.neovide_background_color = "#101623" .. alpha()
		end
	end
})

-------------
-- Keymaps --
-------------
vim.keymap.set('n', 'Q', '<nop>')
-- vim.keymap.set('n', '<esc>', '<cmd>noh<cr>', { noremap = true }) -- Disabled because I breaks smart_splits resize mode
vim.keymap.set('n', '<backspace>', '<cmd>noh<cr>', { noremap = true }) -- Disabled because I breaks smart_splits resize mode
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<cr>')
vim.keymap.set( 't', '<esc>', '<c-\\><c-n>')

-- copy pasta
vim.keymap.set({'x', 'n'}, '<leader>y', '"+y', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>p', '"+p', { silent = true, noremap = true })
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"_d')

vim.keymap.set('n', '<a-a>', 'ggVG')
vim.keymap.set('n', '<c-w>', ':w<cr>')

-- Center cursor
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('i', '<esc>', '<esc>l')

-- close/open
vim.keymap.set('n', '<c-x>', ':close<cr>') -- X out of here
vim.keymap.set('n', '<c-s>', ':vs<cr>')
vim.keymap.set('n', '<c-t>', ':vs |:terminal<cr>') -- Conflicts with oil

vim.keymap.set('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<cr>')

-- -- quickfix stuff
-- vim.keymap.set('n', '<c-k>', '<cmd>cnext<cr>')
-- vim.keymap.set('n', '<c-j>', '<cmd>cprev<cr>')
-- vim.keymap.set('n', '<leader>k', '<cmd>lnext<cr>')
-- vim.keymap.set('n', '<leader>j', '<cmd>lprev<cr>')
