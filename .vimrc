set nocompatible " This must be first, because it changes other options as a side effect.

" Disable useless widgets
" Widgets do nothing but distract you
" Disable them to create more screen real estate
" and to make GUI and terminal experience more similar
:set guioptions-=m  "remove menu bar
:set guioptions-=T  "remove toolbar
:set guioptions-=r  "remove right-hand scroll bar
:set guioptions-=L  "remove left-hand scroll bar

" Default font on Linux is nice, but if you want to use another one
" Here is how you do it. Of course, you have to make sure the font
" is installed first.
" set guifont=Source_Code_Pro:h12
" set guifont=Anonymous_Pro:h10

" Essential things

set hidden " Without this, every buffer is closed when another one is opened
set nowrap
syntax on
set background=dark
set t_Co=256
set smartindent
set autoindent
set copyindent
set shiftwidth=2
set shiftround
set backspace=indent,eol,start
set smarttab
set expandtab
set showmatch
set smartcase
set hlsearch
set incsearch
set clipboard=unnamedplus
set foldmethod=manual
set mouse=a
set spelllang=en_us
set spell " Detect spelling mistakes in text mode buffers and in comments
set laststatus=2 " Always show the status line
set title " Display the path in the window title
set splitbelow " Default location where splits should occur
set encoding=utf-8
set number " Comment this out if you do not want line numbers on by default

filetype plugin indent on

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

" Remember, and automatically restore  the location of point in buffers
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

if has("folding")
  function! UnfoldCur()
    if !&foldenable
      return
    endif
    let cl = line(".")
    if cl <= 1
      return
    endif
    let cf  = foldlevel(cl)
    let uf  = foldlevel(cl - 1)
    let min = (cf > uf ? uf : cf)
    if min
      execute "normal!" min . "zo"
      return 1
    endif
  endfunction
endif

augroup resCur
  autocmd!
  if has("folding")
    autocmd BufWinEnter * if ResCur() | call UnfoldCur() | endif
  else
    autocmd BufWinEnter * call ResCur()
  endif
augroup END

" Key mappings
let g:mapleader = ","
let g:localmapleader = "\\"
nnoremap <S-right> :tabn<CR>
nnoremap <S-left> :tabp<CR>
" remove last search highlight
nnoremap <C-l> :nohlsearch<CR><C-l>

" Initialize Vim Plug
call plug#begin($HOME.'/.vim/plugins/plugged')

" Plugins that are universally useful regardless of which programming language
" you are working with
Plug 'tpope/vim-fugitive'
Plug 'jreybert/vimagit'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'scrooloose/syntastic'
Plug 'junegunn/vim-easy-align'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/paredit.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'akmassey/vim-codeschool'
Plug 'kien/ctrlp.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'int3/vim-extradite'

" Programming language specific plugins
Plug 'maksimr/vim-jsbeautify', { 'do' : 'git submodule update --init --recursive' }
Plug 'elzr/vim-json'
Plug 'othree/yajs.vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'cakebaker/scss-syntax.vim'
Plug 'othree/html5.vim'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --tern-completer' }
Plug 'marijnh/tern_for_vim', { 'do' : 'npm install' }
Plug 'moll/vim-node'
Plug 'syngan/vim-vimlint'
Plug 'ynkdir/vim-vimlparser'

call plug#end()

" Configure plugins

" Finding files, switching buffers, easy mode
let g:ctrlp_map = ''
nnoremap <leader>f :CtrlP<CR>
nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>r :CtrlPMRU<CR>
" Ignore files that are in .gitignore
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

if has('gui_running')
  color solarized
  call togglebg#map("<F5>")
endif

" Airline configuration
if has('gui_running')
  let g:airline_theme = "solarized"
endif

let g:airline#extensions#tabline#enabled = 0
let g:airline#extensions#tabline#fnamemod = ':t'

" Disable filename in the status line, it is already shown at the top
let g:airline_section_c = '%t'

let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" Do not show stupid LN symbol
let g:airline_symbols.linenr = ''

" Disable word counting
let g:airline#extensions#wordcount#enabled = 0

" Git gutter settings
" On windows realtime does not work
" also enable the line highlights
let g:gitgutter_realtime = 1

let g:gitgutter_sign_column_always = 1
let g:gitgutter_highlight_lines = 0

" Follow symlinks when opening a file {{{
" NOTE: this happens with directory symlinks anyway (due to Vim's chdir/getcwd
"       magic when getting filenames).
" Sources:
"  - https://github.com/tpope/vim-fugitive/issues/147#issuecomment-7572351
"  - http://www.reddit.com/r/vim/comments/yhsn6/is_it_possible_to_work_around_the_symlink_bug/c5w91qw
function! MyFollowSymlink(...)
  if exists('w:no_resolve_symlink') && w:no_resolve_symlink
    return
  endif
  let fname = a:0 ? a:1 : expand('%')
  if fname =~ '^\w\+:/'
    " Do not mess with 'fugitive://' etc.
    return
  endif
  let fname = simplify(fname)

  let resolvedfile = resolve(fname)
  if resolvedfile == fname
    return
  endif
  let resolvedfile = fnameescape(resolvedfile)
  let sshm = &shm
  set shortmess+=A  " silence ATTENTION message about swap file (would get displayed twice)
  exec 'file ' . resolvedfile
  let &shm=sshm

  " Re-init fugitive.
  call fugitive#detect(resolvedfile)
  if &modifiable
    " Only display a note when editing a file, especially not for `:help`.
    redraw  " Redraw now, to avoid hit-enter prompt.
    echomsg 'Resolved symlink: =>' resolvedfile
  endif
endfunction
command! FollowSymlink call MyFollowSymlink()
command! ToggleFollowSymlink let w:no_resolve_symlink = !get(w:, 'no_resolve_symlink', 0) | echo "w:no_resolve_symlink =>" w:no_resolve_symlink
au BufReadPost * nested call MyFollowSymlink(expand('%'))

" you can use [c and ]c to navigate between the hunks in the file

" ViMagit is a really nice alternative in certain cases
nnoremap <leader>gf :MagitOnly<CR>

" zo and zc can be used to open and close folds inside vimagit buffer
" or in fact anywhere else you have folds, in normal mode

" fugitive git bindings
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit -v -q<CR>
nnoremap <leader>gt :Gcommit -v -q %:p<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gw :Gwrite<CR><CR>
nnoremap <leader>gl :Extradite<CR>
nnoremap <leader>gll :silent! Glog<CR>:bot copen<CR>
nnoremap <leader>gp :Ggrep<Space>
nnoremap <leader>gm :Gmove<Space>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Git push<CR>
nnoremap <leader>gpl :Git pull<CR>

" EditorConfig
" to avoid issues with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

"" Syntax checkers

let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1
let g:syntastic_php_checkers=['php', 'phpcs', 'phpmd']
let g:syntastic_html_checkers=['tidy']
let g:syntastic_vim_checkers=['vimlint']
let g:syntastic_json_checkers=['jsonlint']
let g:syntastic_yaml_checkers=['js-yaml']
let g:syntastic_scss_checkers=['scss-lint']
let g:syntastic_css_checkers=['csslint']
let g:syntastic_handlebars_checkers=['handlebars']
let g:syntastic_tpl_checkers=['handlebars']
let g:syntastic_javascript_checkers=['jshint', 'eslint']

" EasyAlign

" select paragraph and start easyalign on the left
nnoremap <leader>a vip<Plug>(EasyAlign)<cr>

" Start interactive align to the right
vmap <leader>a <Plug>(EasyAlign)<cr><right>

let g:easy_align_ignore_groups = ['Comment']

" JsBeautify

" format selection
autocmd FileType javascript vnoremap <buffer>  <c-f> :call RangeJsBeautify()<cr>
autocmd FileType json vnoremap <buffer>  <c-f> :call RangeJsonBeautify()<cr>
autocmd FileType html vnoremap <buffer> <c-f> :call RangeHtmlBeautify()<cr>
autocmd FileType css vnoremap <buffer> <c-f> :call RangeCSSBeautify()<cr>

" format the whole file
autocmd FileType javascript nnoremap <buffer>  <c-f> :call JsBeautify()<cr>
autocmd FileType json nnoremap <buffer>  <c-f> :call JsonBeautify()<cr>
autocmd FileType html nnoremap <buffer> <c-f> :call HtmlBeautify()<cr>
autocmd FileType css nnoremap <buffer> <c-f> :call CSSBeautify()<cr>

" YankStack

nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

" Javascript libraries syntax

let g:used_javascript_libs = 'jquery,underscore,requirejs,chai,handlebars'

" Force filetype
autocmd BufRead,BufNewFile .eslintrc setfiletype json
autocmd BufRead,BufNewFile .jshintrc setfiletype json

" Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Automatically remove trailing whitespace on save
autocmd BufWritePre * FixWhitespace

