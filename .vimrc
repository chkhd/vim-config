" Disable useless widgets
:set guioptions-=m  "remove menu bar
:set guioptions-=T  "remove toolbar
:set guioptions-=r  "remove right-hand scroll bar
:set guioptions-=L  "remove left-hand scroll bar

" Use a better font
" set guifont=Source_Code_Pro:h12
" set guifont=Anonymous_Pro:h10

" Essential things, like making sure we don't run in compatible mode
set nocompatible
set wrap
syntax on
set background=light
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
set nospell
set laststatus=2
set title
set splitbelow
set encoding=utf-8
" Uncomment the line below if you want line numbers
" set number

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
Plug 'bling/vim-airline'
Plug 'altercation/vim-colors-solarized'
Plug 'Shougo/vimproc.vim'
Plug 'Shougo/neomru.vim'
Plug 'Shougo/unite.vim'

" Programming language specific plugins
Plug 'maksimr/vim-jsbeautify', { 'do' : 'git submodule update --init --recursive' }
Plug 'elzr/vim-json'
Plug 'othree/yajs.vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'cakebaker/scss-syntax.vim'
Plug 'othree/html5.vim'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
Plug 'marijnh/tern_for_vim', { 'do' : 'npm install' }
Plug 'moll/vim-node'
Plug 'syngan/vim-vimlint'
Plug 'ynkdir/vim-vimlparser'

call plug#end()

" Configure plugins

" Make searching and switching easy
nnoremap <silent> <Leader>m :Unite -buffer-name=recent -winheight=10 file_mru<cr>
nnoremap <Leader>b :Unite -buffer-name=buffers -winheight=10 buffer<cr>
nnoremap <Leader>f :Unite grep:.<cr>

" CtrlP-like search
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
call unite#custom#source('file_rec/async','sorters','sorter_rank')

" replacing unite with ctrl-p
nnoremap <silent> <C-p> :Unite -start-insert -buffer-name=files -winheight=10 file_rec/async<cr>

" airline configuration
let g:airline#extensions#tabline#enabled = 0
let g:airline#extensions#tabline#fnamemod = ':t'

" Disable filename in the status line, it is already shown at the top
let g:airline_section_c = '%t'

let g:airline_powerline_fonts = 0
let g:airline_left_sep=''
let g:airline_right_sep=''

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
let g:gitgutter_realtime = 0
let g:gitgutter_sign_column_always = 1
let g:gitgutter_highlight_lines = 1

" fugitive git bindings
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit -v -q<CR>
nnoremap <leader>gt :Gcommit -v -q %:p<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gw :Gwrite<CR><CR>
nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <leader>gp :Ggrep<Space>
nnoremap <leader>gm :Gmove<Space>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Dispatch! git push<CR>
nnoremap <leader>gpl :Dispatch! git pull<CR>

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

" Apply Color scheme
" color solarized

" Make switching light/dark theme easy
call togglebg#map("<F5>")

" Force filetype
autocmd BufRead,BufNewFile .eslintrc setfiletype json
autocmd BufRead,BufNewFile .jshintrc setfiletype json

" Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif


