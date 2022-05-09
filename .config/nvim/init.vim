set nocompatible
set path+=**

" Nice menu when typing `:find *.py`
set wildmode=longest,list,full
set wildmenu
" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*

set mouse=a
syntax off
filetype plugin indent on
set autoindent
set backspace=indent,eol,start
set complete-=i
set smarttab
set laststatus=2
set ruler
set wildmenu
set scrolloff=1
set sidescrolloff=5
set display+=lastline
set encoding=utf-8
set number
set autoread
set hidden
set history=1000
set tabpagemax=50
set viminfo^=!
set sessionoptions-=options
set number relativenumber " relative line numbers
autocmd Filetype javascript,javascriptreact,typescript,typescriptreact setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype json setlocal ts=2 sts=2 sw=2
autocmd Filetype css setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType bazel setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType starlark,star,bzl setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType elm setlocal ts=4 sts=4 sw=4 expandtab
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd BufRead,BufNewFile *.tmpl set filetype=tmpl
autocmd Filetype tmpl setlocal ts=2 sw=2 expandtab
autocmd Filetype proto setlocal ts=2 sw=2 expandtab
autocmd Filetype markdown setlocal ts=2 sw=2 expandtab
autocmd Filetype mdx setlocal ts=2 sw=2 expandtab
autocmd Filetype zig setlocal ts=4 sw=4 expandtab
set noerrorbells
set novisualbell
set t_vb=
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey
autocmd! GUIEnter * set vb t_vb=
let mapleader = ','
set completeopt-=preview
set completeopt+=longest,menuone,noselect,noinsert
set shortmess+=c   " Shut off completion messages
set belloff+=ctrlg " If Vim beeps during completion
set rtp+=~/bin

lua require("myluamodule")

" fzf
nmap ; :Buffers<CR>
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--info=inline']}), <bang>0)
nmap <Leader>t :Files<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>g :GFiles<CR>
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
nmap <Leader>a :RG<CR>

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

"autocmd VimEnter * colorscheme molokai
let g:rehash256 = 1
 
let g:airline#extensions#tabline#enabled = 1

" Neovim
noremap § <esc>
vnoremap § <esc>
:tnoremap <Esc> <C-\><C-n>
":set shell=/usr/local/bin/zsh
if has('nvim')
  let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif
autocmd FileType gitcommit set bufhidden=delete

" codefmt
" Run Glaive setup after plugins have loaded
autocmd VimEnter * Glaive codefmt rustfmt_options=`['--edition=2018']`
" autocmd VimEnter * Glaive codefmt gofmt_executable='goimports'
augroup autoformat_settings
  " autocmd Filetype mdx AutoFormatBuffer prettier
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  " autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer prettier
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue,javascript,typescript,typescriptreact AutoFormatBuffer prettier
  autocmd FileType starlark AutoFormatBuffer buildifier
augroup END

" Set the filetype based on the file's extension, but only if
" 'filetype' has not already been set
au BufRead,BufNewFile *.star setfiletype starlark
au BufRead,BufNewFile *.mdx setfiletype mdx

" lsp autocomplete
" <C-X><C-O> in insert mode, <C-N> and <C-P> to navigate.
set completeopt=menuone,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_enable_auto_popup = 1

" lsp formatting
autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 3000)
autocmd BufWritePre *.zig lua vim.lsp.buf.formatting_sync(nil, 3000)

inoremap <silent><expr> <CR>      compe#confirm('<CR>')
