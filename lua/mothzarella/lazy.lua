vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.noop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy")

require("mothzarella.opts")
require("mothzarella.remap")

-- lazy setup
lazy.setup({
	spec = {
		"christoomey/vim-tmux-navigator",

		-- avante
		{
			"yetone/avante.nvim",
			event = "VeryLazy",
			lazy = false,
			version = false,
			keys = {
				{
					"<leader>cc",
					function()
						require("avante").toggle()
					end,
					desc = "Toggle Avante",
				},
			},
			opts = {
				provider = "copilot",
				auto_suggestions_provider = "copilot",
				windows = { position = "left" },
			},
			behaviour = {
				auto_suggestions = true,
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = false,
				minimize_diff = true,
			},
			build = "make",
			dependencies = {
				"stevearc/dressing.nvim",
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				"echasnovski/mini.pick",
				"nvim-telescope/telescope.nvim",
				"hrsh7th/nvim-cmp",
				"ibhagwan/fzf-lua",
				"nvim-tree/nvim-web-devicons",
				"github/copilot.vim",
				{
					"HakonHarnes/img-clip.nvim",
					event = "VeryLazy",
					opts = {
						default = {
							embed_image_as_base64 = false,
							prompt_for_file_name = false,
							drag_and_drop = {
								insert_mode = true,
							},
							use_absolute_path = true,
						},
					},
				},
				{
					"MeanderingProgrammer/render-markdown.nvim",
					opts = {
						file_types = { "markdown", "Avante" },
					},
					ft = { "markdown", "Avante" },
				},
			},
		},

		-- barbecue
		{
			"utilyre/barbecue.nvim",
			name = "barbecue",
			version = "*",
			dependencies = { "SmiteshP/nvim-navic" },
			config = function()
				require("barbecue").setup({
					exclude_filetypes = {},
					show_dirname = false,
					show_basename = false,
				})
			end,
		},

		-- CMP
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				{
					"L3MON4D3/LuaSnip",
					dependencies = { "rafamadriz/friendly-snippets" },
					build = (function()
						if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
							return
						end
						return "make install_jsregexp"
					end)(),
				},
				"saadparwaiz1/cmp_luasnip",

				"windwp/nvim-autopairs",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-path",
			},
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
				require("nvim-autopairs").setup({})

				local cmp = require("cmp")
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				local luasnip = require("luasnip")

				luasnip.config.setup({})

				local options = {
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					completion = { completeopt = "menu,menuone,noinsert" },
					mapping = cmp.mapping.preset.insert({

						-- completion
						["<C-n>"] = cmp.mapping.select_next_item(),
						["<C-p>"] = cmp.mapping.select_prev_item(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
						["<C-Space>"] = cmp.mapping(function()
							if cmp.visible() then
								cmp.close()
							else
								cmp.complete()
							end
						end, { "i", "s" }),

						-- documentation
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),

						["<C-l>"] = cmp.mapping(function()
							if luasnip.expand_or_locally_jumpable() then
								luasnip.expand_or_jump()
							end
						end, { "i", "s" }),
						["<C-h>"] = cmp.mapping(function()
							if luasnip.locally_jumpable(-1) then
								luasnip.jump(-1)
							end
						end, { "i", "s" }),
					}),
					sources = {
						{
							name = "lazydev",
							group_index = 0,
						},
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "path" },
					},
				}

				options = vim.tbl_deep_extend("force", options, require("nvchad.cmp"))

				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
				cmp.setup(options)
			end,
		},

		-- comments
		{
			-- todo
			{
				"folke/todo-comments.nvim",
				event = "VimEnter",
				dependencies = { "nvim-lua/plenary.nvim" },
				opts = true,
			},

			-- ts-comments (overwrites native comments)
			{
				"folke/ts-comments.nvim",
				opts = {},
				event = "VeryLazy",
				enabled = vim.fn.has("nvim-0.10.0") == 1,
			},
		},

		-- DAP
		{
			"mfussenegger/nvim-dap",
			dependencies = {
				"rcarriga/nvim-dap-ui",
				"nvim-neotest/nvim-nio",
				"williamboman/mason.nvim",
				"jay-babu/mason-nvim-dap.nvim",

				{ "leoluz/nvim-dap-go", ft = "go" },
			},
			keys = {
				{
					"<F5>",
					function()
						require("dap").continue()
					end,
					desc = "Debug: Start/Continue",
				},
				{
					"<F1>",
					function()
						require("dap").step_into()
					end,
					desc = "Debug: Step Into",
				},
				{
					"<F2>",
					function()
						require("dap").step_over()
					end,
					desc = "Debug: Step Over",
				},
				{
					"<F3>",
					function()
						require("dap").step_out()
					end,
					desc = "Debug: Step Out",
				},
				{
					"<leader>b",
					function()
						require("dap").toggle_breakpoint()
					end,
					desc = "Debug: Toggle Breakpoint",
				},
				{
					"<leader>B",
					function()
						require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
					end,
					desc = "Debug: Set Breakpoint",
				},
				{
					"<leader>d",
					function()
						require("dapui").toggle()
					end,
					desc = "Debug: See last session result.",
				},
				{
					"<leader>dr",
					function()
						require("dapui").open({ reset = true })
					end,
					desc = "Debug: Reset UI",
				},
			},
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")

				require("mason-nvim-dap").setup({
					automatic_installation = true,

					handlers = {},

					ensure_installed = { "delve", "codelldb", "debugpy" },
				})

				dapui.setup()

				if not dap.adapters then
					dap.adapters = {}
				end

				-- go
				require("dap-go").setup({
					delve = {
						detached = vim.fn.has("win32") == 0,
					},
				})

				-- rust
				dap.adapters.gdb = {
					type = "executable",
					command = "gdb",
					args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
				}
				dap.configurations.c = {
					{
						name = "Launch",
						type = "gdb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopAtBeginningOfMainSubprogram = false,
					},
					{
						name = "Select and attach to process",
						type = "gdb",
						request = "attach",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						pid = function()
							local name = vim.fn.input("Executable name (filter): ")
							return require("dap.utils").pick_process({ filter = name })
						end,
						cwd = "${workspaceFolder}",
					},
					{
						name = "Attach to gdbserver :1234",
						type = "gdb",
						request = "attach",
						target = "localhost:1234",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
					},
				}

				dap.listeners.after.event_initialized["dapui_config"] = dapui.open
				dap.listeners.before.event_terminated["dapui_config"] = dapui.close
				dap.listeners.before.event_exited["dapui_config"] = dapui.close
			end,
		},

		-- formatter
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			keys = {
				{
					"<leader>cf",
					function()
						require("conform").format({ async = true, lsp_format = "fallback" })
					end,
					mode = { "n", "x" },
					desc = "[F]ormat buffer",
				},
			},
			opts = {
				notify_on_error = false,
				format_on_save = function(bufnr)
					local disable_filetypes = { c = true, cpp = true }
					local lsp_format_opt
					if disable_filetypes[vim.bo[bufnr].filetype] then
						lsp_format_opt = "never"
					else
						lsp_format_opt = "fallback"
					end
					return {
						timeout_ms = 500,
						lsp_format = lsp_format_opt,
					}
				end,
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "goimports", "gofumpt" },
					python = { "black" },
					typescript = { "prettier" },
				},
			},
		},

		-- git
		{
			{
				"lewis6991/gitsigns.nvim",
				opts = {
					on_attach = function(bufnr)
						local gitsigns = require("gitsigns")

						local function map(mode, l, r, opts)
							opts = opts or {}
							opts.buffer = bufnr
							vim.keymap.set(mode, l, r, opts)
						end

						-- Navigation
						map("n", "]c", function()
							if vim.wo.diff then
								vim.cmd.normal({ "]c", bang = true })
							else
								gitsigns.nav_hunk("next")
							end
						end, { desc = "Jump to next git [c]hange" })

						map("n", "[c", function()
							if vim.wo.diff then
								vim.cmd.normal({ "[c", bang = true })
							else
								gitsigns.nav_hunk("prev")
							end
						end, { desc = "Jump to previous git [c]hange" })
					end,
				},
			},
			{
				"kdheepak/lazygit.nvim",
				lazy = true,
				cmd = {
					"LazyGit",
					"LazyGitConfig",
					"LazyGitCurrentFile",
					"LazyGitFilter",
					"LazyGitFilterCurrentFile",
				},
				dependencies = { "nvim-lua/plenary.nvim" },
				keys = {
					{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "[L]azy git" },
				},
			},
		},

		-- languages
		{
			-- go
			{
				"ray-x/go.nvim",
				dependencies = { "ray-x/guihua.lua" },
				config = function()
					require("go").setup({})
				end,
				event = { "CmdlineEnter" },
				ft = { "go", "gomod" },
				build = ':lua require("go.install").update_all_sync()',
			},

			-- rust
			{
				"saecki/crates.nvim",
				event = { "BufRead Cargo.toml" },
				opts = {
					completion = {
						crates = {
							enabled = true,
						},
					},
					lsp = {
						enabled = true,
						actions = true,
						completion = true,
						hover = true,
					},
				},
			},

			-- c/c++
			{
				"p00f/clangd_extensions.nvim",
				lazy = true,
				config = function() end,
				opts = {
					inlay_hints = {
						inline = false,
					},
					ast = {
						role_icons = {
							type = "",
							declaration = "",
							expression = "",
							specifier = "",
							statement = "",
							["template argument"] = "",
						},
						kind_icons = {
							Compound = "",
							Recovery = "",
							TranslationUnit = "",
							PackExpansion = "",
							TemplateTypeParm = "",
							TemplateTemplateParm = "",
							TemplateParamObject = "",
						},
					},
				},
			},
		},

		-- leap
		{
			"ggandor/leap.nvim",
			lazy = false,
			config = function()
				require("leap").setup({})
			end,
		},

		-- lint
		{
			"mfussenegger/nvim-lint",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				local lint = require("lint")
				lint.linters_by_ft = {
					markdown = { "markdownlint" },
					clojure = { "clj-kondo" },
					dockerfile = { "hadolint" },
					inko = { "inko" },
					janet = { "janet" },
					json = { "jsonlint" },
					rst = { "vale" },
					ruby = { "ruby" },
					terraform = { "tflint" },
					text = { "vale" },
				}

				local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
				vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
					group = lint_augroup,
					callback = function()
						if vim.opt_local.modifiable:get() then
							lint.try_lint()
						end
					end,
				})
			end,
		},

		-- LSP
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{
						path = "luvit-meta/library",
						words = { "vim%.uv" },
					},
				},
			},
		},
		{
			"folke/trouble.nvim",
			opts = {},
			cmd = "Trouble",
			keys = {
				{
					"<leader>xx",
					"<cmd>Trouble diagnostics toggle<cr>",
					desc = "Diagnostics (Trouble)",
				},
				{
					"<leader>xX",
					"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{
					"<leader>cs",
					"<cmd>Trouble symbols toggle focus=false<cr>",
					desc = "Symbols (Trouble)",
				},
				{
					"<leader>cl",
					"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
					desc = "LSP Definitions / references / ... (Trouble)",
				},
				{
					"<leader>xL",
					"<cmd>Trouble loclist toggle<cr>",
					desc = "Location List (Trouble)",
				},
				{
					"<leader>xQ",
					"<cmd>Trouble qflist toggle<cr>",
					desc = "Quickfix List (Trouble)",
				},
			},
		},
		{ "Bilal2453/luvit-meta", lazy = true },
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				{
					"williamboman/mason.nvim",
					config = true,
				},
				"williamboman/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				{
					"j-hui/fidget.nvim",
					opts = {
						progress = {
							suppress_on_insert = true,
							ignore_done_already = true,
							ignore_empty_message = true,
						},
						notification = {
							window = {
								winblend = 0,
							},
						},
					},
				},

				"hrsh7th/cmp-nvim-lsp",
			},
			config = function()
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("mothzarella-lsp-attach", { clear = true }),
					callback = function(event)
						local map = function(keys, func, desc, mode)
							mode = mode or "n"
							vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
						end

						-- remap
						map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

						map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

						map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

						map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

						map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

						map(
							"<leader>ws",
							require("telescope.builtin").lsp_dynamic_workspace_symbols,
							"[W]orkspace [S]ymbols"
						)

						map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

						map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

						-- WARN: This is not Goto Definition, this is Goto Declaration.
						--  For example, in C this would take you to the header.
						map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

						local client = vim.lsp.get_client_by_id(event.data.client_id)
						if
							client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
						then
							local highlight_augroup =
								vim.api.nvim_create_augroup("mothzarella-lsp-highlight", { clear = false })
							vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.document_highlight,
							})

							vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.clear_references,
							})

							vim.api.nvim_create_autocmd("LspDetach", {
								group = vim.api.nvim_create_augroup("mothzarella-lsp-detach", { clear = true }),
								callback = function(event2)
									vim.lsp.buf.clear_references()
									vim.api.nvim_clear_autocmds({
										group = "mothzarella-lsp-highlight",
										buffer = event2.buf,
									})
								end,
							})
						end

						if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
							-- show inline hints on current buffer
							vim.lsp.inlay_hint.enable(true, { bufnr = 0 })

							-- remap
							map("<leader>th", function()
								vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
							end, "[T]oggle Inlay [H]ints")
						end
					end,
				})

				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities =
					vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

				local servers = {
					-- lua ( require man-db on aur repo )
					lua_ls = {
						settings = {
							Lua = {
								completion = {
									callSnippet = "Replace",
								},
								hint = {
									enable = true,
									arrayIndex = "Disable",
								},
							},
						},
					},

					-- go
					gopls = {
						settings = {
							gopls = {
								analyses = {
									unusedparams = true,
								},
								completeUnimported = true,
								usePlaceholders = true,
								staticcheck = true,
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
							},
						},
					},

					-- python
					basedpyright = {
						settings = {
							python = {
								analysis = {
									typeCheckingMode = "basic",
									autoSearchPaths = true,
									useLibraryCodeForTypes = true,
									diagnosticMode = "openFilesOnly",
									inlayHints = {
										variableTypes = true,
										callArgumentNames = true,
										functionReturnTypes = true,
										genericTypes = true,
									},
								},
							},
						},
					},

					-- rust
					rust_analyzer = {
						settings = {
							["rust-analyzer"] = {
								diagnostics = {
									enable = true,
									experimental = {
										enable = true,
									},
								},
								cargo = {
									buildScripts = {
										enable = true,
									},
								},
								imports = {
									granularity = {
										group = "module",
									},
									prefix = "self",
								},
								inlayHints = {
									chainingHints = true,
									typeHints = true,
									parameterHints = true,
								},
								procMacro = {
									enable = true,
								},
							},
						},
					},

					-- typescript / javascript
					ts_ls = {
						filetypes = {
							"javascript",
							"javascriptreact",
							"javascript.jsx",
							"typescript",
							"typescriptreact",
							"typescript.tsx",
						},
						single_file_support = true,
						init_options = {
							preferences = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = true,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
								importModuleSpecifierPreference = "non-relative",
							},
						},
					},

					-- tailwindcss
					tailwindcss = {
						settings = {
							tailwindCSS = {
								lint = {
									enabled = true,
								},
							},
						},
					},

					-- css / scss / less
					cssls = {
						filetypes = { "css", "scss", "less" },
						settings = {
							css = { validate = true },
							less = { validate = true },
							scss = { validate = true },
						},
					},

					-- c/c++
					clangd = {
						cmd = {
							"clangd",
							"--fallback-style=webkit",
						},
						filetypes = { "c", "cpp" },
					},
				}

				require("mason").setup()

				local ensure_installed = vim.tbl_keys(servers or {})
				vim.list_extend(ensure_installed, {
					-- formatters
					"stylua", -- require unzip
					"goimports",
					"black",
					"prettier",

					-- DAP
					"delve",
					"codelldb",
				})
				require("mason-tool-installer").setup({
					ensure_installed = ensure_installed,
					auto_update = true,
				})

				require("mason-lspconfig").setup({
					ensure_installed = {},
					automatic_installation = false,
					handlers = {
						function(server_name)
							local server = servers[server_name] or {}
							server.capabilities =
								vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
							require("lspconfig")[server_name].setup(server)
						end,
					},
				})
			end,
		},

		-- lualine
		{
			"nvim-lualine/lualine.nvim",
			config = function()
				local colors = dofile(vim.g.base46_cache .. "colors")
				require("lualine").setup({
					options = {
						icons_enabled = true,
						component_separators = "",
						section_separators = { left = "", right = "" },
					},
					sections = {
						lualine_a = {
							{
								"mode",
								icon = "",
								color = {
									bg = colors.purple,
									gui = "bold",
								},
							},
						},
						lualine_b = {
							{
								"branch",
								icon = "",
								color = {
									fg = colors.purple,
									bg = colors.black,
								},
							},
						},
						lualine_c = {},
						lualine_x = {
							{
								"diagnostics",
								sources = { "nvim_diagnostic" },
								symbols = { error = " ", warn = " ", info = " " },
							},
						},
						lualine_y = {
							{
								"progress",
								color = {
									fg = colors.purple,
									bg = colors.black,
								},
							},
						},
						lualine_z = {
							{
								"location",
								color = {
									bg = colors.purple,
									gui = "bold",
								},
							},
						},
					},
				})
			end,
		},

		-- markdown
		{
			"MeanderingProgrammer/markdown.nvim",
			main = "render-markdown",
			config = true,
		},

		-- nvchad
		"nvim-lua/plenary.nvim",
		{ "nvim-tree/nvim-web-devicons", lazy = true },

		{
			"nvchad/ui",
			config = function()
				require("nvchad")
			end,
		},

		{
			"nvchad/base46",
			lazy = true,
			build = function()
				require("base46").load_all_highlights()
			end,
		},

		"nvchad/volt",

		-- telescope
		{
			"nvim-telescope/telescope.nvim",
			event = "VimEnter",
			branch = "0.1.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{
					"nvim-telescope/telescope-fzf-native.nvim",
					build = "make",
				},
				{
					"rmagatti/auto-session",
					dependencies = { "nvim-telescope/telescope.nvim" },
					config = function()
						require("auto-session").setup({
							enabled = true,
							auto_save = true,
							suppressed_dirs = { "~/", "/" },
							session_lens = {
								mappings = {
									delete_session = { { "i", "n" }, "<C-d>" },
								},
							},
						})
					end,
				},
			},
			config = function()
				local telescope = require("telescope")
				local builtin = require("telescope.builtin")
				local actions = require("telescope.actions")
				pcall(telescope.load_extension, "fzf")

				telescope.setup({
					defaults = {
						winblend = 0,
						mappings = {
							n = {
								["q"] = actions.close,
								["l"] = actions.select_default,
							},
						},
					},
					pickers = {
						buffers = {
							sort_lastused = true,
							mappings = {
								i = {
									["<C-d>"] = actions.delete_buffer,
								},
								n = {
									["<C-d>"] = actions.delete_buffer,
								},
							},
						},
					},
				})

				-- session
				telescope.load_extension("session-lens")

				-- remap
				vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find [F]iles" })
				vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live [G]rep" })
				vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
				vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

				-- session
				vim.keymap.set("n", "<leader>fs", "<cmd>SessionSearch<CR>", { desc = "Search [S]ession" })

				-- nvim files
				vim.keymap.set("n", "<leader>fn", function()
					builtin.find_files({ cwd = vim.fn.stdpath("config") })
				end, { desc = "[S]earch [N]eovim files" })

				-- fzf
				vim.keymap.set("n", "<leader>/", function()
					builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						previewer = false,
					}))
				end, { desc = "[/] Fuzzily search in current buffer" })
			end,
		},

		-- transparent
		{
			"xiyaowong/nvim-transparent",
			lazy = false,
			opts = {
				enable = true,
				extra_groups = {
					"barbecue_normal",
					"barbecue_ellipsis",
					"barbecue_separator",
					"barbecue_modified",
					"barbecue_dirname",
					"barbecue_basename",
					"barbecue_context",
					"barbecue_context_file",
					"barbecue_context_module",
					"barbecue_context_namespace",
					"barbecue_context_package",
					"barbecue_context_class",
					"barbecue_context_method",
					"barbecue_context_property",
					"barbecue_context_field",
					"barbecue_context_constructor",
					"barbecue_context_enum",
					"barbecue_context_interface",
					"barbecue_context_function",
					"barbecue_context_variable",
					"barbecue_context_constant",
					"barbecue_context_string",
					"barbecue_context_number",
					"barbecue_context_boolean",
					"barbecue_context_array",
					"barbecue_context_object",
					"barbecue_context_key",
					"barbecue_context_null",
					"barbecue_context_enum_member",
					"barbecue_context_struct",
					"barbecue_context_event",
					"barbecue_context_operator",
					"barbecue_context_type_parameter",
					"TroubleNormal",
					"TroubleNormalNC",
				},
			},
			config = function(_, opts)
				local transparent = require("transparent")
				transparent.setup(opts)

				local lines = { "lualine_c", "lualine_x" }
				for _, line in ipairs(lines) do
					transparent.clear_prefix(line)
				end
			end,
		},

		-- treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			main = "nvim-treesitter.configs",
			opts = {
				ensure_installed = {
					"bash",
					"c",
					"diff",
					"go",
					"html",
					"json",
					"javascript",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"rust",
					"toml",
					"typescript",
					"yaml",
					"vim",
					"vimdoc",
				},
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "ruby" },
				},
				indent = { enable = true, disable = { "ruby" } },
			},
			config = function(_, opts)
				dofile(vim.g.base46_cache .. "treesitter")
				require("nvim-treesitter.configs").setup(opts)
			end,
		},

		-- undotree
		{
			"mbbill/undotree",
			keys = {
				{
					"<leader>u",
					"<cmd>UndotreeToggle<CR>",
					desc = "Toggle [U]ndo Tree",
				},
			},
		},

		-- zen
		{
			"folke/zen-mode.nvim",
			cmd = "ZenMode",
			dependencies = {
				{
					"folke/twilight.nvim",
					keys = {
						{
							"<leader>zt",
							"<cmd>Twilight<cr>",
							desc = "Twilight",
						},
					},
				},
			},
			keys = {
				{
					"<leader>zz",
					"<cmd>ZenMode<cr>",
					desc = "Zen Mode",
				},
			},
			config = function()
				require("zen-mode").setup({
					window = {
						backdrop = 1,
						width = 120,
						height = 1,
					},
				})
			end,
		},
	},
	install = { colorscheme = { "nvchad" } },
	checker = { enabled = true },
})

for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
	dofile(vim.g.base46_cache .. v)
end
