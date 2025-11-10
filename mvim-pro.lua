-- =====================================================================
--  Neovim Pro Setup (single-file, Lua-first, lazy.nvim plugin manager)
--  Drop this file at: ~/.config/nvim/init.lua
--  Requires Neovim 0.11+
-- =====================================================================

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ---------------------------------------------------------------------
-- Bootstrap lazy.nvim
-- ---------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git','clone','--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ---------------------------------------------------------------------
-- Core options
-- ---------------------------------------------------------------------
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.updatetime = 200
opt.timeoutlen = 400
opt.scrolloff = 6
opt.splitbelow = true
opt.splitright = true
opt.cursorline = true
opt.clipboard = 'unnamedplus'

-- ---------------------------------------------------------------------
-- Plugins
-- ---------------------------------------------------------------------
require('lazy').setup({
  -- Theme & UI
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000, opts = { style = 'night' } },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function() return { options = { theme = 'tokyonight', globalstatus = true } } end
  },
  { 'akinsho/bufferline.nvim', version = '*', dependencies = 'nvim-tree/nvim-web-devicons', opts = {} },
  { 'rcarriga/nvim-notify', opts = {} },
  { 'stevearc/dressing.nvim', opts = {} },
  { 'folke/which-key.nvim', opts = {} },

  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-tree').setup({
        view = { width = 34, side = 'left' },
        filters = { dotfiles = false },
        git = { enable = true },
      })
    end
  },

  -- Finder & fuzzy
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    opts = { defaults = { prompt_prefix = '  ', selection_caret = ' ', path_display = { 'smart' } } },
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'projects')
    end
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash','c','lua','python','javascript','typescript','tsx','html','css','json','yaml','toml',
        'markdown','markdown_inline','vim','vimdoc','gitignore'
      },
      highlight = { enable = true },
      indent = { enable = true },
    }
  },

  -- Git
  { 'lewis6991/gitsigns.nvim', opts = {} },

  -- Indentation guides
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },

  -- Comments
  { 'numToStr/Comment.nvim', opts = {} },

  -- Autopairs
  { 'windwp/nvim-autopairs', opts = { check_ts = true } },

  -- Todo highlights
  { 'folke/todo-comments.nvim', dependencies = 'nvim-lua/plenary.nvim', opts = {} },

  -- Diagnostics list & quickfix++
  { 'folke/trouble.nvim', dependencies = 'nvim-tree/nvim-web-devicons', opts = {} },

  -- Terminal
  { 'akinsho/toggleterm.nvim', version = '*', opts = { open_mapping = [[<c-`>]], direction = 'float' } },

  -- Project & sessions
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup({
        detection_methods = { 'pattern' },
        patterns = { '.git', 'Makefile', 'package.json', 'pyproject.toml' },
      })
    end
  },
  { 'folke/persistence.nvim', event = 'BufReadPre', opts = {} },

  -- LSP / Formatting / Completion
  { 'williamboman/mason.nvim', opts = {} },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'mason.nvim' },
    opts = { ensure_installed = { 'lua_ls','pyright','ts_ls','bashls','html','cssls','jsonls','yamlls' } }
  },
  { 'neovim/nvim-lspconfig' }, -- solo para leer server_configurations (sin framework)

  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
  { 'rafamadriz/friendly-snippets' },

  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
        javascript = { 'prettier' }, typescript = { 'prettier' },
        css = { 'prettier' }, html = { 'prettier' }, json = { 'jq' },
        yaml = { 'yamlfmt' },
      },
      format_on_save = function(_) return { timeout_ms = 1000, lsp_fallback = true } end,
    }
  },

  -- Breadcrumbs
  { 'SmiteshP/nvim-navic', dependencies = 'neovim/nvim-lspconfig' },

  -- LSP progress
  { 'j-hui/fidget.nvim', opts = {} },

  -- Ollama (local AI)
  {
    'nomnivore/ollama.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      model = 'llama3.1:8b-instruct-q4_K_M',
      prompt = '> ',
      accept_keymap = '<C-y>',
      chat_separator = '────────────────────────────',
      mappings = { send = '<C-y>', close = '<Esc>' },
      options = {
        num_ctx = 2048,
        num_predict = 512,
        temperature = 0.6,
        top_p = 0.9,
      },
      prompts = {
        Ask_About_Code = {
          prompt = [[Eres un experto. Responde preguntas sobre el código seleccionado ($sel) o, si no hay selección, sobre el buffer. Pregunta: $input]],
          input_label = 'Q> ',
          action = 'display',
        },
        Explain_Code = {
          prompt = [[Explica claramente qué hace este código: $sel]],
          action = 'display',
        },
        Generate_Code = {
          prompt = [[Genera el código solicitado: $input. Si hay contexto: $sel]],
          action = 'display',
        },
        Modify_Code = {
          prompt = [[Refactoriza o modifica el siguiente código según: $input. Código: $sel]],
          action = 'replace',
        },
        Simplify_Code = {
          prompt = [[Simplifica el siguiente código manteniendo la funcionalidad: $sel]],
          action = 'replace',
        },
        Raw = {
          prompt = [[$input]],
          action = 'display',
        },
      },
    }
  },

  -- CodeCompanion + Ollama
  {
    'olimorris/codecompanion.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      strategies = {
        chat = { adapter = 'ollama', options = { model = 'llama3.1:8b-instruct-q4_K_M', temperature = 0.7 } },
        inline = { adapter = 'ollama', options = { model = 'llama3.1:8b-instruct-q4_K_M', temperature = 0.7 } },
      },
      keymaps = {
        toggle_chat = '<leader>cc',
        inline_code = '<leader>ci',
      },
    }
  },

}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})

-- ---------------------------------------------------------------------
-- Colorscheme
-- ---------------------------------------------------------------------
vim.cmd.colorscheme('tokyonight')

-- ---------------------------------------------------------------------
-- LSP setup (Neovim 0.11+ API — sin framework lspconfig)
-- ---------------------------------------------------------------------
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('mason').setup()
require('mason-lspconfig').setup()

-- Lista de servers
local servers = { 'ts_ls','pyright','lua_ls','bashls','html','cssls','jsonls','yamlls' }

-- Para cada server, usamos la definición de nvim-lspconfig/server_configurations
for _, server in ipairs(servers) do
  local ok, mod = pcall(require, 'lspconfig.server_configurations.' .. server)
  if ok and mod and mod.default_config then
    local default = vim.deepcopy(mod.default_config)
    local filetypes = default.filetypes or {}

    -- Ajustes específicos que tenías (ej. lua_ls globals = { 'vim' })
    if server == 'lua_ls' then
      default.settings = default.settings or {}
      default.settings.Lua = default.settings.Lua or {}
      default.settings.Lua.diagnostics = default.settings.Lua.diagnostics or {}
      default.settings.Lua.diagnostics.globals = { 'vim' }
      default.settings.Lua.workspace = { checkThirdParty = false }
      default.settings.Lua.telemetry = { enable = false }
    end

    -- Autocmd para iniciar el cliente en buffers con esos filetypes
    vim.api.nvim_create_autocmd('FileType', {
      pattern = filetypes,
      callback = function(args)
        local bufnr = args.buf
        -- Evitar duplicados
        for _, client in pairs(vim.lsp.get_clients({ buffer = bufnr })) do
          if client.name == server then return end
        end
        -- root_dir según default_config.root_dir si existe
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root_dir = default.root_dir and default.root_dir(fname)
        local cfg = vim.lsp.config(vim.tbl_deep_extend('force', default, {
          name = server,
          capabilities = capabilities,
          root_dir = root_dir or vim.fn.getcwd(),
        }))
        vim.lsp.start(cfg, { bufnr = bufnr })
      end
    })
  end
end

-- nvim-navic attach al arrancar cualquier LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    pcall(function() require('nvim-navic').attach(client, args.buf) end)
  end
})

-- Diagnósticos
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = '●' },
  float = { border = 'rounded' },
})

-- ---------------------------------------------------------------------
-- Completion (nvim-cmp)
-- ---------------------------------------------------------------------
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { 'i','s' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { 'i','s' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  })
})

-- Cmdline completion
cmp.setup.cmdline({ '/', '?' }, { mapping = cmp.mapping.preset.cmdline(), sources = { { name = 'buffer' } } })
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
})

-- ---------------------------------------------------------------------
-- Keymaps (leader = space)
-- ---------------------------------------------------------------------
local map = vim.keymap.set
local silent = { noremap = true, silent = true }

-- Normaliza la selección visual (evita rangos invertidos que rompen ollama.nvim)
local function with_norm_vis(cmd)
  return function()
    local _, ls, cs = unpack(vim.fn.getpos("'<"))
    local _, le, ce = unpack(vim.fn.getpos("'>"))
    if ls > le or (ls == le and cs > ce) then
      vim.fn.setpos("'<", {0, le, ce, 0})
      vim.fn.setpos("'>", {0, ls, cs, 0})
    end
    vim.cmd(cmd)
  end
end

-- File explorer & files
map('n', '<leader>e', require('nvim-tree.api').tree.toggle, silent)
map('n', '<leader>w', '<cmd>w<CR>', silent)
map('n', '<leader>q', '<cmd>q<CR>', silent)

-- Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', silent)
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', silent)
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>', silent)
map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', silent)

-- Windows
map('n', '<leader>sv', '<C-w>v', silent)
map('n', '<leader>sh', '<C-w>s', silent)
map('n', '<leader>se', '<C-w>=', silent)
map('n', '<leader>sx', '<cmd>close<CR>', silent)

-- Diagnostics
map('n', '[d', vim.diagnostic.goto_prev, silent)
map('n', ']d', vim.diagnostic.goto_next, silent)
map('n', '<leader>do', vim.diagnostic.open_float, silent)
map('n', '<leader>dl', '<cmd>Trouble diagnostics toggle<CR>', silent)

-- LSP
map('n', 'gd', vim.lsp.buf.definition, silent)
map('n', 'gr', vim.lsp.buf.references, silent)
map('n', 'gi', vim.lsp.buf.implementation, silent)
map('n', 'K',  vim.lsp.buf.hover, silent)
map('n', '<leader>rn', vim.lsp.buf.rename, silent)
map('n', '<leader>ca', vim.lsp.buf.code_action, silent)

-- Formatting (Conform)
map({ 'n','v' }, '<leader>f', function() require('conform').format({ async = true }) end, silent)

-- Comment
map({ 'n','v' }, '<leader>/', function() require('Comment.api').toggle.linewise.current() end, silent)

-- Git
map('n', '<leader>gb', '<cmd>Gitsigns blame_line<CR>', silent)
map('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>', silent)

-- Trouble
map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', silent)
map('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', silent)

-- Terminal
map('n', '<leader>tt', '<cmd>ToggleTerm<CR>', silent)

-- Project/session
map('n', '<leader>pp', function() require('telescope').extensions.projects.projects({}) end, silent)
map('n', '<leader>ss', function() require('persistence').load() end, silent)
map('n', '<leader>sl', function() require('persistence').load({ last = true }) end, silent)
map('n', '<leader>sd', function() require('persistence').stop() end, silent)

-- Ollama
-- Abrir selector de prompts de Ollama (Normal y Visual) en <leader>p
map({ 'n','v' }, '<leader>p', ":<C-u>lua require('ollama').prompt()<CR>", { silent = true, desc = 'Ollama prompt' })

-- Visual: invoca prompts concretos con selección normalizada
map('v', '<leader>aa', with_norm_vis("lua require('ollama').prompt('Ask_About_Code')"), { silent = true })
map('v', '<leader>ee', with_norm_vis("lua require('ollama').prompt('Explain_Code')"),   { silent = true })
map('v', '<leader>gg', with_norm_vis("lua require('ollama').prompt('Generate_Code')"),  { silent = true })
map('v', '<leader>mm', with_norm_vis("lua require('ollama').prompt('Modify_Code')"),    { silent = true })
map('v', '<leader>ss', with_norm_vis("lua require('ollama').prompt('Simplify_Code')"),  { silent = true })
map('v', '<leader>rr', with_norm_vis("lua require('ollama').prompt('Raw')"),            { silent = true })

-- CodeCompanion shortcuts
map('n', '<leader>cc', '<cmd>CodeCompanionChatToggle<CR>', silent)
map('v', '<leader>ci', '<cmd>CodeCompanionInline<CR>', silent)

-- Which-key labels
local wk = require('which-key')
wk.add({
  { '<leader>f', group = 'Find/Telescope' },
  { '<leader>g', group = 'Git' },
  { '<leader>x', group = 'Diagnostics (Trouble)' },
  { '<leader>s', group = 'Sessions' },
  { '<leader>p', group = 'Ollama' },
  { '<leader>pp', desc = 'Projects (Telescope)' },
  { '<leader>t', group = 'Terminal' },
  { '<leader>c', group = 'Chat/AI' },
})

-- ---------------------------------------------------------------------
-- Final touches
-- ---------------------------------------------------------------------
-- Save with Ctrl-s
vim.keymap.set({ 'n','i','v' }, '<C-s>', '<cmd>w<CR>', { silent = true })

-- Resaltar yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 120 }) end,
})

-- Telescope projects extension (en caso de carga perezosa)
pcall(function() require('telescope').load_extension('projects') end)
