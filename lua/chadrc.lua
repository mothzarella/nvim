return {
	base46 = {
		theme = "rosepine",
		hl_add = {},
		hl_override = {
			CursorLineNr = { fg = "purple" },
			WildMenu = { bg = "black2", fg = "white" },
			WildDone = { bg = "black2", fg = "white" },

			-- LSP
			NormalFloat = { bg = "black2" },
			FloatBorder = { bg = "black2", fg = "one_bg3" },

			-- CMP
			CmpPmenu = { bg = "black2" },
			CmpBorder = { bg = "black2", fg = "one_bg3" },
			CmpDoc = { bg = "black2" },
			CmpDocBorder = { bg = "black2", fg = "one_bg3" },

			-- Telescope
			TelescopeNormal = { bg = "darker_black" },
			TelescopeBorder = { bg = "darker_black", fg = "darker_black" },
			TelescopePromptNormal = { bg = "black2" },
			TelescopePromptBorder = { bg = "black2", fg = "black2" },
			TelescopeSelection = { bg = "black2" },
		},
		integrations = {
			"cmp",
			"telescope",
		},
		changed_themes = {},
		transparency = true,
	},

	ui = {
		cmp = {
			icons_left = true,
			lspkind_text = true,
			style = "default",
			abbr_maxwidth = 60,
			format_colors = {
				tailwind = true,
				icon = "󱓻",
			},
		},

		telescope = { style = "borderless" },

		statusline = { enabled = false },

		tabufline = { enabled = false },
	},

	nvdash = { load_on_startup = false },

	term = {
		winopts = { number = false, relativenumber = false },
		sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
		float = {
			relative = "editor",
			row = 0.3,
			col = 0.25,
			width = 0.5,
			height = 0.4,
			border = "single",
		},
	},

	lsp = { signature = true },

	cheatsheet = {
		theme = "grid",
		excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" },
	},

	mason = { pkgs = {}, skip = {} },

	colorify = {
		enabled = true,
		mode = "virtual",
		virt_text = "󱓻 ",
		highlight = { hex = true, lspvars = true },
	},
}
