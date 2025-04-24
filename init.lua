-- Bootstrap lazy.nvim
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

vim.o.laststatus = 3

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

vim.api.nvim_set_hl(0, 'WinBarNC', { bold = true })

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

--- Set to true if ure using declarative distros like NixOS
vim.g.local_lsp = false

--- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true

--- Show which line your cursor is on
vim.o.cursorline = true

--- Enable break indent
vim.o.breakindent = true

--- Don't show the mode, since it's already in the status line
vim.o.showmode = false

--- Save undo history
vim.o.undofile = true

--- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

--- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

--- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '[b', '<cmd>bprev<CR>')
vim.keymap.set('n', ']b', '<cmd>bnext<CR>')

--- yank to system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])

-- Setup lazy.nvim
require('lazy').setup {
  spec = {
    'tpope/vim-sleuth',
    {
      'sainnhe/gruvbox-material',
      priority = 1000,
      config = function()
        vim.o.background = 'dark'
        vim.g.gruvbox_material_foreground = 'mix'
        vim.cmd [[colorscheme gruvbox-material]]
      end,
    },
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
            max_width = 0.5,
            max_height = 0.5,
            border = vim.g.borders,
          },
        }

        vim.keymap.set('n', '<leader>e', function()
          oil.toggle_float()
        end, { desc = 'Oil: [E]xplore' })
      end,
    },
    {
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      },
    },
    {
      'echasnovski/mini.nvim',
      version = '*', --- Stable version
      config = function()
        --- Icons
        ---@see https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-icons.md
        require('mini.icons').setup()

        --- Statusline
        ---@see https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-statusline.md
        local statusline = require 'mini.statusline'
        statusline.setup { use_icons = true }

        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
          ---@see https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#cursor-position-ruler-and-scrollbar
          local sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }

          local curr_line = vim.api.nvim_win_get_cursor(0)[1]
          local lines = vim.api.nvim_buf_line_count(0)
          local i = math.floor((curr_line - 1) / lines * #sbar) + 1
          return '%2P ' .. string.rep(sbar[i], 2)
        end
      end,
    },

    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'echasnovski/mini.nvim' },
      ---@module 'render-markdown'
      opts = {
        file_types = { 'markdown', 'vimwiki' },
        completions = {
          lsp = { enabled = true },
          blink = { enabled = true },
        },
      },
      config = function(_, opts)
        require('render-markdown').setup(opts)
      end,
    },
    { 'numToStr/Comment.nvim', opts = {} },

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

        vim.api.nvim_set_hl(0, 'FzfLuaBorder', { link = 'NormalFloat' })
        vim.api.nvim_set_hl(0, 'FzfLuaNormal', { link = 'NormalFloat' })

        vim.api.nvim_create_autocmd('BufEnter', {
          group = vim.api.nvim_create_augroup('fzf.enter', { clear = true }),
          callback = function(event)
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'Fzf: ' .. desc })
            end

            map('<leader>ff', fzf.files, '[F]ind [F]ile', { 'n', 'x' })
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

        navic.setup {
          highlight = true,
          depth_limit = 8,
        }

        ---  This function gets run when an LSP attaches to a particular buffer.
        ---    That is to say, every time a new file is opened that is associated with
        ---    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
        ---    function will be executed to configure the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('lsp.attach', { clear = true }),
          callback = function(event)
            -- NOTE: Remember that Lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            -- Rename the variable under your cursor.
            --  Most Language Servers support renaming across files, etc.
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('<leader>ca', fzf.lsp_code_actions, '[C]ode [A]ction', { 'n', 'x' })

            -- Find references for the word under your cursor.
            -- map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            --
            -- -- Jump to the implementation of the word under your cursor.
            -- --  Useful when your language has ways of declaring types without an actual implementation.
            -- map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
            --
            -- -- Jump to the definition of the word under your cursor.
            -- --  This is where a variable was first declared, or where a function is defined, etc.
            -- --  To jump back, press <C-t>.
            -- map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
            --
            -- -- WARN: This is not Goto Definition, this is Goto Declaration.
            -- --  For example, in C this would take you to the header.
            -- map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
            --
            -- -- Fuzzy find all the symbols in your current document.
            -- --  Symbols are things like variables, functions, types, etc.
            -- map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
            --
            -- -- Fuzzy find all the symbols in your current workspace.
            -- --  Similar to document symbols, except searches over your entire project.
            -- map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
            --
            -- -- Jump to the type of the word under your cursor.
            -- --  Useful when you're not sure what type a variable is and you want to see
            -- --  the definition of its *type*, not where it was *defined*.
            -- map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
            --
            vim.keymap.set('n', 'K', function()
              vim.lsp.buf.hover {
                border = vim.g.borders,
              }
            end, { buffer = event.buf })

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            -- if client.server_capabilities.documentSymbolProvider then
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

              -- The following code creates a keymap to toggle inlay hints in your
              -- code, if the language server you are using supnorts them
              --
              -- This may be unwanted, since they displace some of your code
              if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
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

              ---@diagnostic disable: deprecated
              server.handlers = {
                ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
                ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
              }

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
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
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
          menu = { border = vim.g.borders },
          -- By default, you may press `<c-space>` to show the documentation.
          -- Optionally, set `auto_show = true` to show the documentation after a delay.
          documentation = {
            auto_show = false,
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
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
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
