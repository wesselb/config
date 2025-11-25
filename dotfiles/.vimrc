set nocompatible    " Enable vim.
set encoding=utf-8  " Set file encoding to utf-8.

" Must load this in the beginning of the script!
if !empty($VIM_PYTHON3)
    let g:python3_host_prog = $VIM_PYTHON3
endif

" Kill any deprecation warnings.
if has('python3')
    silent! python3 1
endif

filetype off  " Temporarily required for Vundle.

set rtp+=~/.vim/bundle/Vundle.vim

" Load Vundle plugins.
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'L9'                               " More utility
Plugin 'junegunn/fzf'                     " Fuzzy finder
Plugin 'junegunn/fzf.vim'                 " Fuzzy finder
Plugin 'w0rp/ale'                         " Linter
Plugin 'davidhalter/jedi-vim'             " Autocompletion for Python
Plugin 'powerline/powerline'              " Powerline
Plugin 'joonty/vim-do'                    " Run shell commands asyncly.
Plugin 'preservim/nerdtree'               " Browser

Plugin 'tpope/vim-sensible'               " Sensible defaults
Plugin 'altercation/vim-colors-solarized' " Solarized theme

Plugin 'tpope/vim-surround'               " Surround motion
Plugin 'Tabular'                          " Align text.
Plugin 'vim-scripts/tComment'             " Comment text.

Plugin 'SirVer/ultisnips'                 " Snippets
Plugin 'honza/vim-snippets'

Plugin 'Vimjas/vim-python-pep8-indent'    " Proper indentation for Python
Plugin 'plasticboy/vim-markdown'          " Markdown support
Plugin 'lervag/vimtex'                    " LaTeX support

Plugin 'axvr/zepl.vim'                    " REPL support

call vundle#end()

""
"" General
""

let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" Theme
set t_Co=256
colorscheme solarized
set guifont=Source\ Code\ Pro\ for\ Powerline:h13
set nu
set background=light
set fileformat=unix

" Autoindentation and plugins
filetype plugin indent on

" Expand tabs.
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" Text width
set cc=79
set textwidth=0
au BufNewFile,BufRead *.py set cc=88

" Automatic indentation
set autoindent

noremap j gj
noremap k gk

" Incremental search
set incsearch
set ignorecase
set smartcase
set hlsearch
nmap <Leader>s :nohlsearch<CR>

" Scrolling using mouse
set mouse=a

" Miscellaneous maps
nmap <Leader>q :q<CR>
nmap <Leader>x :w<CR>:!chmod u+x % && ./%

" Maps that mimc Spacemacs shortcuts
nmap <Leader>fs :w<CR>
nmap <Leader>w <C-w>
nmap <Leader>wd <C-w>q
nmap <Leader>w- :sp<CR>
nmap <Leader>w/ :vsp<CR>

""
"" fzf
""

let g:fzf_command_prefix = 'Fzf'
nmap <C-p> :FzfFiles<CR>
" nmap <silent> <C-p> :call fzf#run({
"     \ 'source': '
"         \ python /Users/wessel/Dropbox/Projects/Development/Vim/list_files.py . 
"         \ --type py jl tex md 
"         \ --ignore-dir venv',
"     \ 'sink': 'e',
"     \ 'down': '30%'
"     \ })<CR>
nmap <C-b> :FzfBuffers<CR>

" Maps
nmap <Leader>l :lclose<CR>

""
"" NerdTree
""

au VimEnter *  NERDTree | wincmd p
" Close if NERDTree is the last buffer. Source:
"     https://stackoverflow.com/a/4319165
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""
"" tComment
""

nmap <Leader>c :TComment<CR>
vmap <Leader>c :TComment<CR>

""
"" Tabular
""

nmap <Leader>a= :Tabularize<Space>/=/l1c1l0<CR>
vmap <Leader>a= :Tabularize<Space>/=/l1c1l0<CR>
nmap <Leader>a: :Tabularize<Space>/:/r0c1l0<CR>
vmap <Leader>a: :Tabularize<Space>/:/r0c1l0<CR>
nmap <Leader>a- :Tabularize<Space>/->/l1c1l0<CR>
vmap <Leader>a- :Tabularize<Space>/->/l1c1l0<CR>
nmap <Leader>a" :Tabularize<Space>/"/l1c1l0<CR>
vmap <Leader>a" :Tabularize<Space>/"/l1c1l0<CR>


""
"" Python
""

" ALE
let g:ale_fixers = {
  \   'python': [
  \       'ruff',
  \       'ruff_format',
  \   ],
  \   'tex': []
  \}
let g:ale_fix_on_save = 1
let g:ale_linters = {
  \   'python': [
  \       'ruff'
  \   ],
  \   'tex': []
  \}
let g:ale_python_ruff_options = '--select I'  " Always sort imports.
let g:ale_history_enabled=1
nmap <Leader><Leader>f :ALEFix<CR>

" Folding
let g:SimpylFold_fold_docstring = 0

""
"" Run
""

let g:run_cmd = "python %"

function! Run()
    let parsed_cmd = substitute(g:run_cmd, "%", expand("%"), "")
    exec "DoQuietly tmux send-keys -t right '" . parsed_cmd . "' Enter"
    echom "Executed \"" . parsed_cmd . "\""
endfunction

nmap <Leader>r :call<Space>Run()<CR>

""
"" Markdown
""

let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_conceal_code_blocks = 0
set nofoldenable

""
"" LaTeX
""

let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_sync = 1
let g:vimtex_view_skim_activate = 1

let g:vimtex_compiler_latexmk = {
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 0,
    \ 'executable' : 'latexmk',
    \ 'hooks' : [],
    \ 'options' : [
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}

autocmd FileType tex nmap <buffer> <Leader>b :w<CR>:VimtexCompile<CR>

function! InsertReference(output)
    let output = split(a:output, " | ")[0]
    execute "normal! a" . output
    startinsert!
endfunction

" nmap <silent> <Leader>lc :call fzf#run({
"     \ 'source': '/Users/wessel/Dropbox/Projects/PyLib/Catalogue/venv/bin/python /Users/wessel/Dropbox/Projects/PyLib/Catalogue/list_fzf.py',
"     \ 'sink': function('InsertReference'),
"     \ })<CR>

""
"" UltiSnips
""

let g:UltiSnipsSnippetDirectories = [$HOME . '/.vim/UltiSnips']

function! Dedent(timer)
    execute "normal! <<a"
    startinsert!
endfunction

syntax on
