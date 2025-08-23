" =============================================================================
" SECCIÓN 0: INSTALACIÓN AUTOMÁTICA (SOLO SE EJECUTA UNA VEZ)
" =============================================================================

" Ruta al archivo que usaremos como bandera para saber si ya se instaló todo.
let g:init_flag = expand('~/.vim/.initialized-z43l')

" Función principal de instalación y verificación
function! s:CheckAndInstallDependencies()
  " --- Paso 1: Instalar vim-plug si no existe ---
  let plug_path = expand('~/.vim/autoload/plug.vim')
  if empty(glob(plug_path))
    echo "Instalando vim-plug..."
    silent !curl -fLo plug_path --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    execute 'source ' . plug_path
  endif

  " --- Paso 2: Instalar todos los plugins ---
  echo "Instalando plugins con vim-plug... (puede tardar un momento)"
  PlugInstall --sync

  " --- Paso 3: Instalar extensiones de CoC ---
  echo "Instalando extensiones de CoC (LSPs)..."
  CocInstall -sync coc-json coc-tsserver coc-pyright coc-go coc-rust-analyzer coc-clangd coc-html coc-css coc-docker coc-sh

  " --- Paso 4: Verificar dependencias del sistema ---
  echo "Verificando dependencias del sistema..."
  let s:missing_deps = []
  if !executable('fzf')
    call add(s:missing_deps, 'fzf -> sudo apt install fzf  |  brew install fzf')
  endif
  if !executable('rg')
    call add(s:missing_deps, 'ripgrep -> sudo apt install ripgrep  |  brew install ripgrep')
  endif
  if !executable('node')
    call add(s:missing_deps, 'nodejs -> sudo apt install nodejs npm  |  brew install node')
  endif

  " --- Paso 5: Verificar adaptadores de debugger ---
  echo "Verificando adaptadores de debugger..."
  if !executable('python3') || system('python3 -m debugpy.adapter --version') !~# 'debugpy'
      call add(s:missing_deps, 'debugpy (Python) -> python3 -m pip install -U debugpy')
  endif
  if !executable('js-debug-adapter')
      call add(s:missing_deps, 'js-debug-adapter (NodeJS) -> npm install -g vscode-js-debug')
  endif
  if !executable('dlv')
      call add(s:missing_deps, 'delve (Go) -> go install github.com/go-delve/delve/cmd/dlv@latest')
  endif
  if !executable('codelldb') && !filereadable(expand('/home/davmoren/.local/bin/codelldb'))
      call add(s:missing_deps, 'codelldb (C++/Rust) -> Descargar desde GitHub y poner en PATH')
  endif

  " --- Paso 6: Mostrar resumen y crear bandera ---
  if empty(s:missing_deps)
    echom "¡Instalación completada! Todas las dependencias están presentes."
  else
    echohl WarningMsg
    echo "==================== ACCIÓN REQUERIDA ===================="
    echo "Faltan las siguientes dependencias. Por favor, instálalas desde tu terminal:"
    for dep in s:missing_deps
      echo '- ' . dep
    endfor
    echo "Después de instalar, reinicia Vim."
    echo "=========================================================="
    echohl None
  endif

  " Creamos el archivo bandera para que esto no se vuelva a ejecutar
  call writefile(["Instalación completada en " . strftime("%c")], g:init_flag)
endfunction

" Autocomando que dispara la instalación solo si el archivo bandera no existe
autocmd VimEnter * if !filereadable(g:init_flag) | call s:CheckAndInstallDependencies() | endif


" =============================================================================
" SECCIÓN 1: VIM-PLUG Y LISTA DE PLUGINS
" =============================================================================
call plug#begin('~/.vim/plugged')

" ===== UI y Apariencia =====
Plug 'dracula/vim' " ✅ NUEVO TEMA: Dracula
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" ===== LSP y Autocompletado (CoC) =====
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ===== Búsqueda (FZF) =====
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" ===== Utilidades y Core =====
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'lewis6991/gitsigns.nvim'
Plug 'github/copilot.vim'

" ===== Debugger (Vimspector) =====
Plug 'puremourning/vimspector'

" ===== Herramientas Específicas =====
Plug 'mattn/emmet-vim'
Plug '42Paris/42header'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install' }
call plug#end()


" =============================================================================
" SECCIÓN 2: OPCIONES GENERALES Y CONFIGURACIÓN DE PLUGINS
" =============================================================================
set number
set relativenumber
set mouse=a
set splitright
set splitbelow
set nowrap
set termguicolors
set background=dark " Importante para temas oscuros
set clipboard+=unnamedplus
set hidden " Permite cambiar de buffer sin guardar

" Opciones para Airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='dracula' " Sincronizamos el tema de Airline

" Opciones para NERDTree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

" Opciones generales
let mapleader = " "
let g:user42 = 'davmoren'
let g:mail42 = 'davmoren@student.42urduliz.com'

" Tema de color
if (has("termguicolors"))
  set termguicolors
endif
colorscheme dracula " ✅ NUEVO TEMA: Dracula

" Configuración del portapapeles para WSL
if executable('win32yank.exe')
  let g:clipboard = {
  \   'name': 'win32yank-wsl',
  \   'copy': {
  \     '+': 'win32yank.exe -i --crlf',
  \     '*': 'win32yank.exe -i --crlf',
  \   },
  \   'paste': {
  \     '+': 'win32yank.exe -o --lf',
  \     '*': 'win32yank.exe -o --lf',
  \   },
  \   'cache_enabled': 1,
  \ }
endif

" =============================================================================
" SECCIÓN 3: CONFIGURACIÓN DEL DEBUGGER (VIMSPECTOR)
" =============================================================================
" Esto reemplaza el archivo ~/.vimspector.json
let g:vimspector_adapters = {
\  'CodeLLDB': {
\    'command': ['/home/davmoren/.local/bin/codelldb', '--port', '${port}'],
\    'name': 'codelldb'
\  },
\  'Python3': {
\    'command': ['python3', '-m', 'debugpy.adapter'],
\    'name': 'python'
\  },
\  'Go': {
\    'command': ['dlv', 'dap'],
\    'name': 'go'
\  },
\  'NodeJS': {
\    'command': ['js-debug-adapter'],
\    'name': 'pwa-node'
\  }
\}


" =============================================================================
" SECCIÓN 4: VENTANAS DE AYUDA PERSONALIZADAS
" =============================================================================

" ✅ CORRECCIÓN DEFINITIVA: Usamos un "filtro de teclas" para cerrar la ventana,
" que es el método más compatible y robusto.
function! s:PopupCloseFilter(id, key)
  if a:key == 'q' || a:key == "\<Esc>"
    call popup_close(a:id)
    return 1 " La tecla ha sido gestionada
  endif
  return 0 " La tecla no ha sido gestionada
endfunction

" --- Ventana 1: Guía de Uso y Atajos ---
let s:help_win_id = -1
function! s:ToggleHelpWindow()
  if s:help_win_id != -1 && popup_is_hidden(s:help_win_id) == 0
    call popup_close(s:help_win_id)
    let s:help_win_id = -1
    return
  endif
  let s:help_content = [
    \ '# 📜 Guía Profesional de mi Entorno Vim', '', '## 1. Mi Configuración (.vimrc)', '### Plugins Clave y su Función',
    \ '| Plugin      | Función                                             |', '| :---------- | :-------------------------------------------------- |',
    \ '| `coc.nvim`  | Motor de autocompletado, LSP y diagnósticos (IDE)   |', '| `fzf.vim`   | Buscador "fuzzy" súper rápido para todo             |',
    \ '| `nerdtree`  | Explorador de archivos en panel lateral             |', '| `vim-airline`| Barra de estado y de pestañas                       |',
    \ '| `vimspector`| Soporte para depuración multi-lenguaje (Debugger)   |', '', '### Atajos de Teclado (`<leader>` es la barra espaciadora)',
    \ '#### Archivos y Búsqueda', '- `<leader>e`: Abrir/Cerrar explorador de archivos (`nerdtree`)', '- `<leader>ff`: Buscar archivos por nombre (`fzf`)',
    \ '- `<leader>fg`: Buscar archivos por contenido (`fzf` + `grep/rg`)', '- `<leader>fb`: Buscar en buffers abiertos (`fzf`)',
    \ '#### Funcionalidad IDE (CoC)', '- `gd`: Ir a la **D**efinición de la variable/función', '- `gy`: Ir al **T**ipo de la definición',
    \ '- `gr`: Ver las **R**eferencias', '- `K`: Mostrar documentación flotante', '- `<leader>rn`: **R**e**n**ombrar símbolo en todo el proyecto',
    \ '- `<leader>ca`: Ver y aplicar **A**cciones de **C**ódigo (ej: auto-importar)',
    \ '#### Depuración (Vimspector)', '- `<F5>`: Iniciar y **C**ontinuar la depuración', '- `<F10>`: **P**aso por encima (Step Over)',
    \ '- `<F11>`: **E**ntrar en (Step Into)', '- `<F12>`: **S**alir de (Step Out)', '- `<leader>db`: Poner/Quitar **B**reakpoint', '',
    \ '## 2. Técnicas Avanzadas de Vim', '### La Gramática de Vim: Text Objects',
    \ 'Usa `i` (inner/dentro) o `a` (around/alrededor).', '- `ci"`: **C**ambiar **d**entro de las comillas.',
    \ '- `da(`: **B**orrar **a**lrededor de los paréntesis (incluyéndolos).', '- `yiw`: **C**opiar la **p**alabra actual.',
    \ '- `vip`: **S**eleccionar el **p**árrafo actual.', '', '### Macros: Automatiza Tareas Repetitivas',
    \ '1. `q` + `letra` (ej: `qa`): Empieza a grabar.', '2. Realiza tus acciones.', '3. `q`: Detén la grabación.',
    \ '4. `@a`: Ejecuta la macro una vez.', '5. `10@a`: Ejecuta la macro 10 veces.', '',
    \ '### El Comando Global: `:g`', 'Ejecuta un comando en todas las líneas que coincidan con un patrón.',
    \ 'Formato: `:g/patrón/comando`', '- `:g/TODO/d`: Borra todas las líneas que contienen "TODO".',
    \ '- `:g!/^\s*$/d`: Borra todas las líneas que NO están vacías.',
    \ ]
  let s:win_options = { 'title': ' Ayuda Z43L ', 'border': [], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], 'filter': function('s:PopupCloseFilter'), 'wrap': 1, 'highlight': 'NormalFloat' }
  if has('popupwin')
    let s:help_win_id = popup_create(s:help_content, s:win_options)
  else
    vnew | setlocal buftype=nofile bufhidden=wipe noswapfile | call setline(1, s:help_content)
  endif
endfunction

" --- Ventana 2: Guía de Instalación ---
let s:install_help_win_id = -1
function! s:ToggleInstallHelpWindow()
  if s:install_help_win_id != -1 && popup_is_hidden(s:install_help_win_id) == 0
    call popup_close(s:install_help_win_id)
    let s:install_help_win_id = -1
    return
  endif
  let s:install_help_content = [
    \ '# ⚙️ Guía de Instalación y Debuggers',
    \ '',
    \ '## 1. Pasos de Instalación',
    \ 'Sigue estos pasos en orden para que la configuración funcione.',
    \ '',
    \ '### Paso 1: Instalar vim-plug y Plugins',
    \ '1. Guarda este archivo `.vimrc` en tu home (`~/`).',
    \ '2. Abre Vim. `vim-plug` debería instalarse automáticamente.',
    \ '3. El script ejecutará `:PlugInstall` por ti la primera vez.',
    \ '',
    \ '### Paso 2: Instalar Dependencias del Sistema',
    \ 'El script de auto-instalación te avisará si falta algo de esto:',
    \ '- **fzf** (buscador): `sudo apt install fzf` o `brew install fzf`',
    \ '- **ripgrep** (búsqueda rápida): `sudo apt install ripgrep` o `brew install ripgrep`',
    \ '- **nodejs y npm**: `sudo apt install nodejs npm` o `brew install node`',
    \ '',
    \ '### Paso 3: Instalar LSPs con CoC',
    \ 'El script ejecutará `:CocInstall` por ti la primera vez.',
    \ '',
    \ '### Paso 4: Instalar Adaptadores de Debugger',
    \ 'El script te avisará si falta algo. Ejecuta estos comandos en tu terminal:',
    \ '- **Python**: `python3 -m pip install -U debugpy`',
    \ '- **Node.js**: `npm install -g vscode-js-debug`',
    \ '- **Go**: `go install github.com/go-delve/delve/cmd/dlv@latest`',
    \ '- **C++/Rust**: Descarga `codelldb` desde GitHub, descomprímelo y mueve el binario a `~/.local/bin/` (o a la ruta de la SECCIÓN 3).',
    \ '',
    \ '## 2. Plantillas para Vimspector (`.vimspector.json`)',
    \ 'Crea este archivo en la raíz de tu proyecto.',
    \ '',
    \ '### Plantilla para Python',
    \ '```json',
    \ '{',
    \ '  "configurations": {',
    \ '    "launch": {',
    \ '      "adapter": "Python3",',
    \ '      "configuration": { "request": "launch", "type": "python", "program": "${file}", "console": "integratedTerminal" }',
    \ '    }',
    \ '  }',
    \ '}',
    \ '```',
    \ '',
    \ '### Plantilla para C/C++/Rust',
    \ '```json',
    \ '{',
    \ '  "configurations": {',
    \ '    "launch": {',
    \ '      "adapter": "CodeLLDB",',
    \ '      "configuration": { "request": "launch", "program": "${workspaceRoot}/a.out" }',
    \ '    }',
    \ '  }',
    \ '}',
    \ '```',
    \ '*Recuerda compilar con `-g` y cambiar `a.out` por el nombre de tu ejecutable.*',
    \ '',
    \ '### Plantilla para Go',
    \ '```json',
    \ '{',
    \ '  "configurations": {',
    \ '    "launch": {',
    \ '      "adapter": "Go",',
    \ '      "configuration": { "request": "launch", "program": "${fileDirname}" }',
    \ '    }',
    \ '  }',
    \ '}',
    \ '```',
    \ '',
    \ '### Plantilla para Node.js',
    \ '```json',
    \ '{',
    \ '  "configurations": {',
    \ '    "Launch current file": {',
    \ '      "adapter": "NodeJS",',
    \ '      "configuration": { "request": "launch", "program": "${file}", "stopOnEntry": false }',
    \ '    }',
    \ '  }',
    \ '}',
    \ '```',
    \ ]
  let s:win_options = { 'title': ' Guía de Instalación ', 'border': [], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], 'filter': function('s:PopupCloseFilter'), 'wrap': 1, 'highlight': 'NormalFloat' }
  if has('popupwin')
    let s:install_help_win_id = popup_create(s:install_help_content, s:win_options)
  else
    vnew | setlocal buftype=nofile bufhidden=wipe noswapfile | call setline(1, s:install_help_content)
  endif
endfunction


" =============================================================================
" SECCIÓN 5: ATAJOS DE TECLADO
" =============================================================================

" Atajos para las ventanas de ayuda
nnoremap <silent> <leader>hh :call <SID>ToggleHelpWindow()<CR>
nnoremap <silent> <leader>hi :call <SID>ToggleInstallHelpWindow()<CR>

" Explorador de archivos
nnoremap <leader>e :NERDTreeToggle<CR>

" Búsqueda con FZF
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fb :Buffers<CR>

" Atajos generales
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Navegación de ventanas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Depuración con Vimspector
nnoremap <F5> <Plug>vimspectorContinue
nnoremap <F10> <Plug>vimspectorStepOver
nnoremap <F11> <Plug>vimspectorStepInto
nnoremap <F12> <Plug>vimspectorStepOut
nnoremap <leader>db <Plug>vimspectorToggleBreakpoint
nnoremap <leader>dr :VimspectorEval

" Copilot Chat
nnoremap <leader>cc :CopilotChat<CR>
xnoremap <leader>cs :CopilotChatVisual<CR>

" =============================================================================
" SECCIÓN 6: CONFIGURACIÓN DE COC (LSP Y AUTOCOMPLETADO)
" =============================================================================

" Atajos para funcionalidad de IDE con CoC
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nnoremap <silent> <leader>rn <Plug>(coc-rename)
nnoremap <silent> <leader>ca <Plug>(coc-codeaction-cursor)

" Usa <tab> para navegar en el menú de completado
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space()
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
