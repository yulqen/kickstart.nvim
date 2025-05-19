--[[
--Assertions.
init
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================
--]]

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.g.loaded_matchparen = 0

-- [[ Setting options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.o.updatetime = 250
vim.opt.showmode = false
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 5

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-u>', '<C-o>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<tab>', ':tabnext<CR>', { desc = 'Move to next tab' })

-- neotest keybinds
vim.keymap.set('n', 'dn', ':lua require("neotest").run.run({strategy = "dap"})<CR>')
vim.keymap.set('n', 'tn', ':lua require("neotest").run.run()<CR>', { desc = 'Test nearest' })
vim.keymap.set('n', 'tf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { desc = 'Test file' })
vim.keymap.set('n', 'to', ':lua require("neotest").output.open({ enter = true })<CR>')
vim.keymap.set('n', 'ts', ':lua require("neotest").summary.open()<CR>')
vim.keymap.set('n', 'tt', ':lua require("neotest").summary.toggle()<CR>')
vim.keymap.set('n', 'tq', ':lua require("neotest").output_panel.close()<CR>')

-- Cody keybinds
vim.keymap.set('n', '<C-t>', ':CodyChat<CR>', { desc = 'Cody chat' })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  'tpope/vim-sleuth',

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
    'stevanmilic/nvim-lspimport',
    config = function()
      vim.keymap.set('n', '<leader>5', require('lspimport').import, { noremap = true })
    end,
  },

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'mfussenegger/nvim-dap-python',
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        keys = {
          {
            '<leader>du',
            function()
              require('dapui').toggle {}
            end,
            desc = 'Dap UI',
          },
          {
            '<leader>de',
            function()
              require('dapui').eval()
            end,
            desc = 'Eval',
            mode = { 'n', 'v' },
          },
        },
        opts = {},
        config = function(_, opts)
          local dap = require 'dap'
          local dapui = require 'dapui'
          dapui.setup(opts)
          dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open {}
          end
          dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close {}
          end
          dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close {}
          end
        end,
      },
    },
    keys = { -- General DAP keymaps
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Breakpoint Condition',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle Breakpoint',
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'Continue',
      },
      -- { '<leader>da', function() require('dap').continue { before = get_args } end, desc = 'Run with Args' }, -- get_args is not defined
      {
        '<leader>dC',
        function()
          require('dap').run_to_cursor()
        end,
        desc = 'Run to Cursor',
      },
      {
        '<leader>dg',
        function()
          require('dap').goto_()
        end,
        desc = 'Go to Line (No Execute)',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'Step Into',
      },
      {
        '<leader>dj',
        function()
          require('dap').down()
        end,
        desc = 'Down',
      },
      {
        '<leader>dk',
        function()
          require('dap').up()
        end,
        desc = 'Up',
      },
      {
        '<leader>dl',
        function()
          require('dap').run_last()
        end,
        desc = 'Run Last',
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        desc = 'Step Out',
      },
      {
        '<leader>dO',
        function()
          require('dap').step_over()
        end,
        desc = 'Step Over',
      },
      {
        '<leader>dp',
        function()
          require('dap').pause()
        end,
        desc = 'Pause',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        desc = 'Toggle REPL',
      },
      {
        '<leader>ds',
        function()
          require('dap').session()
        end,
        desc = 'Session',
      },
      {
        '<leader>dt',
        function()
          require('dap').terminate()
        end,
        desc = 'Terminate',
      },
      {
        '<leader>dw',
        function()
          require('dap.ui.widgets').hover()
        end,
        desc = 'Widgets Hover',
      },
    },
    config = function()
      -- If you have specific nvim-dap configurations (not dap-ui), put them here.
      -- e.g. require("dap.ext.vscode").load_launchjs()
      -- require('dap-python').setup('~/.virtualenvs/debugpy/bin/python') -- Moved to end of file
    end,
  },

  {
    'ellisonleao/gruvbox.nvim',
    config = function()
      require('gruvbox').setup {
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = { strings = false, emphasis = false, comments = true, operators = false, folds = true },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true,
        contrast = 'hard',
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      }
    end,
  },

  { 'mfussenegger/nvim-jdtls' }, -- For Java LSP and neotest-java dependency

  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = true,
  },

  -- Neotest adapter plugins (dependencies for neotest)
  {
    'rcasia/neotest-java',
    dependencies = {
      'mfussenegger/nvim-jdtls', -- Already listed above, lazy handles duplicates
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
  },
  { 'nvim-neotest/neotest-python' },

  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- Adapter plugins
      'rcasia/neotest-java',
      'nvim-neotest/neotest-python',
    },
    config = function()
      local neotest_java_ok, neotest_java = pcall(require, 'neotest-java')
      local neotest_python_ok, neotest_python = pcall(require, 'neotest-python')

      local adapters = {}
      if neotest_java_ok then
        table.insert(
          adapters,
          neotest_java {
            junit_jar_path = nil, -- Or specific path, nil uses default
            incremental_build = true,
          }
        )
      else
        vim.notify('neotest-java adapter module not found', vim.log.levels.WARN)
      end

      if neotest_python_ok then
        table.insert(
          adapters,
          neotest_python {
            dap = { justMyCode = false },
          }
        )
      else
        vim.notify('neotest-python adapter module not found', vim.log.levels.WARN)
      end

      require('neotest').setup { adapters = adapters }
    end,
  },

  { 'olrtg/emmet-language-server' },

  {
    'ellisonleao/glow.nvim',
    config = function()
      require('glow').setup()
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<C-p>p', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<C-p>a', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<C-p>g', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Fises ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<C-p>b', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } } } },
  { 'Bilal2453/luvit-meta', lazy = true },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- 'nvim-java/nvim-java', -- Removed, replaced by nvim-jdtls top-level
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local au_name = 'kickstart-lsp-highlight-' .. event.buf
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = vim.api.nvim_create_augroup(au_name, { clear = true }),
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = au_name,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', { -- Clear highlights on detach
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach-' .. event.buf, { clear = true }),
              buffer = event.buf,
              callback = function()
                vim.api.nvim_clear_autocmds { group = au_name, buffer = event.buf }
              end,
            })
          end
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        clangd = {},
        gopls = {},
        pyright = {
          settings = {
            pyright = { disableOrganizeImports = true, autoImportCompletion = true },
            python = { analysis = { typeCheckingMode = 'standard' } },
          },
        },
        ruff = { -- Assuming ruff is used as LSP, otherwise configure as linter in conform.nvim
          init_options = { settings = { logFile = '/tmp/ruff.log' } },
        },
        tailwindcss = {
          filetypes = { 'html', 'css', 'less', 'sass', 'scss', 'postcss', 'htmldjango' },
        },
        -- tsserver = {}, -- or ts_ls
        ts_ls = {}, -- Using ts_ls example
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        jdtls = {}, -- Placeholder, configuration will be handled by the handler
      }

      require('mason').setup()
      require('mason-tool-installer').setup {
        ensure_installed = vim.list_extend(vim.tbl_keys(servers), {
          'stylua',
          'markdownlint', -- jdtls, pyright already in servers
        }),
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            local server_opts = servers[server_name] or {}
            server_opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_opts.capabilities or {})

            if server_name == 'jdtls' then
              local jdtls_ok, jdtls_mod = pcall(require, 'jdtls')
              local jdtls_setup_ok, jdtls_setup_mod = pcall(require, 'jdtls.setup')

              if jdtls_ok and jdtls_setup_ok then
                vim.notify('nvim-jdtls Lua modules loaded successfully for LSP setup.', vim.log.levels.INFO)
                server_opts.on_attach = function(client, bufnr)
                  vim.api.nvim_exec_autocmds('LspAttach', { buffer = bufnr, modeline = false, data = { client_id = client.id } })
                  jdtls_mod.setup_dap { hotcodereplace = 'auto' }
                  jdtls_mod.dap.setup_dap_main_class_configs()
                end
                server_opts.root_dir = jdtls_setup_mod.find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', '.project' }
                -- Example for bundles, adjust based on nvim-jdtls docs
                -- server_opts.init_options = {
                --   bundles = jdtls_setup_mod.resolve_bundles and jdtls_setup_mod.resolve_bundles() or {}
                -- }
              else
                vim.notify(
                  'nvim-jdtls Lua modules could not be loaded. Please check plugin installation. JDTLS setup might be incomplete.',
                  vim.log.levels.ERROR
                )
              end
            else
              -- For other servers, general on_attach is handled by the LspAttach augroup
              -- server_opts.on_attach = function(client, bufnr)
              --   vim.api.nvim_exec_autocmds("LspAttach", { buffer = bufnr, modeline = false, data = { client_id = client.id } })
              -- end
            end
            require('lspconfig')[server_name].setup(server_opts)
          end,
        },
      }
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
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
        local disable_filetypes = { c = true, cpp = true }
        return { timeout_ms = 500, lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and 'never' or 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = function(bufnr)
          if require('conform').get_formatter_info('ruff_format', bufnr).available then
            return { 'ruff_format', 'ruff_organize_imports' } -- if ruff_format handles imports, just 'ruff_format'
          elseif require('conform').get_formatter_info('ruff', bufnr).available then
            return { 'ruff_organize_imports', 'ruff' } -- older ruff might lint and format separately for imports
          else
            return { 'isort', 'black' }
          end
        end,
        ['_'] = { 'trim_whitespace' },
      },
    },
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0) and nil or 'make install_jsregexp',
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'lazydev', group_index = 0 },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'cody' },
          { name = 'tailwindcss' },
        },
      }
    end,
  },

  {
    'ellisonleao/gruvbox.nvim', -- Also as a primary colorscheme choice
    priority = 1000,
    init = function()
      vim.cmd 'set termguicolors'
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'ruby', 'query', 'vim', 'vimdoc', 'java', 'python' },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns',
  -- { import = 'custom.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Configure neogit
local neogit_ok, neogit = pcall(require, 'neogit')
if neogit_ok then
  neogit.setup {
    disable_hint = false,
    disable_context_highlighting = false,
    disable_signs = false,
    disable_insert_on_commit = 'auto',
    filewatcher = { interval = 1000, enabled = true },
    graph_style = 'unicode',
    git_services = {
      ['github.com'] = 'https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1',
      ['bitbucket.org'] = 'https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1',
      ['gitlab.com'] = 'https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}',
    },
    telescope_sorter = function()
      local ts_fzf_ok, ts_fzf = pcall(require, 'telescope.extensions.fzf')
      if ts_fzf_ok and ts_fzf.native_fzf_sorter then
        return ts_fzf.native_fzf_sorter()
      end
      return nil
    end,
    remember_settings = true,
    use_per_project_settings = true,
    ignored_settings = {
      'NeogitPushPopup--force-with-lease',
      'NeogitPushPopup--force',
      'NeogitPullPopup--rebase',
      'NeogitCommitPopup--allow-empty',
      'NeogitRevertPopup--no-edit',
    },
    highlight = { italic = true, bold = true, underline = true },
    use_default_keymaps = true,
    auto_refresh = true,
    sort_branches = '-committerdate',
    kind = 'tab',
    disable_line_numbers = true,
    console_timeout = 2000,
    auto_show_console = true,
    status = { recent_commit_count = 10 },
    commit_editor = { kind = 'auto' },
    commit_select_view = { kind = 'tab' },
    commit_view = { kind = 'vsplit', verify_commit = (vim.fn.executable 'gpg' == 1) },
    log_view = { kind = 'tab' },
    rebase_editor = { kind = 'auto' },
    reflog_view = { kind = 'tab' },
    merge_editor = { kind = 'auto' },
    tag_editor = { kind = 'auto' },
    preview_buffer = { kind = 'split' },
    popup = { kind = 'split' },
    signs = { hunk = { '', '' }, item = { '>', 'v' }, section = { '>', 'v' } },
    integrations = { telescope = nil, diffview = nil, fzf_lua = nil },
    sections = { -- Defaults are fine
      sequencer = { folded = false, hidden = false },
      untracked = { folded = false, hidden = false },
      unstaged = { folded = false, hidden = false },
      staged = { folded = false, hidden = false },
      stashes = { folded = true, hidden = false },
      unpulled_upstream = { folded = true, hidden = false },
      unmerged_upstream = { folded = false, hidden = false },
      unpulled_pushRemote = { folded = true, hidden = false },
      unmerged_pushRemote = { folded = false, hidden = false },
      recent = { folded = true, hidden = false },
      rebase = { folded = true, hidden = false },
    },
    mappings = { -- Defaults are fine
      commit_editor = { ['q'] = 'Close', ['<c-c><c-c>'] = 'Submit', ['<c-c><c-k>'] = 'Abort' },
      rebase_editor = {
        ['p'] = 'Pick',
        ['r'] = 'Reword',
        ['e'] = 'Edit',
        ['s'] = 'Squash',
        ['f'] = 'Fixup',
        ['x'] = 'Execute',
        ['d'] = 'Drop',
        ['b'] = 'Break',
        ['q'] = 'Close',
        ['<cr>'] = 'OpenCommit',
        ['gk'] = 'MoveUp',
        ['gj'] = 'MoveDown',
        ['<c-c><c-c>'] = 'Submit',
        ['<c-c><c-k>'] = 'Abort',
      },
      finder = {
        ['<cr>'] = 'Select',
        ['<c-c>'] = 'Close',
        ['<esc>'] = 'Close',
        ['<c-n>'] = 'Next',
        ['<c-p>'] = 'Previous',
        ['<down>'] = 'Next',
        ['<up>'] = 'Previous',
        ['<tab>'] = 'MultiselectToggleNext',
        ['<s-tab>'] = 'MultiselectTogglePrevious',
        ['<c-j>'] = 'NOP',
      },
      popup = {
        ['?'] = 'HelpPopup',
        ['A'] = 'CherryPickPopup',
        ['D'] = 'DiffPopup',
        ['M'] = 'RemotePopup',
        ['P'] = 'PushPopup',
        ['X'] = 'ResetPopup',
        ['Z'] = 'StashPopup',
        ['b'] = 'BranchPopup',
        ['c'] = 'CommitPopup',
        ['f'] = 'FetchPopup',
        ['l'] = 'LogPopup',
        ['m'] = 'MergePopup',
        ['p'] = 'PullPopup',
        ['r'] = 'RebasePopup',
        ['v'] = 'RevertPopup',
        ['w'] = 'WorktreePopup',
      },
      status = {
        ['q'] = 'Close',
        ['I'] = 'InitRepo',
        ['1'] = 'Depth1',
        ['2'] = 'Depth2',
        ['3'] = 'Depth3',
        ['4'] = 'Depth4',
        ['<tab>'] = 'Toggle',
        ['x'] = 'Discard',
        ['s'] = 'Stage',
        ['S'] = 'StageUnstaged',
        ['<c-s>'] = 'StageAll',
        ['u'] = 'Unstage',
        ['U'] = 'UnstageStaged',
        ['$'] = 'CommandHistory',
        ['#'] = 'Console',
        ['Y'] = 'YankSelected',
        ['<c-r>'] = 'RefreshBuffer',
        ['<enter>'] = 'GoToFile',
        ['<c-v>'] = 'VSplitOpen',
        ['<c-x>'] = 'SplitOpen',
        ['<c-t>'] = 'TabOpen',
        ['{'] = 'GoToPreviousHunkHeader',
        ['}'] = 'GoToNextHunkHeader',
      },
    },
  }
else
  vim.notify('Neogit plugin not found.', vim.log.levels.WARN)
end

require('luasnip').filetype_extend('htmldjango', { 'html' })

local dap_python_ok, dap_python = pcall(require, 'dap-python')
if dap_python_ok then
  dap_python.setup '~/src/virtualenvs/debugpy/bin/python' -- Ensure this path is correct for your system
else
  vim.notify('dap-python not found for setup.', vim.log.levels.WARN)
end

vim.keymap.set('n', '<leader>A', function()
  local lspimport_ok, lspimport = pcall(require, 'lspimport')
  if lspimport_ok then
    lspimport.import()
  else
    vim.notify('lspimport not found for <leader>A', vim.log.levels.WARN)
  end
end, { noremap = true })

-- vim: ts=2 sts=2 sw=2 et
