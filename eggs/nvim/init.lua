-- Copyright (c) 2025, Kira Hasegawa
-- Licensed under the MIT license.

-- Pckr.nvim Commands Reference:
-- `:Pckr clean`    - Remove any disabled or unused plugins
-- `:Pckr install`  - Install missing plugins (optionally specify plugins)
-- `:Pckr update`   - Update installed plugins (optionally specify plugins)
-- `:Pckr upgrade`  - Upgrade pckr.nvim itself
-- `:Pckr sync`     - Clean, install, update, and upgrade plugins
-- `:Pckr status`   - View status of plugins
-- `:Pckr lock`     - Create a lockfile of plugins with their current commits
-- `:Pckr restore`  - Restore plugins using saved lockfile

-- Globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

-- Quick commands
-- `[range]` works for many commands (e.g., `:10,12d`, `:%s/old/new/g`)
-- Delete: `[range]d` or `3dd`, `%d` = all lines
-- Replace: `[range]s/old/new/g` (`c` = confirm, `i` = ignore case)

-- Options
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.opt.fillchars = { eob = " " }
vim.schedule(function() -- Schedule to set clipboard
	vim.o.clipboard = "unnamedplus"
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.laststatus = 0

-- Disable netrw (using Fyler)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Basic Keybinds
-- See `:help vim.keymap.set()`

-- To open file explorer, type `:Ex`,
-- where
-- `:Ex` - Open file explorer
-- For more info, see `:help Ex`

-- To clear search highlight, type `:nohlsearch`,
-- where
-- `:nohlsearch` - Clear search highlight and cursor position on search
-- For more info, see `:help nohlsearch`

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { unique = true, desc = "Open diagnostic [Q]uickfix list" })

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Instead of `left`, use `h` to move"<CR>', { unique = true, remap = false })
vim.keymap.set("n", "<right>", '<cmd>echo "Instead of `right`, use `l` to move"<CR>', { unique = true, remap = false })
vim.keymap.set("n", "<up>", '<cmd>echo "Instead of `up`, use `k` to move"<CR>', { unique = true, remap = false })
vim.keymap.set("n", "<down>", '<cmd>echo "Instead of `down`, use `j` to move"<CR>', { unique = true, remap = false })

-- Disable arrow keys in terminal mode
vim.keymap.set("t", "<Esc>", function()
	print("Instead of `<Esc>`, use `<C-\\><C-n>` to exit terminal mode")
end, { unique = true, remap = false })

-- For moving windows, use `<C-w><C-h>`, `<C-w><C-l>`, `<C-w><C-j>`, and `<C-w><C-k>`,
-- where
-- `<C-w><C-h>` - Move window to the left
-- `<C-w><C-l>` - Move window to the right
-- `<C-w><C-j>` - Move window to the lower
-- `<C-w><C-k>` - Move window to the upper

-- Disable easy window movement
-- See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", '<cmd>echo "Instead of `<C-h>`, use `<C-w><C-h>` to move"<CR>', { remap = false })
vim.keymap.set("n", "<C-l>", '<cmd>echo "Instead of `<C-l>`, use `<C-w><C-l>` to move"<CR>', { remap = false })
vim.keymap.set("n", "<C-j>", '<cmd>echo "Instead of `<C-j>`, use `<C-w><C-j>` to move"<CR>', { remap = false })
vim.keymap.set("n", "<C-k>", '<cmd>echo "Instead of `<C-k>`, use `<C-w><C-k>` to move"<CR>', { remap = false })

-- For splitting windows, use `<C-w><C-v>` and `<C-w><C-s>`,
-- where
-- `<C-w><C-v>` - Vertical split
-- `<C-w><C-s>` - Horizontal split

-- For closing windows, use `<C-w><C-c>`,
-- where
-- `<C-w><C-c>` - Close window

-- Autocommands
--  See `:help lua-guide-autocommands`

-- Set comment string keymap
-- vim.keymap.set("n", "gc", function()
-- 	return vim.bo.commentstring:gsub("%%s", "")
-- end, { expr = true, desc = "Comment out current line" })

--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
	desc = "Highlight when yanking (copying) text",
})

-- Handle last known cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("cursor", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
	desc = "Go to last known cursor position when opening a buffer",
})

-- Handle equalizing splits
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = vim.api.nvim_create_augroup("EqualizeSplits", {}),
	callback = function()
		local current_tab = vim.api.nvim_get_current_tabpage()
		vim.cmd("tabdo wincmd =")
		vim.api.nvim_set_current_tabpage(current_tab)
	end,
	desc = "Resize splits with terminal window",
})

-- Handle bootstrap of packr.nvim (successor of packer.nvim)
-- See https://github.com/lewis6991/pckr.nvim for more info
local function bootstrap_pckr()
	local path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
	if not (vim.uv or vim.loop).fs_stat(path) then
		out = vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/lewis6991/pckr.nvim",
			path,
		})

		if vim.v.shell_error == 0 then
			-- success
			print("Package manager installed successfully")
		else
			-- error
			error("Error cloning package manager:\n" .. out)
		end
	end

	vim.opt.rtp:prepend(path) -- Add pckr.nvim to runtimepath
end

-- Bootstrap plugin manager
bootstrap_pckr()

-- Get pckr.nvim functions
local command = require("pckr.loader.cmd")
local keys = require("pckr.loader.keys")

-- Define icons
local icons = {
	devicons = {
		default_icon = { icon = "󰈚", name = "Default" },
		js = { icon = "󰌞", name = "js" },
		ts = { icon = "󰛦", name = "ts" },
		lock = { icon = "󰌾", name = "lock" },
		["robots.txt"] = { icon = "󰚩", name = "robots" },
	},
	lspkind = {
		Namespace = "󰌗",
		Text = "󰉿",
		Method = "󰆧",
		Function = "󰆧",
		Constructor = "",
		Field = "󰜢",
		Variable = "󰀫",
		Class = "󰠱",
		Interface = "",
		Module = "",
		Property = "󰜢",
		Unit = "󰑭",
		Value = "󰎠",
		Enum = "",
		Keyword = "󰌋",
		Snippet = "",
		Color = "󱓻",
		File = "󰈚",
		Reference = "󰈇",
		Folder = "󰉋",
		EnumMember = "",
		Constant = "󰏿",
		Struct = "󰙅",
		Event = "",
		Operator = "󰆕",
		TypeParameter = "󰊄",
		Table = "",
		Object = "󰅩",
		Tag = "",
		Array = "[]",
		Boolean = "",
		Number = "",
		Null = "󰟢",
		Supermaven = "",
		String = "󰉿",
		Calendar = "",
		Watch = "󰥔",
		Package = "",
		Copilot = "",
		Codeium = "",
		TabNine = "",
		BladeNav = "",
	},
	diagnostics = {
		Error = "",
		Warn = "",
		Info = "",
		Hint = "",
	},
}

-- Install plugins hereby using `pckr.nvim`
require("pckr").add({
	{ -- Colorscheme
		"folke/tokyonight.nvim",
		config = function()
			-- Primary theme configuration
			require("tokyonight").setup({
				style = "night",
				transparent = true,
			})
			-- Apply colorscheme
			vim.cmd("colorscheme tokyonight")
		end,
	},

	{ -- Fuzzy Finder
		"ibhagwan/fzf-lua",
		config = function()
			-- Load fzf-lua
			local fzf_lua = require("fzf-lua")

			-- Setup custom keymaps
			vim.keymap.set("n", "<leader>ff", function()
				fzf_lua.files()
			end, { unique = true, desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", function()
				fzf_lua.live_grep()
			end, { unique = true, desc = "Find text" })
			vim.keymap.set("n", "<leader>fb", function()
				fzf_lua.buffers()
			end, { unique = true, desc = "Find buffers" })
		end,
	},

	{ -- Bookmarks
		"chentoast/marks.nvim",
		config = function()
			require("marks").setup({
				default_mappings = false,
				mappings = {
					set_next = "m,",
					toggle = "m;",
					delete_bookmark = "dmx",
					delete_line = "dm-",
					delete_buf = "dm<space>",
					next = "m]",
					prev = "m[",
					preview = "m:",
					-- set_bookmark0 = "m0",
					-- set_bookmark1 = "m1",
					-- set_bookmark2 = "m2",
					-- set_bookmark3 = "m3",
					-- set_bookmark4 = "m4",
					-- set_bookmark5 = "m5",
					-- set_bookmark6 = "m6",
					-- set_bookmark7 = "m7",
					-- set_bookmark8 = "m8",
					-- set_bookmark9 = "m9",
					-- delete_bookmark0 = "dm0",
					-- delete_bookmark1 = "dm1",
					-- delete_bookmark2 = "dm2",
					-- delete_bookmark3 = "dm3",
					-- delete_bookmark4 = "dm4",
					-- delete_bookmark5 = "dm5",
					-- delete_bookmark6 = "dm6",
					-- delete_bookmark7 = "dm7",
					-- delete_bookmark8 = "dm8",
					-- delete_bookmark9 = "dm9",
				},
			})
		end,
	},

	{ -- File Explorer
		"A7Lavinraj/fyler.nvim",
		config = function()
			local fyler = require("fyler")
			fyler.setup()
			vim.keymap.set("n", "<leader>e", function()
				fyler.open({ kind = "split_left_most" })
			end, { unique = true, desc = "Open Fyler View" })
		end,
	},


	{ -- Syntax
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	},

	{ -- Markdown Preview
		"OXY2DEV/markview.nvim",
	},

	{ -- Git
		"lewis6991/gitsigns.nvim",
		config = function()
			-- Only attach if inside a git repository
			vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
				callback = function()
					if vim.fn.isdirectory(".git") == 1 or vim.fn.finddir(".git", ".;") ~= "" then
						require("gitsigns").setup({
							signs = {
								add = { text = "+" },
								change = { text = "~" },
								delete = { text = "_" },
								topdelete = { text = "‾" },
								changedelete = { text = "~" },
							},
						})
					end
				end,
			})
		end,
	},

	{ -- Keymaps
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({
				preset = "helix",
				icons = {
					mappings = false,
				},
			})

			-- Set keymaps
			vim.keymap.set(
				"n",
				"<leader>?",
				"<cmd>WhichKey<cr>",
				{ unique = true, desc = "Buffer Local Keymaps (which-key)" }
			)
		end,
	},

	{ -- Debugger
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			-- Example: basic keymaps for debugging control
			vim.keymap.set("n", "<F5>", dap.continue, { unique = true, desc = "DAP Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { unique = true, desc = "DAP Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { unique = true, desc = "DAP Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { unique = true, desc = "DAP Step Out" })
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { unique = true, desc = "DAP Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { unique = true, desc = "DAP Conditional Breakpoint" })
		end,
	},

	{ -- Autocompletion
		"saghen/blink.cmp",
		-- run = "cargo build --releaese",
		requires = {
			{ "rafamadriz/friendly-snippets" }, -- Snippet collection for completion
		},
		config = function()
			require("blink.cmp").setup({
				keymap = {
					preset = "none", -- disable default keymaps

					-- Completion
					["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
					["<C-e>"] = { "hide", "fallback" },
					["<C-y>"] = { "select_and_accept", "fallback" },

					--  Navigation
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<C-p>"] = { "select_prev", "fallback_to_mappings" },
					["<C-n>"] = { "select_next", "fallback_to_mappings" },

					-- Documentation
					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },

					-- Snippets
					["<Tab>"] = { "snippet_forward", "fallback" },
					["<S-Tab>"] = { "snippet_backward", "fallback" },

					-- Signature
					["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
				},
				appearance = {
					nerd_font_variant = "mono",
				},
				completion = {
					documentation = { auto_show = false },
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
				fuzzy = {
					implementation = "lua", -- old: "prefer_rust"
				},
			})
		end,
	},

	{ -- Binary Manager
		"williamboman/mason.nvim",
		requires = {
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp" }, -- LSP → completion capabilities bridge
			{ "williamboman/mason-lspconfig.nvim" }, -- Mason ↔ LSP server glue
		},
		keys = {
			{ "<leader>df", vim.diagnostic.open_float, desc = "Show diagnostic in floating window" },
			{ "[d", vim.diagnostic.goto_prev, desc = "Go to previous diagnostic" },
			{ "]d", vim.diagnostic.goto_next, desc = "Go to next diagnostic" },
		},
		config = function()
			-- Diagnostic sign icons
			local function on_attach(client, bufnr)
				for severity, icon in pairs(icons.diagnostics) do
					local group = "DiagnosticVirtualText" .. severity .. "Border"
					vim.fn.sign_define("DiagnosticSign" .. severity, {
						text = icon,
						texthl = group,
						numhl = group,
					})
				end
			end

			-- LSP servers to automatically install & configure
			local servers = {
				"cssls",
				"html",
				"jdtls",
				"ts_ls",
				"lua_ls",
				"pyright",
				"rust_analyzer",
			}

			-- Handle vim start
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					local mason = require("mason")
					local mason_lsp = require("mason-lspconfig")
					local default_capabilities = require("cmp_nvim_lsp").default_capabilities()

					-- Start Mason
					mason.setup()

					-- Install servers automatically
					mason_lsp.setup({
						ensure_installed = servers,
						automatic_installation = true,
					})

					-- Attach LSP servers
					for _, server in ipairs(servers) do
						vim.lsp.config(server, {
							on_attach = on_attach,
							capabilities = default_capabilities,
						})
					end
				end,
			})
		end,
	},

	{ -- Luau LSP
		"lopi-py/luau-lsp.nvim",
		config = function()
			-- Core server options
			local opts = {
				platform = { type = "standard" },
				types = { roblox_security_level = "PluginSecurity" },
				sourcemap = {
					enabled = true,
					autogenerate = true,
					rojo_project_file = "default.project.json",
					sourcemap_file = "sourcemap.json",
				},
				plugin = { enabled = true, port = 3667 },
				fflags = {
					enable_new_solver = true,
					sync = true,
					override = {
						LuauTableTypeMaximumStringifierLength = "100",
					},
				},
			}

			-- Detect Rojo project automatically
			local root = vim.fs.root(0, function(name)
				return name:match(".+%.project%.json$")
			end)
			opts.platform.type = root and "roblox" or "standard"

			-- Distinguish .lua and .luau properly
			vim.filetype.add({
				extension = {
					lua = function(path)
						return path:match("%.nvim%.lua$") and "lua" or "luau"
					end,
				},
			})

			require("luau-lsp").setup(opts)
		end,
	},

	{ -- AI Autocompletion
		"monkoose/neocodeium",
		config = function()
			-- Handle vim start
			vim.api.nvim_create_autocmd("VimEnter", {
				once = true,
				callback = function()
					require("neocodeium").setup()
					vim.keymap.set("i", "<A-f>", require("neocodeium").accept)
				end,
			})
		end,
	},
})
