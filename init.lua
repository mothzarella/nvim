--- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--- Make sure to setup `mapleader` and `maplocalleader` before
--- loading lazy.nvim so that mappings are correct.
--- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

--- Setup floating borders
vim.g.borders = {
  { ' ', 'FloatBorder' },
  { ' ', 'FloatBorder' },
  { ' ', 'FloatBorder' },
  { ' ', 'FloatBorder' },
  { ' ', 'FloatBorder' },
  { ' ', 'FloatBorder' },
  { ' ', 'FloatBorder' },
  { ' ', 'FloatBorder' },
}

--- Options
local o = vim.o

--- Enable termgui color
o.termguicolors = true

o.laststatus = 3

--- Make line numbers default
o.number = true
o.relativenumber = true

--- Show which line your cursor is on
o.cursorline = true

--- Enable break indent
o.breakindent = true

--- Don't show the mode, since it's already in the status line
o.showmode = false

--- Save undo history
o.undofile = true

--- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
o.ignorecase = true
o.smartcase = true

--- Number of spaces to use for each step of (auto)indent
local tabs = 2
o.shiftwidth = tabs
o.tabstop = tabs
o.expandtab = true
o.smartindent = true

--- Keep signcolumn on by default
o.signcolumn = 'yes'

--- Minimal number of screen lines to keep above and below the cursor.
o.scrolloff = 10

--- Remap
local map = vim.keymap

map.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

map.set('n', '[b', '<cmd>bprev<CR>')
map.set('n', ']b', '<cmd>bnext<CR>')

--- Yank to system clipboard
map.set({ 'n', 'v' }, '<leader>y', [["+y]])

--- Diagnostic keymaps
map.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

--- Highlight when yanking (copying) text
---  Try it with `yap` in normal mode
---  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

--- Setup lazy.nvim
require('lazy').setup {
  spec = {
    {
      'rmagatti/auto-session',
      lazy = false,

      ---enables autocomplete for opts
      ---@module "auto-session"
      ---@type AutoSession.Config
      opts = {
        suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
        -- log_level = 'debug',
      },
    },
    ---  Markdown
    {
      'OXY2DEV/markview.nvim',
      lazy = false,
      --- Remap
      keys = {
        { '<leader>tm', '<cmd>Markview toggle<cr>', desc = '[T]oggle [M]arkdown' },
      },
    },
    {
      'mbbill/undotree',
      config = function()
        vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndoo tree' })
      end,
    },
    {
      'christoomey/vim-tmux-navigator',
      cmd = {
        'TmuxNavigateLeft',
        'TmuxNavigateDown',
        'TmuxNavigateUp',
        'TmuxNavigateRight',
        'TmuxNavigatePrevious',
        'TmuxNavigatorProcessList',
      },
      keys = {
        { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
        { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
        { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
        { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
        { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
      },
    },
    {
      'rebelot/heirline.nvim',
      config = function()
        local conditions = require 'heirline.conditions'
        local utils = require 'heirline.utils'

        local colors = {
          bright_bg = utils.get_highlight('Folded').bg,
          bright_fg = utils.get_highlight('Folded').fg,
          red = utils.get_highlight('DiagnosticError').fg,
          dark_red = utils.get_highlight('DiffDelete').bg,
          green = utils.get_highlight('String').fg,
          blue = utils.get_highlight('Function').fg,
          gray = utils.get_highlight('NonText').fg,
          orange = utils.get_highlight('Constant').fg,
          purple = utils.get_highlight('Statement').fg,
          cyan = utils.get_highlight('Special').fg,
          diag_warn = utils.get_highlight('DiagnosticWarn').fg,
          diag_error = utils.get_highlight('DiagnosticError').fg,
          diag_hint = utils.get_highlight('DiagnosticHint').fg,
          diag_info = utils.get_highlight('DiagnosticInfo').fg,
          git_del = utils.get_highlight('diffDeleted').fg,
          git_add = utils.get_highlight('diffAdded').fg,
          git_change = utils.get_highlight('diffChanged').fg,
        }

        local status = require 'tar.status'

        require('heirline').setup {
          --- Components
          ---@diagnostic disable-next-line: missing-fields
          winbar = { status.Navic() },

          ---@diagnostic disable-next-line: missing-fields
          statusline = {
            status.FileType(utils),
            status.Git(conditions),
            { provider = '%=' },
            status.ScrollBar(),
          },

          --- Options
          opts = {
            colors = colors,
            disable_winbar_cb = function(args)
              return conditions.buffer_matches({
                buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
                filetype = { '^git.*', 'fugitive', 'Trouble', 'dashboard', 'oil', 'fzf' },
              }, args.buf)
            end,
          },
        }
      end,
    },

    --- colorsheme
    {
      'luisiacc/gruvbox-baby',
      priority = 1000,
      lazy = false,
      config = function()
        vim.o.background = 'dark'
        vim.cmd [[colorscheme gruvbox-baby]]

        --- Override hl
        vim.api.nvim_create_autocmd('BufEnter', {
          group = vim.api.nvim_create_augroup('colorscheme', { clear = true }),
          callback = function()
            local hl = function(name, api)
              vim.api.nvim_set_hl(0, name, api)
            end

            --- Fzf
            hl('FzfLuaBorder', { link = 'NormalFloat' })
            hl('FzfLuaNormal', { link = 'NormalFloat' })

            --- Float
            hl('Pmenu', { link = 'NormalFloat' })
            hl('PmenuSbar', { link = 'NormalFloat' }) --- Better look Pmenu & CMP scroll

            --- Winbar
            hl('Winbar', { bg = 'NONE' })
            hl('WinbarNC', { link = 'WinBar' })
          end,
        })
      end,
    },

    --- Explorer
    {
      'stevearc/oil.nvim',
      lazy = false,
      config = function()
        local oil = require 'oil'

        oil.setup {
          skip_confirm_for_simple_edits = true,
          keymaps = {
            ['q'] = {
              desc = 'Oil: [Q]uit explorer',
              callback = function()
                oil.close()
              end,
            },
            --- Toggle file detail view
            ---@see https://github.com/stevearc/oil.nvim/blob/master/doc/recipes.md#toggle-file-detail-view
            ['gd'] = {
              desc = 'Oil: Toggle file detail view',
              callback = function()
                Detail = not Detail
                if Detail then
                  oil.set_columns { 'icon', 'permissions', 'size', 'mtime' }
                else
                  oil.set_columns { 'icon' }
                end
              end,
            },
          },
          view_options = { show_hidden = true },
          float = {
            max_width = 0.75,
            max_height = 0.75,
            border = vim.g.borders,
          },
        }

        vim.keymap.set('n', '<leader>e', oil.toggle_float, { desc = 'Oil: [E]xplore' })
      end,
    },

    --- Git integration
    { 'lewis6991/gitsigns.nvim', opts = {} },

    {
      'echasnovski/mini.nvim',
      version = '*', --- Stable version
      config = function()
        --- Icons
        ---@see https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-icons.md
        require('mini.icons').setup()
      end,
    },

    --- Highlight colors
    {
      'brenoprata10/nvim-highlight-colors',
      opts = {
        ---Render style
        ---@usage 'background'|'foreground'|'virtual'
        render = 'virtual',

        ---Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '󱓻',

        ---Set virtual symbol suffix (defaults to '')
        virtual_symbol_prefix = '',

        ---Set virtual symbol suffix (defaults to ' ')
        virtual_symbol_suffix = ' ',

        ---Set virtual symbol position()
        ---@usage 'inline'|'eol'|'eow'
        ---inline mimics VS Code style
        ---eol stands for `end of column` - Recommended to set `virtual_symbol_suffix = ''` when used.
        ---eow stands for `end of word` - Recommended to set `virtual_symbol_prefix = ' ' and virtual_symbol_suffix = ''` when used.
        virtual_symbol_position = 'inline',

        ---Highlight hex colors, e.g. '#FFFFFF'
        enable_hex = true,

        ---Highlight short hex colors e.g. '#fff'
        enable_short_hex = true,

        ---Highlight rgb colors, e.g. 'rgb(0 0 0)'
        enable_rgb = true,

        ---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
        enable_hsl = true,

        ---Highlight ansi colors, e.g '\033[0;34m'
        enable_ansi = true,

        --- Highlight hsl colors without function, e.g. '--foreground: 0 69% 69%;'
        enable_hsl_without_function = true,

        ---Highlight CSS variables, e.g. 'var(--testing-color)'
        enable_var_usage = true,

        ---Highlight named colors, e.g. 'green'
        enable_named_colors = true,

        ---Highlight tailwind colors, e.g. 'bg-blue-500'
        enable_tailwind = true,
      },
    },

    --- Comments
    { 'numToStr/Comment.nvim', opts = {} },
    {
      'folke/todo-comments.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = {},
    },

    --- Fuzzy Finder
    {
      'ibhagwan/fzf-lua',
      event = 'VeryLazy',

      --- Conform Fzf with the editor apparence
      opts = {
        winopts = {
          border = vim.g.borders,
          backdrop = 100,
          preview = {
            border = vim.g.borders,
          },
        },
        fzf_colors = {
          ['bg'] = '-1',
          ['gutter'] = '-1',
        },
      },
      config = function(_, opts)
        local fzf = require 'fzf-lua'
        fzf.setup(opts)

        vim.api.nvim_create_autocmd('BufEnter', {
          group = vim.api.nvim_create_augroup('fzf.enter', { clear = true }),
          callback = function(event)
            --- Remap
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'Fzf: ' .. desc })
            end

            --- Buffer
            map('<leader><leader>', fzf.buffers, '[F]ind [F]ile', { 'n', 'x' })

            --- Comments
            map('<leader>fc', function()
              require('todo-comments.fzf').todo()
            end, '[F]ind [C]comment', { 'n', 'x' })

            --- File
            map('<leader>ff', fzf.files, '[F]ind [F]ile', { 'n', 'x' })

            --- Session
            map('<leader>fs', function()
              fzf.fzf_exec 'SessionSearch'
            end, 'Fuzzy complete file', { 'n' })
          end,
        })
      end,
    },

    --- LSP
    {
      --- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
      --- used for completion, annotations and signatures of Neovim apis
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          --- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        --- Automatically install LSPs and related tools to stdpath for Neovim
        { 'williamboman/mason.nvim', opts = {} },
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        --- Useful status updates for LSP.
        { 'j-hui/fidget.nvim', opts = {} },

        --- Allows extra capabilities provided by blink.cmp
        'saghen/blink.cmp',

        --- Simple winbar/statusline plugin that shows your current code context
        'SmiteshP/nvim-navic',
      },
      config = function()
        local fzf = require 'fzf-lua'
        local navic = require 'nvim-navic'

        --- This function gets run when an LSP attaches to a particular buffer.
        ---   That is to say, every time a new file is opened that is associated with
        ---   an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
        ---   function will be executed to configure the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('lsp.attach', { clear = true }),
          callback = function(event)
            --- NOTE: Remember that Lua is a real programming language, and as such it is possible
            --- to define small helper and utility functions so you don't have to repeat yourself.
            ---
            --- In this case, we create a function that lets us more easily define mappings specific
            --- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            --- Open LSP
            vim.keymap.set('n', 'K', function()
              vim.lsp.buf.hover {
                border = vim.g.borders,
              }
            end, { buffer = event.buf })

            --- Diagnostic and Fzf

            --- Rename the variable under your cursor.
            ---  Most Language Servers support renaming across files, etc.
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

            --- Execute a code action, usually your cursor needs to be on top of an error
            --- or a suggestion from your LSP for this to activate.
            map('<leader>ca', fzf.lsp_code_actions, '[C]ode [A]ction', { 'n', 'x' })

            --- Find references for the word under your cursor.
            map('<leader>gr', fzf.lsp_references, '[G]oto [R]eferences')

            --- Jump to the implementation of the word under your cursor.
            ---  Useful when your language has ways of declaring types without an actual implementation.
            map('<leader>gi', fzf.lsp_implementations, '[G]oto [I]mplementation')

            --- Jump to the definition of the word under your cursor.
            ---  This is where a variable was first declared, or where a function is defined, etc.
            ---  To jump back, press <C-t>.
            map('gd', fzf.lsp_definitions, '[G]oto [D]efinition')

            --- WARN: This is not Goto Definition, this is Goto Declaration.
            ---  For example, in C this would take you to the header.
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            --- Jump to the type of the word under your cursor.
            ---  Useful when you're not sure what type a variable is and you want to see
            ---  the definition of its *type*, not where it was *defined*.
            map('<leader>gt', fzf.lsp_typedefs, '[G]oto [T]ype Definition')

            --- Trouble

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client then
              --- For nvim-navic to work, it needs attach to the lsp server.
              --- Can attach to only one server per buffer.
              if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, event.buf)
              end

              --- The following two autocommands are used to highlight references of the
              --- word under your cursor when your cursor rests there for a little while.
              ---    See `:help CursorHold` for information about when this is executed
              if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                local highlight_augroup = vim.api.nvim_create_augroup('lsp.highlight', { clear = false })
                vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                  buffer = event.buf,
                  group = highlight_augroup,
                  callback = vim.lsp.buf.document_highlight,
                })

                --- When you move your cursor, the highlights will be cleared (the second autocommand).
                vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                  buffer = event.buf,
                  group = highlight_augroup,
                  callback = vim.lsp.buf.clear_references,
                })

                vim.api.nvim_create_autocmd('LspDetach', {
                  group = vim.api.nvim_create_augroup('lsp.detach', { clear = true }),
                  callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = 'lsp.highlight', buffer = event2.buf }
                  end,
                })
              end

              --- The following code creates a keymap to toggle inlay hints in your
              --- code, if the language server you are using supnorts them
              ---
              --- This may be unwanted, since they displace some of your code
              if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                --- Set inlay hints 'true' as default
                vim.lsp.inlay_hint.enable(true)

                map('<leader>th', function()
                  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                end, '[T]oggle Inlay [H]ints')
              end
            end
          end,
        })

        --- Diagnostic Config
        --- See :help vim.diagnostic.Opts
        vim.diagnostic.config {
          severity_sort = true,
          float = { border = 'rounded', source = 'if_many' },
          underline = { severity = vim.diagnostic.severity.ERROR },
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = '󰅚 ',
              [vim.diagnostic.severity.WARN] = '󰀪 ',
              [vim.diagnostic.severity.INFO] = '󰋽 ',
              [vim.diagnostic.severity.HINT] = '󰌶 ',
            },
          },
          virtual_text = {
            source = 'if_many',
            spacing = 2,
            format = function(diagnostic)
              local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
              }
              return diagnostic_message[diagnostic.severity]
            end,
          },
        }

        --- LSP servers and clients are able to communicate to each other what features they support.
        ---  By default, Neovim doesn't support everything that is in the LSP specification.
        ---  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
        ---  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
        local capabilities = require('blink.cmp').get_lsp_capabilities()

        --- Enable the following language servers
        ---
        ---  Add any additional override configuration in the following tables. Available keys are:
        ---  - cmd (table): Override the default command used to start the server
        ---  - filetypes (table): Override the default list of associated filetypes for the server
        ---  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        ---  - settings (table): Override the default settings passed when initializing the server.
        ---        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
          -- clangd = {},
          --- Go
          -- gopls = {},
          -- pyright = {},
          -- rust_analyzer = {},
          -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
          --
          -- Some languages (like typescript) have entire language plugins that can be useful:
          --    https://github.com/pmizio/typescript-tools.nvim
          --
          -- But for many setups, the LSP (`ts_ls`) will work just fine
          -- ts_ls = {},

          --- Nix
          nil_ls = {},

          --- Lua
          lua_ls = {
            --- cmd = { ... },
            --- filetypes = { ... },
            --- capabilities = {},
            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace',
                },
                diagnostics = { disable = { 'missing-fields' } },
              },
            },
          },
        }

        --- Ensure the servers and tools above are installed
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
          'stylua',
        })
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
          ensure_installed = {}, --- explicitly set to an empty table (populates installs via mason-tool-installer)
          automatic_installation = false,
          handlers = {
            function(server_name)
              local server = servers[server_name] or {}
              --- This handles overriding only values explicitly passed
              --- by the server configuration above. Useful when disabling
              --- certain features of an LSP (for example, turning off formatting for ts_ls)
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

              require('lspconfig')[server_name].setup(server)
            end,
          },
        }
      end,
    },

    --- Autoformat
    {
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      cmd = { 'ConformInfo' },
      keys = {
        {
          '<leader>cf',
          function()
            require('conform').format { async = true, lsp_format = 'fallback' }
          end,
          mode = '',
          desc = '[F]ormat buffer',
        },
      },
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          --- Disable "format_on_save lsp_fallback" for languages that don't
          --- have a well standardized coding style. You can add additional
          --- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
          else
            return {
              timeout_ms = 500,
              lsp_format = 'fallback',
            }
          end
        end,
        formatters_by_ft = {
          lua = { 'stylua' },

          --- Conform can also run multiple formatters sequentially
          python = { 'isort', 'black' },
          nix = { 'nixfmt' },
          javascript = {
            'prettierd',
            'prettier',
            --- You can use 'stop_after_first' to run the first available formatter from the list
            stop_after_first = true,
          },
        },
      },
    },

    --- Autocompletion
    {
      'saghen/blink.cmp',
      event = 'VimEnter',
      version = '1.*',
      dependencies = {
        --- Snippet Engine
        {
          'L3MON4D3/LuaSnip',
          version = '2.*',
          build = (function()
            --- Build Step is needed for regex support in snippets.
            --- This step is not supported in many windows environments.
            --- Remove the below condition to re-enable on windows.
            if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
              return
            end
            return 'make install_jsregexp'
          end)(),
          dependencies = {
            --- `friendly-snippets` contains a variety of premade snippets.
            ---@see https://github.com/rafamadriz/friendly-snippets
            {
              'rafamadriz/friendly-snippets',
              config = function()
                require('luasnip.loaders.from_vscode').lazy_load()
              end,
            },
          },
          opts = {},
        },
        {
          'zbirenbaum/copilot.lua',
          cmd = 'Copilot',
          event = 'InsertEnter',
          config = function()
            require('copilot').setup {}
          end,
        },
        'folke/lazydev.nvim',
      },
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        keymap = {
          -- 'default' (recommended) for mappings similar to built-in completions
          --   <c-y> to accept ([y]es) the completion.
          --    This will auto-import if your LSP supports it.
          --    This will expand snippets if the LSP sent a snippet.
          -- 'super-tab' for tab to accept
          -- 'enter' for enter to accept
          -- 'none' for no mappings
          --
          -- For an understanding of why the 'default' preset is recommended,
          -- you will need to read `:help ins-completion`
          --
          -- No, but seriously. Please read `:help ins-completion`, it is really good!
          --
          -- All presets have the following mappings:
          -- <tab>/<s-tab>: move to right/left of your snippet expansion
          -- <c-space>: Open menu or open docs if already open
          -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
          -- <c-e>: Hide menu
          -- <c-k>: Toggle signature help
          --
          -- See :h blink-cmp-config-keymap for defining your own keymap
          preset = 'default',

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },

        appearance = {
          -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono',
        },

        completion = {
          menu = {
            border = vim.g.borders,
            draw = {
              components = {
                kind_icon = {
                  text = function(ctx)
                    --- Default kind icon
                    local icon = ctx.kind_icon
                    --- if LSP source, check for color derived from documentation
                    if ctx.item.source_name == 'LSP' then
                      local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                      if color_item and color_item.abbr ~= '' then
                        icon = color_item.abbr
                      end
                    end
                    return icon .. ctx.icon_gap
                  end,

                  --- Use mini.icons highlight colors
                  highlight = function(ctx)
                    local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                    return hl
                  end,
                },
                kind = {
                  highlight = function(ctx)
                    local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                    return hl
                  end,
                },
              },
            },
          },

          --- Display a preview of the selected item on the current line
          ghost_text = { enabled = true },

          -- By default, you may press `<c-space>` to show the documentation.
          -- Optionally, set `auto_show = true` to show the documentation after a delay.
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
            window = { border = vim.g.borders },
          },
        },

        sources = {
          default = { 'lsp', 'path', 'snippets', 'lazydev' },
          providers = {
            lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
          },
        },

        snippets = { preset = 'luasnip' },

        -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
        -- which automatically downloads a prebuilt binary when enabled.
        --
        -- By default, we use the Lua implementation instead, but you may enable
        -- the rust implementation via `'prefer_rust_with_warning'`
        --
        -- See :h blink-cmp-config-fuzzy for more information
        fuzzy = { implementation = 'lua' },

        -- Shows a signature help window while you type arguments for a function
        signature = {
          enabled = true,
          window = { border = vim.g.borders },
        },
      },
    },

    --- Highlight, edit, and navigate code
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      main = 'nvim-treesitter.configs', -- Sets main module to use for opts
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
      opts = {
        ensure_installed = {
          'bash',
          'c',
          'diff',
          'html',
          'lua',
          'luadoc',
          'nix',
          'markdown',
          'markdown_inline',
          'query',
          'vim',
          'vimdoc',
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  if you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      },
      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    },
  },

  --- automatically check for plugin updates
  checker = { enabled = true },
}
