-- always set leader first!
vim.g.mapleader = ","

-------------------------------------------------------------------------------
--
-- preferences
--
-------------------------------------------------------------------------------
-- never ever folding
vim.opt.foldenable = false
vim.opt.foldmethod = 'manual'
vim.opt.foldlevelstart = 99
vim.opt.scrolloff = 2
-- never show me line breaks if they're not there
vim.opt.wrap = false
-- always draw sign column. prevents buffer moving when adding/deleting sign
vim.opt.signcolumn = 'yes'
-- sweet sweet relative line numbers
vim.opt.relativenumber = true
-- and show the absolute line number for the current line
vim.opt.number = true
-- keep current content top + left when splitting
vim.opt.splitright = true
vim.opt.splitbelow = true
-- infinite undo!
vim.opt.undofile = true
-- NOTE: ends up in ~/.local/state/nvim/undo/
vim.opt.expandtab = true 
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- case-insensitive search/replace
vim.opt.ignorecase = true
-- unless uppercase in search term
vim.opt.smartcase = true
-- never ever make my terminal beep
vim.opt.vb = true
-- more useful diffs (nvim -d)
--- by ignoring whitespace
vim.opt.diffopt:append('iwhite')
vim.opt.diffopt:append('algorithm:histogram')
vim.opt.diffopt:append('indent-heuristic')
-- show a column at 80 characters as a guide for long lines
vim.opt.colorcolumn = '80'
--- except in Rust where the rule is 100 characters
vim.api.nvim_create_autocmd('Filetype', { pattern = 'rust', command = 'set colorcolumn=100' })
-- show more hidden characters
-- enable system clipboard integration
vim.opt.clipboard = 'unnamedplus'
-- tags file locations: current file's dir, then walk up to repo root
vim.opt.tags = './tags,tags;~/'

-------------------------------------------------------------------------------
--
-- hotkeys
--
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader><leader>', '<c-^>')
-- <leader>, shows/hides hidden characters
vim.keymap.set('n', '<leader>,', ':set invlist<cr>')
-- always center search results
vim.keymap.set('n', 'n', 'nzz', { silent = true })
vim.keymap.set('n', 'N', 'Nzz', { silent = true })
vim.keymap.set('n', '*', '*zz', { silent = true })
vim.keymap.set('n', '#', '#zz', { silent = true })
vim.keymap.set('n', 'g*', 'g*zz', { silent = true })
-- "very magic" (less escaping needed) regexes by default
vim.keymap.set('n', '?', '?\\v')
vim.keymap.set('n', '/', '/\\v')
vim.keymap.set('c', '%s/', '%sm/')
-- handy keymap for replacing up to next _ (like in variable names)
vim.keymap.set('n', '<leader>m', 'ct_')
-- open file explorer (will be configured by nvim-tree below)
-- vim.keymap.set('n', '<leader>q', ':Ex<CR>')
-- universal copy/paste keymaps
vim.keymap.set('v', '<C-c>', '"+y', { desc = 'Copy to system clipboard' })
-- Map Ctrl+V to Visual Line mode
vim.keymap.set('n', '<C-v>', 'V', { desc = 'Enter Visual Line mode' })
-- F1 is pretty close to Esc, so you probably meant Esc
vim.keymap.set('', '<F1>', '<Esc>')
vim.keymap.set('i', '<F1>', '<Esc>')
-- Ctrl+j acts as Escape in both normal and insert mode
vim.keymap.set('n', '<C-j>', '<Esc>')
vim.keymap.set('i', '<C-j>', '<Esc>')
-- regenerate ctags for the project root (requires universal-ctags or ctags)
vim.keymap.set('n', '<leader>ct', function()
	local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
	if vim.v.shell_error ~= 0 then root = vim.fn.getcwd() end
	vim.fn.jobstart({ 'ctags', '-R', '--exclude=.git', root }, {
		on_exit = function(_, code)
			if code == 0 then
				vim.notify('tags regenerated', vim.log.levels.INFO)
			else
				vim.notify('ctags failed', vim.log.levels.WARN)
			end
		end,
	})
end, { desc = 'Regenerate ctags' })

-------------------------------------------------------------------------------
--
-- configuring diagnostics
--
-------------------------------------------------------------------------------
-- Allow virtual text
vim.diagnostic.config({ virtual_text = true, virtual_lines = false })

local aug = vim.api.nvim_create_augroup("UserFileReload", { clear = true })
vim.api.nvim_create_autocmd("FocusGained", {
  desc = "Reload files from disk when we focus vim",
  pattern = "*",
  command = "if getcmdwintype() == '' | checktime | endif",
  group = aug,
})
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Every time we enter an unmodified buffer, check if it changed on disk",
  pattern = "*",
  command = "if &buftype == '' && !&modified && expand('%') != '' | exec 'checktime ' . expand('<abuf>') | endif",
  group = aug,
})

-------------------------------------------------------------------------------
--
-- autocommands
--
-------------------------------------------------------------------------------
-- highlight yanked text

-------------------------------------------------------------------------------
--
-- formatting
--
-------------------------------------------------------------------------------
-- C/C++ always go through the clang-format binary (it picks up the nearest
-- .clang-format file); every other filetype formats via its LSP.
local clang_format_filetypes = {
	c = true,
	cpp = true,
	objc = true,
	objcpp = true,
	cuda = true,
	proto = true,
}

local function clang_format_buffer(buf)
	local view = vim.fn.winsaveview()
	local name = vim.api.nvim_buf_get_name(buf)
	if name == '' then
		name = vim.bo[buf].filetype == 'c' and 'buffer.c' or 'buffer.cpp'
	end
	local out = vim.fn.systemlist(
		{ 'clang-format', '--assume-filename=' .. name },
		vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	)
	if vim.v.shell_error ~= 0 then
		vim.notify('clang-format failed: ' .. table.concat(out, '\n'), vim.log.levels.ERROR)
		return
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
	vim.fn.winrestview(view)
end

-- used by <leader>c everywhere, including the LspAttach mapping below
function _G.format_buffer()
	local buf = vim.api.nvim_get_current_buf()
	if clang_format_filetypes[vim.bo[buf].filetype] and vim.fn.executable('clang-format') == 1 then
		clang_format_buffer(buf)
	else
		vim.lsp.buf.format { async = true }
	end
end

-- make gq/= reach for clang-format too, instead of clangd's formatexpr
local function use_clang_formatprg(buf)
	if vim.fn.executable('clang-format') == 0 then return end
	if not clang_format_filetypes[vim.bo[buf].filetype] then return end
	vim.bo[buf].formatprg = 'clang-format --assume-filename=' .. vim.fn.shellescape(vim.api.nvim_buf_get_name(buf))
	vim.bo[buf].formatexpr = ''
end

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
	callback = function(ev)
		use_clang_formatprg(ev.buf)
		vim.keymap.set('n', '<leader>c', _G.format_buffer, { buffer = ev.buf, desc = 'clang-format buffer' })
	end,
})

-- clangd sets formatexpr when it attaches, so claim it back afterwards
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(ev.buf) then
				use_clang_formatprg(ev.buf)
			end
		end)
	end,
})
-------------------------------------------------------------------------------
--
-- plugin configuration
--
-------------------------------------------------------------------------------
-- first, grab the manager
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- then, setup!
require("lazy").setup({
	-- main color scheme
	{
		"wincent/base16-nvim",
		lazy = false, -- load at start
		priority = 1000, -- load first
		config = function()
			vim.cmd([[colorscheme gruvbox-dark-hard]])
			vim.o.background = 'dark'
			vim.cmd([[hi Normal ctermbg=NONE]])
			-- Less visible window separator
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = 1250067 })
			-- Make comments orange
		-- 	vim.api.nvim_set_hl(0, 'Comment', { fg = '#FFA500' })
			-- Make it clearly visible which argument we're at.
			local bools = vim.api.nvim_get_hl(0, { name = 'Boolean' })
			vim.api.nvim_set_hl(0, 'Comment', bools)
			local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
			vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true })
			-- Set inline hint colors to pink
		--	vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = '#FF69B4' })
		--	vim.api.nvim_set_hl(0, 'CmpGhostText', { fg = '#FF69B4' })
		end
	},
    {'whonore/Coqtail'},
    { 'ntk148v/komau.vim' },
	-- nice bar at the bottom
	{
		'itchyny/lightline.vim',
		lazy = false, -- also load at start since it's UI
		config = function()
			-- no need to also show mode in cmd line when we have bar
			vim.o.showmode = false
			vim.g.lightline = {
				active = {
					left = {
						{ 'mode', 'paste' },
						{ 'readonly', 'filename', 'modified' }
					},
					right = {
						{ 'lineinfo' },
						{ 'percent' },
						{ 'fileencoding', 'filetype' }
					},
				},
				component_function = {
					filename = 'LightlineFilename'
				},
			}
			function LightlineFilenameInLua(opts)
				if vim.fn.expand('%:t') == '' then
					return '[No Name]'
				else
					return vim.fn.getreg('%')
				end
			end
			-- https://github.com/itchyny/lightline.vim/issues/657
			vim.api.nvim_exec(
				[[
				function! g:LightlineFilename()
					return v:lua.LightlineFilenameInLua()
				endfunction
				]],
				true
			)
		end
	},
	-- quick navigation
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			local builtin = require('telescope.builtin')
			local telescope = require('telescope')

			telescope.setup({
				defaults = {
					vimgrep_arguments = {
						'rg',
						'--color=never',
						'--no-heading',
						'--with-filename',
						'--line-number',
						'--column',
						'--smart-case'
					},
					preview = {
						treesitter = false,
					},
				}
			})

			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
			vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Telescope LSP references' })
			vim.keymap.set('n', '<leader>gr', builtin.grep_string, { desc = 'Telescope grep string' })
			vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, { desc = 'Telescope LSP document symbols' })
			vim.keymap.set('n', '<leader>d', function()
				builtin.diagnostics({ bufnr = 0 })
			end, { desc = 'Telescope diagnostics (current buffer)' })
			vim.keymap.set('n', '<leader>ft', builtin.tags, { desc = 'Telescope tags' })
			vim.keymap.set('n', '<leader>fT', builtin.current_buffer_tags, { desc = 'Telescope buffer tags' })
		end
	},
	-- quick file marks and navigation
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
			vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

			vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
			vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
			vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
			vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
		end
	},
	-- LSP
	{
		'neovim/nvim-lspconfig',
		config = function()
			-- Configure rust-analyzer with custom settings
			vim.lsp.config('rust_analyzer', {
				cmd = { 'rust-analyzer' },
				root_markers = { 'Cargo.toml', 'rust-project.json' },
				settings = {
					['rust-analyzer'] = {
						check = {
							command = 'clippy',
						},
						inlayHints = {
							chainingHints = { enable = true },
							parameterHints = { enable = true },
							typeHints = { enable = true },
							closureReturnTypeHints = { enable = 'always' },
							lifetimeElisionHints = { enable = 'skip_trivial' },
						},
					},
				},
			})

			-- Configure clangd for C/C++
			vim.lsp.config('clangd', {
				cmd = {
					'clangd',
					'--background-index',
					'--clang-tidy',
					'--header-insertion=iwyu',
					'--completion-style=detailed',
					'--function-arg-placeholders=true',
				},
			})

			-- Configure ty (Python type checker / LSP)
			vim.lsp.config('ty', {
				settings = {
					ty = {},
				},
			})

			-- Configure zls for Zig
			vim.lsp.config('zls', {
				cmd = { 'zls' },
				root_markers = { 'build.zig', 'build.zig.zon', '.git' },
				settings = {
					zls = {
						enable_inlay_hints = true,
						inlay_hints_show_builtin = true,
						include_at_in_builtins = false,
						warn_style = true,
					},
				},
			})

			-- Configure lua_ls, aware of the Neovim runtime
			vim.lsp.config('lua_ls', {
				settings = {
					Lua = {
						runtime = { version = 'LuaJIT' },
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file('', true),
						},
						diagnostics = { globals = { 'vim' } },
						telemetry = { enable = false },
					},
				},
			})

			-- Enable LSP servers
			-- Lua
			if vim.fn.executable('lua-language-server') == 1 then
				vim.lsp.enable('lua_ls')
			end

			-- Python
			if vim.fn.executable('ruff') == 1 then
				vim.lsp.enable('ruff')
			end
			if vim.fn.executable('ty') == 1 then
				vim.lsp.enable('ty')
			end

			-- SQL
			if vim.fn.executable('sqls') == 1 then
				vim.lsp.enable('sqls')
			end

			-- Rust
			if vim.fn.executable('rust-analyzer') == 1 then
				vim.lsp.enable('rust_analyzer')
			end

			-- C/C++
			if vim.fn.executable('clangd') == 1 then
				vim.lsp.enable('clangd')
			end

			-- Zig
			if vim.fn.executable('zls') == 1 then
				vim.lsp.enable('zls')
			end

			-- LaTeX
			if vim.fn.executable('texlab') == 1 then
				vim.lsp.enable('texlab')
			end

			-- Global mappings
			vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
			vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
			vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

			-- LSP mappings
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(ev)
					local opts = { buffer = ev.buf }
					vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
					vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)
					vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
					vim.keymap.set('n', '<leader>c', _G.format_buffer, opts)

					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					client.server_capabilities.semanticTokensProvider = nil

					local ft = vim.bo[ev.buf].filetype
					if ft == 'rust' or ft == 'c' or ft == 'cpp' or ft == 'java' or ft == 'zig' then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end
				end,
			})
		end
	},
	-- Java LSP via jdtls
	{
		'mfussenegger/nvim-jdtls',
		ft = 'java',
		config = function()
			local function start_jdtls()
				if vim.fn.executable('jdtls') == 0 then return end
				local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/'
					.. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
				require('jdtls').start_or_attach({
					cmd = { 'jdtls', '-data', workspace_dir },
					root_dir = vim.fs.root(0, { 'pom.xml', 'build.gradle', 'build.xml', '.git' }),
					settings = {
						java = {
							inlayHints = {
								parameterNames = { enabled = 'all' },
							},
						},
					},
				})
			end

			vim.api.nvim_create_autocmd('FileType', {
				pattern = 'java',
				callback = start_jdtls,
			})

			if vim.bo.filetype == 'java' then
				start_jdtls()
			end
		end,
	},
	-- LSP-based code-completion
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		event = "InsertEnter",
		-- these dependencies will only be loaded when cmp loads
		-- dependencies are always lazy-loaded unless specified otherwise
		dependencies = {
			'neovim/nvim-lspconfig',
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require'cmp'
			cmp.setup({
				snippet = {
					-- REQUIRED by nvim-cmp. get rid of it once we can
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<C-n>'] = cmp.mapping.select_next_item(),
					['<C-p>'] = cmp.mapping.select_prev_item(),
					-- Accept currently selected item.
					-- Set `select` to `false` to only confirm explicitly selected items.
					['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
				}),
				completion = {
					-- never auto-open the menu; <C-Space> summons it on demand.
					-- while typing, the inline ghost text below is the only hint.
					autocomplete = false,
				},
				performance = {
					max_view_entries = 8,
				},
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
				}, {
					{ name = 'buffer' },
					{ name = 'path' },
				}),
				experimental = {
					ghost_text = true,
				},
			})

			-- Enable completing paths in :
			cmp.setup.cmdline(':', {
				sources = cmp.config.sources({
					{ name = 'path' }
				})
			})
		end
	},
	-- inline function signatures
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			-- Get signatures (and _only_ signatures) when in argument lists.
			require "lsp_signature".setup({
				doc_lines = 0,
				-- no floating window; the inline hint carries the current param
				floating_window = false,
				hint_enable = true,
				hint_prefix = "",
				toggle_key = "<C-k>",
				handler_opts = {
					border = "none"
				},
			})
		end
	},
	-- LSP progress notifications
	{
		"j-hui/fidget.nvim",
		opts = {},
	},
	-- auto pairs for brackets, quotes, etc.
	{
		'windwp/nvim-autopairs',
		enabled = true,
		event = "InsertEnter",
		config = function()
			require('nvim-autopairs').setup({
				check_ts = false,
			})
			-- integration with nvim-cmp
			local cmp_autopairs = require('nvim-autopairs.completion.cmp')
			local cmp = require('cmp')
			cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
		end
	},
	-- git integration
	{
		'tpope/vim-fugitive',
		config = function()
			-- Git keymaps
			vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Git status' })
			vim.keymap.set('n', '<leader>ga', ':Git add .<CR>', { desc = 'Git add all' })
			vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = 'Git commit' })
			vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = 'Git push' })
			vim.keymap.set('n', '<leader>gl', ':Git log<CR>', { desc = 'Git log' })
			vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Git blame' })
			vim.keymap.set('n', '<leader>gd', ':Gdiffsplit<CR>', { desc = 'Git diff split' })
		end
	},
	-- git signs + inline blame
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup({
				current_line_blame = true,
				current_line_blame_opts = {
					delay = 300,
					virt_text_pos = 'eol',
				},
				on_attach = function(bufnr)
					local gs = require('gitsigns')
					local opts = { buffer = bufnr }
					vim.keymap.set('n', ']h', gs.next_hunk, opts)
					vim.keymap.set('n', '[h', gs.prev_hunk, opts)
					vim.keymap.set('n', '<leader>hs', gs.stage_hunk, opts)
					vim.keymap.set('n', '<leader>hr', gs.reset_hunk, opts)
					vim.keymap.set('n', '<leader>hp', gs.preview_hunk, opts)
					vim.keymap.set('n', '<leader>hb', gs.toggle_current_line_blame, opts)
				end,
			})
		end,
	},
	-- LaTeX support
	{
		'lervag/vimtex',
		lazy = false,
		init = function()
			-- PDF viewer (Skim on macOS, supports forward/reverse sync)
			vim.g.vimtex_view_method = 'skim'
			vim.g.vimtex_compiler_method = 'latexmk'
			-- Suppress some warnings
			vim.g.vimtex_quickfix_mode = 0
		end,
	},
	-- file explorer
	{
		'nvim-tree/nvim-tree.lua',
		dependencies = {
			'nvim-tree/nvim-web-devicons', -- optional, for file icons
		},
		config = function()
			-- disable netrw at the very start of your init.lua (recommended by nvim-tree)
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = {
					width = 30,
				},
				renderer = {
					group_empty = true,
				},
				filters = {
					dotfiles = false,
				},
				git = {
					enable = true,
					ignore = false,
				},
			})

			-- Keymaps
			vim.keymap.set('n', '<leader>q', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
			vim.keymap.set('n', '<leader>n', ':NvimTreeFocus<CR>', { desc = 'Focus file explorer' })
		end
	},
})


-- Inline LSP completion: top match shown as ghost text, no menu.
-- <Tab> accepts it, anything else ignores it.
local ghost = {}
ghost.ns = vim.api.nvim_create_namespace('inline_ghost')
ghost.text = nil
ghost.gen = 0
ghost.timer = nil

local function ghost_clear()
	vim.api.nvim_buf_clear_namespace(0, ghost.ns, 0, -1)
	ghost.text = nil
end

-- Ghost text is always a bare identifier: never a signature
-- ("push_back(value_type &&x)") and never a snippet body ("foo(${1:x})").
local function plain(item)
	local t = (item.textEdit and item.textEdit.newText) or item.insertText or item.label or ''
	return t:gsub('^%s+', ''):match('^[%w_]+') or ''
end

local function ghost_show()
	ghost.gen = ghost.gen + 1
	local gen = ghost.gen
	local buf = vim.api.nvim_get_current_buf()

	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local prefix = line:sub(1, col):match('[%w_]+$')
	if not prefix or #prefix < 2 then
		ghost_clear()
		return
	end

	local client
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		if c:supports_method('textDocument/completion') then
			client = c
			break
		end
	end
	if not client then
		ghost_clear()
		return
	end

	local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
	client:request('textDocument/completion', params, function(err, result)
		if err or not result or gen ~= ghost.gen then
			return
		end
		if vim.api.nvim_get_current_buf() ~= buf or vim.fn.mode() ~= 'i' then
			return
		end
		local items = result.items or result
		if type(items) ~= 'table' then
			return
		end

		-- best match = shortest completion that extends what you typed
		local best, best_sort
		local lower = prefix:lower()
		for _, item in ipairs(items) do
			local word = plain(item)
			if #word > #prefix and word:sub(1, #prefix):lower() == lower then
				local sort = item.sortText or item.label or word
				if not best_sort or sort < best_sort then
					best, best_sort = word, sort
				end
			end
		end

		vim.api.nvim_buf_clear_namespace(buf, ghost.ns, 0, -1)
		ghost.text = nil
		if not best then
			return
		end

		-- cursor may have moved while the server was thinking
		local cline = vim.api.nvim_get_current_line()
		local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
		if crow ~= row or cline:sub(1, ccol):match('[%w_]+$') ~= prefix then
			return
		end

		ghost.text = best:sub(#prefix + 1)
		vim.api.nvim_buf_set_extmark(buf, ghost.ns, crow - 1, ccol, {
			virt_text = { { ghost.text, 'Comment' } },
			virt_text_pos = 'inline',
			hl_mode = 'combine',
		})
	end, buf)
end

vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChangedP' }, {
	callback = function()
		ghost_clear()
		if ghost.timer then
			ghost.timer:stop()
		end
		ghost.timer = vim.defer_fn(ghost_show, 120)
	end,
})

vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufLeave' }, {
	callback = function()
		ghost.gen = ghost.gen + 1
		ghost_clear()
	end,
})

-- Not an expr mapping: expr runs under textlock, which forbids buffer edits.
vim.keymap.set('i', '<Tab>', function()
	if ghost.text and ghost.text ~= '' then
		local t = ghost.text
		ghost.gen = ghost.gen + 1
		ghost_clear()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { t })
		vim.api.nvim_win_set_cursor(0, { row, col + #t })
	else
		-- 'i': insert at the head of the typeahead so fast typing keeps its order
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'ni', false)
	end
end, { desc = 'Accept inline completion' })
