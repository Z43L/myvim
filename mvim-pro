
-- =====================================================================
--  Neovim Pro Setup (single-file, Lua-first, lazy.nvim plugin manager)
--  Drop this file at: ~/.config/nvim/init.lua
--  Requires Neovim 0.9+ (0.10+ recommended)
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
        'git', 'clone', '--filter=blob:none',
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
    { 'folke/tokyonight.nvim',   lazy = false,  priority = 1000,                              opts = { style = 'night' } },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = function()
            return { options = { theme = 'tokyonight', globalstatus = true } }
        end
    },
    { 'akinsho/bufferline.nvim', version = '*', dependencies = 'nvim-tree/nvim-web-devicons', opts = {} },
    { 'rcarriga/nvim-notify',    opts = {} },
    { 'stevearc/dressing.nvim',  opts = {} },
    { 'folke/which-key.nvim',    opts = {} },

    -- File explorer
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = 'nvim-tree/nvim-web-devicons',
        opts = {
            view = { width = 34, side = 'left' },
            filters = { dotfiles = false },
            git = { enable = true },
        }
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
        end
    },

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = {
                'bash', 'c', 'lua', 'python', 'javascript', 'typescript', 'tsx', 'html', 'css', 'json', 'yaml', 'toml',
                'markdown', 'markdown_inline', 'vim', 'vimdoc', 'gitignore'
            },
            highlight = { enable = true },
            indent = { enable = true },
        }
    },

    -- Git
    { 'lewis6991/gitsigns.nvim',             opts = {} },

    -- Indentation guides
    { 'lukas-reineke/indent-blankline.nvim', main = 'ibl',                                                                                                     opts = {} },

    -- Comments
    { 'numToStr/Comment.nvim',               opts = {} },

    -- Autopairs
    { 'windwp/nvim-autopairs',               opts = { check_ts = true } },

    -- Todo highlights
    { 'folke/todo-comments.nvim',            dependencies = 'nvim-lua/plenary.nvim',                                                                           opts = {} },

    -- Diagnostics list & quickfix++
    { 'folke/trouble.nvim',                  dependencies = 'nvim-tree/nvim-web-devicons',                                                                     opts = {} },

    -- Terminal
    { 'akinsho/toggleterm.nvim',             version = '*',                                                                                                    opts = { open_mapping = [[<c-`>]], direction = 'float' } },

    -- Project & sessions
    { 'ahmedkhalf/project.nvim',             opts = { detection_methods = { 'pattern' }, patterns = { '.git', 'Makefile', 'package.json', 'pyproject.toml' } } },
    { 'folke/persistence.nvim',              event = 'BufReadPre',                                                                                             opts = {} },

    -- LSP, DAP, formatting, completion
    { 'williamboman/mason.nvim',             opts = {} },
    { 'williamboman/mason-lspconfig.nvim',   dependencies = 'mason.nvim',                                                                                      opts = { ensure_installed = { 'lua_ls', 'pyright', 'ts_ls', 'bashls', 'html', 'cssls', 'jsonls', 'yamlls' } } },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'L3MON4D3/LuaSnip',                    build = 'make install_jsregexp' },
    { 'rafamadriz/friendly-snippets' },
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'ruff_format' },
                javascript = { 'prettier' },
                typescript = { 'prettier' },
                css = { 'prettier' },
                html = { 'prettier' },
                json = { 'jq' },
                yaml = { 'yamlfmt' },
            },
            format_on_save = function(buf)
                return { timeout_ms = 1000, lsp_fallback = true }
            end,
        }
    },

    -- Breadcrumbs
    { 'SmiteshP/nvim-navic', dependencies = 'neovim/nvim-lspconfig' },

    -- Status of LSP progress (nice-to-have)
    { 'j-hui/fidget.nvim',   opts = {} },

    -- Ollama (local AI)
    {
        'nomnivore/ollama.nvim',
        opts = {
            model = 'gemma3:12b',
            prompt = '> ',
            accept_keymap = '<C-y>',
            chat_separator = '────────────────────────────',
            mappings = { send = '<C-y>', close = '<Esc>' },
            prompts = {
                Ask_About_Code = {
                    prompt =
                    [[Eres un experto. Responde preguntas sobre el código seleccionado ($sel) o, si no hay selección, sobre el buffer. Pregunta: $input]],
                    input_label = 'Q> ',
                    action = 'display',
                },
                Explain_Code = {
                    prompt = [[Explica claramente qué hace este código: $sel]],
                    action = 'display',
                },
                Generate_Code = {
                    prompt = [[Genera el código solicitado: $input. Si hay contexto: $sel]],
                    action = 'insert', -- inserta en el buffer (puedes usar 'display' si prefieres ver primero)
                },
                Modify_Code = {
                    prompt = [[Refactoriza o modifica el siguiente código según: $input. Código: $sel]],
                    action = 'replace', -- reemplaza la selección
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

    -- CodeCompanion integration with Ollama
    {
        'olimorris/codecompanion.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            strategies = {
                chat = {
                    adapter = 'ollama',
                    options = {
                        model = 'gemma3:12b',
                        temperature = 0.7,
                    },
                },
                inline = {
                    adapter = 'ollama',
                    options = {
                        model = 'gemma3:12b',
                        temperature = 0.7,
                    },
                },
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
-- LSP setup
-- ---------------------------------------------------------------------
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = { 'ts_ls', 'pyright', 'lua_ls', 'bashls', 'html', 'cssls', 'jsonls', 'yamlls' }
for _, s in ipairs(servers) do
    lspconfig[s].setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            -- nvim-navic (breadcrumbs)
            pcall(function()
                require('nvim-navic').attach(client, bufnr)
            end)
        end
    })
end

-- Fix diagnostics look
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
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
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
cmp.setup.cmdline(':',
    {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = 'path' } },
            { { name = 'cmdline' } })
    })

-- ---------------------------------------------------------------------
-- Keymaps (leader = space)
-- ---------------------------------------------------------------------
--
--
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
            vim.fn.setpos("'<", { 0, le, ce, 0 })
            vim.fn.setpos("'>", { 0, ls, cs, 0 })
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
map('n', 'K', vim.lsp.buf.hover, silent)
map('n', '<leader>rn', vim.lsp.buf.rename, silent)
map('n', '<leader>ca', vim.lsp.buf.code_action, silent)

-- Formatting (Conform)
map({ 'n', 'v' }, '<leader>f', function() require('conform').format({ async = true }) end, silent)

-- Comment
map({ 'n', 'v' }, '<leader>/', function() require('Comment.api').toggle.linewise.current() end, silent)

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
-- Normal/Visual: abre selector general
map({ 'n', 'v' }, '<leader>c', ":<C-u>lua require('ollama').prompt()<C-y>", { silent = true, desc = 'Ollama prompt' })

-- Visual: invoca prompts concretos (funcionan también en Normal; en Visual usan $sel)
map({ 'n', 'v' }, '<leader>aa', ":<C-u>lua require('ollama').prompt('Ask_About_Code')<CR>", { silent = true })
map({ 'n', 'v' }, '<leader>ee', ":<C-u>lua require('ollama').prompt('Explain_Code')<CR>", { silent = true })
map({ 'n', 'v' }, '<leader>gg', ":<C-u>lua require('ollama').prompt('Generate_Code')<CR>", { silent = true })
map({ 'n', 'v' }, '<leader>mm', ":<C-u>lua require('ollama').prompt('Modify_Code')<CR>", { silent = true })
map({ 'n', 'v' }, '<leader>ss', ":<C-u>lua require('ollama').prompt('Simplify_Code')<CR>", { silent = true })
map({ 'n', 'v' }, '<leader>rr', ":<C-u>lua require('ollama').prompt('Raw')<CR>", { silent = true })

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
    { '<leader>p', group = 'Projects' },
    { '<leader>t', group = 'Terminal' },
    { '<leader>c', group = 'Chat/AI' },
})

-- ---------------------------------------------------------------------
-- Per-language niceties
-- ---------------------------------------------------------------------
-- Lua: make lua_ls happy about Neovim globals
require('lspconfig').lua_ls.setup({
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        }
    }
})

-- ---------------------------------------------------------------------
-- Final touches
-- ---------------------------------------------------------------------
-- Save with Ctrl-s
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<cmd>w<CR>', { silent = true })

-- Use system clipboard on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 120 }) end,
})

-- Project.nvim integration with Telescope
pcall(function() require('telescope').load_extension('projects') end)
