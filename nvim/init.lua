do
	-- [[ Setting options ]]
	-- See `:help vim.o`

	-- Set <space> as the leader key
	-- See `:help mapleader`
	--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	vim.g.have_nerd_font = true

	-- Set the cursor for Insert mode
	vim.o.guicursor = "i-ci:hor20-Cursor"

	-- Set highlight on search
	vim.o.hlsearch = false

	-- Set incremental search
	vim.o.incsearch = true

	-- Turn off line wrap
	vim.o.wrap = false

	-- Disable comments on new lines
	vim.o.formatoptions = "tqj"

	-- Make line numbers default
	vim.o.number = true
	vim.o.relativenumber = true

	-- Set tabs
	vim.o.tabstop = 2
	vim.o.softtabstop = 2
	vim.o.shiftwidth = 2
	vim.o.expandtab = true

	-- Enable mouse mode
	vim.o.mouse = "a"

	-- Sync clipboard between OS and Neovim.
	-- Schedule the setting after `UiEnter` because it can increase startup-time
	--  Remove this option if you want your OS clipboard to remain independent.
	--  See `:help 'clipboard'`
	vim.schedule(function()
		vim.o.clipboard = "unnamedplus"
	end)

	-- Save undo history
	vim.o.undofile = true

	-- Case-insensitive searching UNLESS \C or capital in search
	vim.o.ignorecase = true
	vim.o.smartcase = true

	-- Keep signcolumn on by default
	vim.wo.signcolumn = "yes"

	-- Decrease update time
	vim.o.updatetime = 250
	vim.o.timeoutlen = 300
	-- Set completeopt to have a better completion experience
	vim.o.completeopt = "menuone,noselect"

	-- Split new windows to the right
	vim.o.splitright = true
	vim.o.splitbelow = true

	-- Preview substitutions live
	vim.o.inccommand = "split"

	-- Show which line your cursor is on
	vim.o.cursorline = true

	-- Minimal number of screen lines to keep above and below the cursor
	vim.o.scrolloff = 5

	vim.o.confirm = true
end

do
	-- [[ Basic Keymaps ]]

	-- Clear highlights on search when pressing <Esc> in normal mode
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

	-- Keymaps for better default experience
	-- See `:help vim.keymap.set()`
	vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

	-- Escape insert mode
	vim.keymap.set("i", "jk", "<esc>")
	vim.keymap.set("i", "kj", "<esc>")

	-- Open new line below while in Insert mode
	vim.keymap.set("i", "<C-Enter>", "<esc>o")

	--  See `:help wincmd` for a list of all window commands
	vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
	vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
	vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
	vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

	-- Useful file commands
	vim.keymap.set("n", "<leader><leader>e", "<cmd>Ex<cr>", { desc = "[e]xplore directory of current file" })
	vim.keymap.set("n", "<leader><leader>q", "<cmd>q<cr>", { desc = "[q]uit nvim" })
	vim.keymap.set("n", "<leader><leader>w", "<cmd>w<cr>", { desc = "[w]rite file" })
	vim.keymap.set("n", "<leader><leader>s", "<cmd>w<cr><cmd>so<cr>", { desc = "write then [s]ource file" })

	-- Editing commands
	-- move selected blocks up and down (and format)
	vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
	vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
	-- clear the current line and stay in Normal mode
	vim.keymap.set("n", "<leader>cl", "S<esc>")

	-- [[ Highlight on yank ]]
	-- See `:help vim.highlight.on_yank()`
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking (copying) text",
		group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
		callback = function()
			vim.hl.on_yank()
		end,
	})

	-- Diagnostic Config & Keymaps
	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = { min = vim.diagnostic.severity.WARN } },

		-- can switch between these
		virtual_text = true, -- text shows up at the end of the line
		virtual_lines = false, -- text shows up underneath the line, with virtual lines

		-- auto open the float to easily read errors when jumping
		jump = {
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({
					bufnr = bufnr,
					scope = "cursor",
					focus = false,
				})
			end,
		},
	})

	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
	-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
	-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
	-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })

	-- Exit terminal mode with a simple shortcut
	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
end

-- [[ Plugin Manager ]]
-- See `:help vim.pack`, `:help vim.pack-examples`
do
	-- Inspect plugin state and pending updates:
	--  :lua vim.pack.update(nil, { offline = true })

	-- Update plugins:
	--  :lua vim.pack.update()

	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()
		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout
			if output == "" then
				output = "No output from build command."
			end
			vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
		end
	end

	-- Runs after a plugin is installed/updated and runs the build command
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
				run_build(name, { "make" }, ev.data.path)
				return
			end

			if name == "LuaSnip" then
				if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
					run_build(name, { "make", "install_jsregexp" }, ev.data.path)
				end
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end
		end,
	})
end

---Helper function for GitHub hosted plugins
---@param repo string
---@return string
local function gh(repo)
	return "https://github.com/" .. repo
end

-- [[ UI & Core UX Plugins ]]
do
	vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
	require("guess-indent").setup({})

	vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
	require("gitsigns").setup({
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	})

	vim.pack.add({ gh("folke/which-key.nvim") })
	require("which-key").setup({
		delay = 300,
		icons = { mappings = vim.g.have_nerd_font },
		spec = {
			{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			{ "gr", group = "LSP Actions", mode = { "n" } },
		},
	})

	-- [[ Colorscheme ]]
	vim.pack.add({ gh("catppuccin/nvim") })
	require("catppuccin").setup({
		flavour = "macchiato",
	})
	vim.cmd.colorscheme("catppuccin")

	vim.pack.add({ gh("folke/todo-comments.nvim") })
	require("todo-comments").setup({ signs = false })

	vim.pack.add({ gh("nvim-mini/mini.nvim") })

	if vim.g.have_nerd_font then
		require("mini.icons").setup()
		MiniIcons.mock_nvim_web_devicons()
	end

	require("mini.ai").setup({
		mappings = {
			around_next = "aa",
			inside_next = "ii",
		},
		n_lines = 500,
	})

	require("mini.surround").setup()

	require("mini.pairs").setup()

	local statusline = require("mini.statusline")
	statusline.setup({ use_icons = vim.g.have_nerd_font })

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end

	-- Split help windows to the right, instead of above
	-- usage: type `:H ` followed by the help topic
	vim.cmd("cnoreabbrev H vert h")

	vim.pack.add({ gh("wet-sandwich/toolbox.nvim") })
	require("toolbox").setup({
		logger = {
			print_statements = {
				lua = {
					info = 'print("%s:", vim.inspect(%s))',
					debug = 'print("***DEBUG*** %s:", vim.inspect(%s))',
					warn = 'vim.notify("%s:" .. vim.inspect(%s), vim.log.levels.WARN)',
					error = 'vim.notify("%s:" .. vim.inspect(%s), vim.log.levels.ERROR)',
				},
			},
		},
	})

	-- Semantic version incrementing keymaps
	vim.keymap.set("n", "<C-M-m>", "<cmd>TBIncSemver major<cr>", { desc = "Increment [M]ajor version" })
	vim.keymap.set("n", "<C-M-n>", "<cmd>TBIncSemver minor<cr>", { desc = "Increment mi[N]or version" })
	vim.keymap.set("n", "<C-M-p>", "<cmd>TBIncSemver patch<cr>", { desc = "Increment [P]atch version" })

	-- Npm install keymaps
	vim.keymap.set("n", "<leader>ni", "<cmd>TBNpmInstall all<cr>", { desc = "Run [N]pm [I]nstall" })
	vim.keymap.set("n", "<leader>np", "<cmd>TBNpmInstall package<cr>", { desc = "Run [N]pm install [P]ackage" })
	vim.keymap.set("n", "<leader>nr", "<cmd>TBNpmRun<cr>", { desc = "[N]pm [R]un script" })

	-- Variable logging keymaps
	vim.keymap.set({ "n", "v" }, "<leader>li", "<cmd>TBLogVariable info<cr>", { desc = "[L]og variable [I]nfo" })
	vim.keymap.set({ "n", "v" }, "<leader>ld", "<cmd>TBLogVariable debug<cr>", { desc = "[L]og variable [D]ebug" })
	vim.keymap.set({ "n", "v" }, "<leader>lw", "<cmd>TBLogVariable warn<cr>", { desc = "[L]og variable [W]arn" })
	vim.keymap.set({ "n", "v" }, "<leader>le", "<cmd>TBLogVariable error<cr>", { desc = "[L]og variable [E]rror" })

	-- JSON keymaps
	vim.keymap.set({ "n", "v" }, "<leader>jf", "<cmd>TBJson format<cr>", { desc = "[J]SON [F]ormat" })
	vim.keymap.set({ "n", "v" }, "<leader>jp", "<cmd>TBJson parse<cr>", { desc = "[J]SON [P]arse" })
	vim.keymap.set({ "n", "v" }, "<leader>js", "<cmd>TBJson stringify<cr>", { desc = "[J]SON [S]tringify" })

	-- Diff Checker keymaps
	vim.keymap.set("n", "<leader>dc", "<cmd>TBDiffChecker<cr>", { desc = "Open [D]iff [C]hecker" })

	-- Floaterminal keymaps
	vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")
	vim.keymap.set({ "n", "t" }, "<leader><leader>t", "<cmd>TBFloaterminal<cr>", { desc = "[T]oggle t[E]rminal" })
end

do
	-- [[ Search & Navigation ]]

	---@type (string|vim.pack.Spec)[]
	local telescope_plugins = {
		gh("nvim-lua/plenary.nvim"),
		gh("nvim-telescope/telescope.nvim"),
		gh("nvim-telescope/telescope-ui-select.nvim"),
	}
	if vim.fn.executable("make") == 1 then
		table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
	end

	vim.pack.add(telescope_plugins)

	require("telescope").setup({
		extensions = {
			["ui-select"] = { require("telescope.themes").get_dropdown() },
		},
	})

	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
	vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[?] Find recently opened files" })
	vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[ ] Find existing buffers" })
	vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Search [G]it [F]iles" })

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
		callback = function(event)
			local buf = event.buf

			vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })

			vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })

			vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })

			vim.keymap.set(
				"n",
				"grt",
				builtin.lsp_type_definitions,
				{ buffer = buf, desc = "[G]oto [T]ype Definition" }
			)

			vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Open Document Symbols" })

			vim.keymap.set(
				"n",
				"gW",
				builtin.lsp_dynamic_workspace_symbols,
				{ buffer = buf, desc = "Open Workspace Symbols" }
			)
		end,
	})

	vim.keymap.set("n", "<leader>/", function()
		-- You can pass additional configuration to telescope to change theme, layout, etc.
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("n", "<leader>sn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config"), follow = true })
	end, { desc = "[S]earch [N]eovim files" })

	vim.pack.add({ gh("smoka7/hop.nvim") })
	require("hop").setup({
		keys = "etovxqpdygfblzhckisuran",
	})

	function HopForward()
		return require("hop").hint_words({ direction = require("hop.hint").HintDirection.AFTER_CURSOR })
	end
	function HopBackward()
		return require("hop").hint_words({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR })
	end
	vim.keymap.set("n", "<leader>w", HopForward, { desc = "hop [w]ords after cursor" })
	vim.keymap.set("n", "<leader>b", HopBackward, { desc = "hop words [b]efore cursor" })

	vim.pack.add({ gh("stevearc/oil.nvim") })
	require("oil").setup({
		skip_confirm_for_simple_edits = true,
		default_file_explorer = true,
	})
	vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })

	vim.pack.add({ gh("MunifTanjim/nui.nvim") })

	vim.pack.add({ gh("nvim-neo-tree/neo-tree.nvim") })
	require("neo-tree").setup({
		filesystem = {
			hijack_netrw_behavior = "disabled",
		},
	})
	vim.keymap.set("n", "<leader>tt", "<cmd>Neotree toggle<cr>", { desc = "[T]ree [T]oggle" })
	vim.keymap.set("n", "<leader>tr", "<cmd>Neotree reveal<cr>", { desc = "[T]ree [R]eveal" })
end

do
	-- [[ LSP Config ]]

	vim.pack.add({ gh("j-hui/fidget.nvim") })
	require("fidget").setup({})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(event)
			local map = function(keys, func, desc, mode)
				mode = mode or "n"
				vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP:" .. desc })
			end

			map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

			map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

			map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client:supports_method("textDocument/inlayHint", event.buf) then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})

	---@type table<string, vim.lsp.Config>
	local servers = {
		gopls = {},
		html = { filetypes = { "html", "twig", "hbs" } },
		ts_ls = {},
		stylua = {},

		lua_ls = {
			on_init = function(client)
				client.server_capabilities.documentFormattingProvider = false

				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = { "lua/?.lua", "lua/?/init.lua" },
					},
					workspace = {
						checkThirdParty = false,
						library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
							"${3rd}/luv/library",
							"${3rd}/busted/library",
						}),
					},
				})
			end,
			---@type lspconfig.settings.lua_ls
			settings = {
				Lua = {
					format = { enable = false },
				},
			},
		},
	}

	vim.pack.add({
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})

	require("mason").setup({})

	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, {})

	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	for name, server in pairs(servers) do
		vim.lsp.config(name, server)
		vim.lsp.enable(name)
	end
end

do
	-- [[ Formatting ]]
	vim.pack.add({ gh("stevearc/conform.nvim") })
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			local enabled_filetypes = {
				lua = true,
				go = true,
				js = true,
			}
			if enabled_filetypes[vim.bo[bufnr].filetype] then
				return { timeout_ms = 500 }
			else
				return nil
			end
		end,
		default_format_opts = {
			lsp_format = "fallback",
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>f", function()
		require("conform").format({ async = true })
	end, { desc = "[F]ormat buffer" })
end

do
	-- [[ Snippet Engine ]]
	vim.pack.add({ { src = gh("L3Mon4D3/LuaSnip"), version = vim.version.range("2.*") } })
	require("luasnip").setup({})

	-- [[ Autocomplete Engine ]]
	vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
	require("blink.cmp").setup({
		keymap = {
			preset = "default",
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},

		sources = {
			default = { "lsp", "path", "snippets" },
		},

		snippets = { preset = "luasnip" },

		fuzzy = { implementation = "lua" },

		signature = { enabled = true },
	})
end

do
	-- [[ Configure Treesitter ]]
	vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

	local parsers =
		{ "bash", "c", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline", "query", "vim", "vimdoc" }
	require("nvim-treesitter").install(parsers)

	---@param buf integer
	---@param language string
	local function treesitter_try_attach(buf, language)
		if not vim.treesitter.language.add(language) then
			return
		end
		vim.treesitter.start(buf, language)

		local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

		if has_indent_query then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	local available_parsers = require("nvim-treesitter").get_available()
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local buf, filetype = args.buf, args.match

			local language = vim.treesitter.language.get_lang(filetype)
			if not language then
				return
			end

			local installed_parsers = require("nvim-treesitter").get_installed("parsers")

			if vim.tbl_contains(installed_parsers, language) then
				treesitter_try_attach(buf, language)
			elseif vim.tbl_contains(available_parsers, language) then
				require("nvim-treesitter").install(language):await(function()
					treesitter_try_attach(buf, language)
				end)
			else
				treesitter_try_attach(buf, language)
			end
		end,
	})
end

do
	-- [[ External ]]

	vim.pack.add({ gh("kdheepak/lazygit.nvim") })
	vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "[L]azy[g]it" })
end

-- Git related plugins
-- "tpope/vim-fugitive",
-- "tpope/vim-rhubarb",

-- Detect tabstop and shiftwidth automatically
-- "tpope/vim-sleuth",

-- "gc" to comment visual regions/lines
-- { "numToStr/Comment.nvim", opts = {} },
-- }, {})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
