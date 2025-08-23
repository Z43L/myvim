" =============================================================================
" SECCIÓN 1: CONFIGURACIÓN INICIAL Y VIM-PLUG
" =============================================================================

let mapleader = " "

" Instala vim-plug automáticamente
let plug_path = stdpath('data') . '/site/autoload/plug.vim'
if empty(glob(plug_path))
  silent !curl -fLo plug_path --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Lista de Plugins
call plug#begin('~/.config/nvim/plugged')

" ===== UI y Apariencia =====
Plug 'folke/tokyonight.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'stevearc/dressing.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'folke/which-key.nvim'
Plug 'onsails/lspkind.nvim' " Iconos para LSP

" ===== Utilidades y Core =====
Plug 'nvim-lua/plenary.nvim'
Plug 'numToStr/Comment.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'kylechui/nvim-surround'
Plug 'phaazon/hop.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'github/copilot.vim'

" ===== Búsqueda (Telescope) =====
Plug 'nvim-telescope/telescope.nvim'

" ===== LSP, Autocompletado y Snippets =====
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'jose-elias-alvarez/null-ls.nvim' " Para linters/formatters como ESLint
Plug 'glepnir/lspsaga.nvim'

" ===== Treesitter =====
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" ===== Depuración (DAP) =====
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-neotest/nvim-nio' " Dependencia de dap-ui

" ===== Herramientas Específicas =====
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install' }
Plug 'MunifTanjim/prettier.nvim'
Plug 'mattn/emmet-vim'
Plug '42Paris/42header'
Plug 'folke/trouble.nvim'
" Frameworks (opcionales)
Plug 'pantharshit00/vim-prisma', { 'for': 'typescriptreact' }
Plug 'jparise/vim-graphql', { 'for': ['graphql', 'typescriptreact', 'javascriptreact'] }

call plug#end()


" =============================================================================
" SECCIÓN 2: OPCIONES, ATAJOS Y CONFIGURACIÓN DE PLUGINS (LUA)
" =============================================================================

lua << EOF

-- ------------------
-- Opciones Generales
-- ------------------
local opt = vim.opt
local g = vim.g

opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.termguicolors = true
opt.clipboard = 'unnamedplus'

g.AutoPairsMapCR = 0
g.user42 = 'davmoren'
g.mail42 = 'davmoren@student.42urduliz.com'
g.user_emmet_settings = { javascript = { extends = 'jsx' } }

-- Configuración del portapapeles para WSL
if vim.fn.executable('win32yank.exe') == 1 then
  g.clipboard = {
    name = 'win32yank-wsl',
    copy = { ['+'] = 'win32yank.exe -i --crlf', ['*'] = 'win32yank.exe -i --crlf' },
    paste = { ['+'] = 'win32yank.exe -o --lf', ['*'] = 'win32yank.exe -o --lf' },
    cache_enabled = 1,
  }
end

-- Aplicar tema de color
vim.cmd('colorscheme tokyonight')

-- ------------------
-- Atajos de Teclado
-- ------------------
local map = vim.keymap.set

map('n', '<leader>hh', function() _G.toggle_help_window() end, { desc = 'Mostrar Ayuda Personalizada' })
map('n', '<leader>w', ':w<CR>', { desc = 'Guardar' })
map('n', '<leader>q', ':q<CR>', { desc = 'Salir' })
map('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Explorador de archivos' })
map('n', '<C-h>', '<C-w>h', { desc = 'Ventana izquierda' })
map('n', '<C-j>', '<C-w>j', { desc = 'Ventana abajo' })
map('n', '<C-k>', '<C-w>k', { desc = 'Ventana arriba' })
map('n', '<C-l>', '<C-w>l', { desc = 'Ventana derecha' })
map('n', '<leader>bp', ':BufferLinePick<CR>', { desc = 'Seleccionar buffer' })
map('n', '<leader>bd', ':BufferLinePickClose<CR>', { desc = 'Cerrar buffer' })
map('n', '<leader>ff', ':Telescope find_files<CR>', { desc = 'Buscar archivos' })
map('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = 'Buscar en archivos' })
map('n', '<leader>fb', ':Telescope buffers<CR>', { desc = 'Buscar en buffers' })
map('n', '<leader>fh', ':Telescope help_tags<CR>', { desc = 'Buscar ayuda' })
map('n', '<F5>', ':lua require("dap").continue()<CR>', { desc = 'DAP: Continuar' })
map('n', '<F10>', ':lua require("dap").step_over()<CR>', { desc = 'DAP: Saltar' })
map('n', '<F11>', ':lua require("dap").step_into()<CR>', { desc = 'DAP: Entrar' })
map('n', '<F12>', ':lua require("dap").step_out()<CR>', { desc = 'DAP: Salir' })
map('n', '<leader>db', ':lua require("dap").toggle_breakpoint()<CR>', { desc = 'DAP: Breakpoint' })
map('n', '<leader>dr', ':lua require("dap").repl.open()<CR>', { desc = 'DAP: Abrir REPL' })
map('n', '<leader>cc', ':CopilotChat<CR>', { desc = 'Copilot: Chat' })
map('x', '<leader>cs', ':CopilotChatVisual<CR>', { desc = 'Copilot: Chat selección' })
map('x', '<leader>ce', ':<C-u>CopilotChatVisual Explica este código.<CR>', { desc = 'Copilot: Explicar' })
map('x', '<leader>cr', ':<C-u>CopilotChatVisual Refactoriza este código.<CR>', { desc = 'Copilot: Refactorizar' })

-- -------------------------
-- Configuración de Plugins
-- -------------------------

-- Lualine, Bufferline, NvimTree, Telescope (sin cambios)
require('lualine').setup { options = { theme = 'tokyonight' } }
require("bufferline").setup{}
require('nvim-tree').setup({ disable_netrw = true, hijack_netrw = true, view = { width = 30, side = 'left' } })
require('telescope').setup({ defaults = { prompt_prefix = "🔍 ", selection_caret = "➜ ", layout_config = { width = 0.9 } } })

-- Treesitter (con más lenguajes)
require('nvim-treesitter.configs').setup({
  ensure_installed = { "c", "cpp", "lua", "javascript", "typescript", "tsx", "json", "html", "css", "python", "go", "rust", "java", "bash", "markdown" },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = { enable = true }
})

-- Comment, Hop, Prettier, Null-ls (sin cambios)
require('Comment').setup()
require('hop').setup()
require("prettier").setup({ bin = 'prettier', filetypes = { "css", "graphql", "html", "javascript", "javascriptreact", "json", "less", "markdown", "scss", "typescript", "typescriptreact", "yaml" }})
vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.scss", "*.html", "*.json", "*.md" }, callback = function() vim.cmd("Prettier") end })
local null_ls = require("null-ls")
null_ls.setup({ sources = { null_ls.builtins.diagnostics.eslint_d.with({ condition = function(utils) return utils.root_has_file({'.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json'}) end }) } })

-- Mason & lspconfig
require('mason').setup()
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- ✅ LISTA DE HERRAMIENTAS "TODOTERRENO" AMPLIADA
require('mason-lspconfig').setup({
  ensure_installed = {
    -- LSPs
    'lua_ls', 'clangd', 'tsserver', 'angularls', 'html', 'cssls', 'tailwindcss', 'jsonls', 'yamlls', 'graphql',
    'pyright', 'gopls', 'rust_analyzer', 'jdtls', 'dockerls', 'bashls', 'marksman',
    -- Debuggers (DAP)
    'debugpy',      -- Python
    'delve',        -- Go
    'js-debug-adapter', -- JS/TS/Node
    'codelldb',     -- Rust, C++
    'java-debug-adapter',
  },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({ capabilities = capabilities })
    end,
    -- Configuración especial para jdtls (Java)
    ['jdtls'] = function()
      -- No hacemos nada aquí por ahora, se necesita una configuración más avanzada
      -- que depende del proyecto. Pero con esto ya se inicia.
    end,
  },
})

-- nvim-cmp (sin cambios)
local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')
cmp.setup({ snippet = { expand = function(args) luasnip.lsp_expand(args.body) end }, sources = cmp.config.sources({{ name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'path' }, { name = 'buffer' }}), mapping = { ['<C-n>'] = cmp.mapping.select_next_item(), ['<C-p>'] = cmp.mapping.select_prev_item(), ['<C-d>'] = cmp.mapping.scroll_docs(-4), ['<C-f>'] = cmp.mapping.scroll_docs(4), ['<C-Space>'] = cmp.mapping.complete(), ['<CR>'] = cmp.mapping.confirm({ select = true }), ['<Tab>'] = cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fallback() end end, { 'i', 's' }), ['<S-Tab>'] = cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() elseif luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end end, { 'i', 's' }) }, formatting = { format = lspkind.cmp_format({ mode = 'symbol', maxwidth = 50, ellipsis_char = '...' }) } })

-- ✅ CONFIGURACIÓN DEL DEBUGGER (DAP) AMPLIADA
-- =============================================
local dap = require('dap')
local dapui = require('dapui')
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

-- --- Adaptadores ---
-- Le dicen a DAP qué programa usar para cada lenguaje
local mason_path = vim.fn.stdpath("data") .. '/mason/bin'

dap.adapters.cppdbg = { id = 'cppdbg', type = 'executable', command = '/home/davmoren/cpptools/extension/debugAdapters/bin/OpenDebugAD7' }
dap.adapters.codelldb = { id = 'codelldb', type = 'server', port = "${port}", executable = { command = mason_path .. '/codelldb', args = {"--port", "${port}"} } }
dap.adapters.python = { id = 'python', type = 'executable', command = mason_path .. '/debugpy', args = { '-m', 'debugpy.adapter' } }
dap.adapters.node2 = { id = 'node2', type = 'executable', command = mason_path .. '/js-debug-adapter', args = { 'js-debug-adapter' } }
dap.adapters.delve = { id = 'delve', type = 'server', port = "${port}", executable = { command = mason_path .. '/dlv', args = {"dap", "-l", "127.0.0.1:${port}"} } }

-- --- Configuraciones de Lanzamiento ---
-- Le dicen a DAP cómo ejecutar tu código
dap.configurations.c = { { name = "Launch C", type = "cppdbg", request = "launch", program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end, cwd = '${workspaceFolder}', stopOnEntry = false } }
dap.configurations.cpp = { { name = "Launch C++", type = "cppdbg", request = "launch", program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end, cwd = '${workspaceFolder}', stopOnEntry = false } }
dap.configurations.rust = { { name = 'Launch Rust', type = 'codelldb', request = 'launch', program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file') end, cwd = '${workspaceFolder}', stopOnEntry = false } }
dap.configurations.python = { { type = 'python', request = 'launch', name = 'Launch Python file', program = '${file}', pythonPath = function() return vim.fn.stdpath("data") .. '/mason/packages/debugpy/venv/bin/python' end } }
dap.configurations.go = { { type = "delve", name = "Launch Go file", request = "launch", program = "${fileDirname}" } }
dap.configurations.javascript = { { type = "node2", name = "Launch JS file", request = "launch", program = "${file}", cwd = vim.fn.getcwd(), sourceMaps = true, protocol = "inspector", console = "integratedTerminal" } }
dap.configurations.typescript = { { type = "node2", name = "Launch TS file", request = "launch", program = "${file}", cwd = vim.fn.getcwd(), sourceMaps = true, protocol = "inspector", console = "integratedTerminal" } }


-- Ventana de Ayuda
local help_win = nil
function _G.toggle_help_window()
  if help_win and vim.api.nvim_win_is_valid(help_win) then
    vim.api.nvim_win_close(help_win, true)
    help_win = nil
    return
  end
  local help_content = {
    '# 📜 Ayuda de mi Configuración de Neovim', '', '## Mi Configuración (Z43L)',
    '### Atajos Principales (`<leader>` es la barra espaciadora)',
    '- `<leader>hh`: Muestra/Oculta esta ventana de ayuda.', '- `<leader>e`: Abre/Cierra el explorador de archivos (NvimTree).',
    '- `<leader>ff`: Buscar archivos en el proyecto (Telescope).', '- `<leader>fg`: Buscar texto en todos los archivos (Telescope).',
    '- `<leader>fb`: Ver y cambiar entre buffers (archivos abiertos).', '- `<leader>w`: Guardar archivo.', '- `<leader>q`: Cerrar ventana.',
    '- `<leader>cc`: Abrir chat con Copilot.', '',
    '### Depuración con DAP (Debugger)',
    '**Lenguajes Soportados**: C, C++, Python, Go, Rust, JavaScript/TypeScript (Node.js).',
    '**Flujo de trabajo general:**',
    '1. Abre el archivo que quieres depurar.',
    '2. Pon breakpoints con `<leader>db`.',
    '3. Inicia la sesión con `<F5>`.',
    '   - Para C/C++/Rust: Te pedirá la ruta al ejecutable compilado con `-g`.',
    '   - Para Python/JS/Go: Se ejecutará el archivo actual directamente.',
    '4. Controla el flujo con `<F10>` (saltar), `<F11>` (entrar), `<F12>` (salir).',
    '', '### Gestión de Lenguajes',
    '- Usa `:Mason` para instalar, desinstalar o actualizar LSPs y Debuggers.',
    '', '---', '', '## Guía Rápida de VIM',
    '### Modos',
    '- **Modo Normal**: El modo por defecto para moverse y ejecutar comandos. Pulsa `<Esc>` para volver siempre aquí.',
    '- **Modo Inserción**: Para escribir texto. Entra con `i`, `a`, `o`.',
    '- **Modo Visual**: Para seleccionar texto. Entra con `v`, `V`, `Ctrl-v`.', '',
    '### La Gramática de Vim: `operador + [número] + movimiento`',
    '- `d` (delete) -> `d3w` (borra 3 palabras)', '- `c` (change) -> `ci"` (cambia dentro de comillas)',
    '- `y` (yank)   -> `yy` (copia la línea actual)', '- `p` (paste) -> pega lo copiado', '',
    '### Movimientos Esenciales',
    '| Tecla(s)   | Acción                               |', '| :--------- | :----------------------------------- |',
    '| `h, j, k, l` | Izquierda, Abajo, Arriba, Derecha    |', '| `w` / `b`  | Moverse por palabras (adelante/atrás)|',
    '| `0` / `^` / `$` | Inicio / Primer caracter / Final de línea |', '| `gg` / `G` | Inicio / Final del archivo           |',
    '| `Ctrl+o` / `Ctrl+i` | Moverse en el historial de posiciones |', '| `/texto`   | Buscar "texto" hacia adelante        |',
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_content)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")
  local win_width = math.floor(width * 0.8)
  local win_height = math.floor(height * 0.8)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)
  local opts = { style = 'minimal', relative = 'editor', width = win_width, height = win_height, row = row, col = col, border = 'rounded' }
  help_win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
end

-- Dashboard personalizado
function _G.custom_dashboard()
  vim.cmd("enew")
  vim.cmd("setlocal buftype=nofile nobuflisted noswapfile")
  local banner = {
    '▒███████▒ ██▓     ',
    '▒ ▒ ▒ ▄▀░▓██▒     ',
    '░ ▒ ▄▀▒░ ▒██░     ',
    '  ▄▀▒   ░▒██░     ',
    '▒███████▒░██████▒',
    '░▒▒ ▓░▒░▒░ ▒░▓  ░',
    '░░▒ ▒ ░ ▒░ ░ ▒  ░',
    '░ ░ ░ ░ ░  ░ ░    ',
    '  ░ ░      ░  ░',
    '░               ',
  }

  vim.api.nvim_buf_set_lines(0, 0, -1, false, banner)
  local menu = { "", " [F]  ->  Buscar archivo", " [R]  ->  Archivos recientes", " [S]  ->  Configuración de Neovim", " [Q]  ->  Salir de Neovim", "", "Bienvenido Z43L - disfruta de un buen desarrollo", }
  vim.api.nvim_buf_set_lines(0, -1, -1, false, menu)
  map('n', 'F', ':Telescope find_files<CR>', { noremap = true, silent = true, buffer = 0 })
  map('n', 'R', ':Telescope oldfiles<CR>', { noremap = true, silent = true, buffer = 0 })
  map('n', 'S', ':e ~/.config/nvim/init.vim<CR>', { noremap = true, silent = true, buffer = 0 })
  map('n', 'Q', ':qa<CR>', { noremap = true, silent = true, buffer = 0 })
end

-- Ejecutar dashboard si no se abren archivos
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    if vim.fn.argc() == 0 then
      _G.custom_dashboard()
    end
  end,
})

EOF
