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
autocmd Filetype javascript,javascriptreact,typescriptreact setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype json setlocal ts=2 sts=2 sw=2
autocmd Filetype css setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType bazel setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType star,bzl setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType elm setlocal ts=4 sts=4 sw=4 expandtab
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd BufRead,BufNewFile *.tmpl set filetype=tmpl
autocmd Filetype tmpl setlocal ts=2 sw=2 expandtab
autocmd Filetype proto setlocal ts=2 sw=2 expandtab
autocmd Filetype markdown setlocal ts=2 sw=2 expandtab
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

" fzf
set rtp+=/usr/local/opt/fzf
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

autocmd VimEnter * colorscheme molokai
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
autocmd VimEnter * Glaive codefmt gofmt_executable='goimports'
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer prettier
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue,javascript,typescriptreact AutoFormatBuffer prettier
augroup END

" lsp
" primagen config
" https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/plugin/lsp.vim
set completeopt=menuone,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

fun! LspLocationList()
    " lua vim.lsp.diagnostic.set_loclist({open_loclist = false})
endfun

nnoremap <leader>vd :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>vi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>vsh :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>vrr :lua vim.lsp.buf.references()<CR>
nnoremap <leader>vrn :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>vh :lua vim.lsp.buf.hover()<CR>
nnoremap <leader>vca :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>vsd :lua vim.lsp.diagnostic.show_line_diagnostics(); vim.lsp.util.show_line_diagnostics()<CR>
nnoremap <leader>vn :lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <leader>vll :call LspLocationList()<CR>

augroup THE_PRIMEAGEN_LSP
    autocmd!
    autocmd! BufWrite,BufEnter,InsertLeave * :call LspLocationList()
augroup END

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 1
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.vsnip = v:true

inoremap <silent><expr> <CR>      compe#confirm('<CR>')

" coc.nvim
"set nobackup
"set nowritebackup
""set cmdheight=2
"set updatetime=300 " Better diagnostic messages
"" Use tab for trigger completion with characters ahead and navigate.
"" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
"inoremap <silent><expr> <TAB>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"
"function! s:check_back_space() abort
"  let col = col('.') - 1
"  return !col || getline('.')[col - 1]  =~# '\s'
"endfunction
"
"" Use <c-space> to trigger completion.
"inoremap <silent><expr> <c-space> coc#refresh()
"
"" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
"" Coc only does snippet and additional edit on confirm.
"inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"" Or use `complete_info` if your vim support it, like:
"" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
"
"" Use `[g` and `]g` to navigate diagnostics
"nmap <silent> [g <Plug>(coc-diagnostic-prev)
"nmap <silent> ]g <Plug>(coc-diagnostic-next)
"
"" Remap keys for gotos
"nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)
"
"" Use K to show documentation in preview window
"nnoremap <silent> K :call <SID>show_documentation()<CR>
"
"function! s:show_documentation()
"  if (index(['vim','help'], &filetype) >= 0)
"    execute 'h '.expand('<cword>')
"  else
"    call CocAction('doHover')
"  endif
"endfunction
"
"" Highlight symbol under cursor on CursorHold
"autocmd CursorHold * silent call CocActionAsync('highlight')
"
"" Remap for rename current word
"nmap <leader>rn <Plug>(coc-rename)
"
"" Remap for format selected region
"xmap <leader>f  <Plug>(coc-format-selected)
"nmap <leader>f  <Plug>(coc-format-selected)
"
"augroup mygroup
"  autocmd!
"  " Setup formatexpr specified filetype(s).
"  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
"  " Update signature help on jump placeholder
"  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
"augroup end
"
"" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
""xmap <leader>a  <Plug>(coc-codeaction-selected)
""nmap <leader>a  <Plug>(coc-codeaction-selected)
"
"" Remap for do codeAction of current line
"nmap <leader>ac  <Plug>(coc-codeaction)
"" Fix autofix problem of current line
"nmap <leader>qf  <Plug>(coc-fix-current)
"
"" Create mappings for function text object, requires document symbols feature of languageserver.
"xmap if <Plug>(coc-funcobj-i)
"xmap af <Plug>(coc-funcobj-a)
"omap if <Plug>(coc-funcobj-i)
"omap af <Plug>(coc-funcobj-a)
"
"" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
""nmap <silent> <C-d> <Plug>(coc-range-select)
""xmap <silent> <C-d> <Plug>(coc-range-select)
"
"" Use `:Format` to format current buffer
"command! -nargs=0 Format :call CocAction('format')
"
"" Use `:Fold` to fold current buffer
"command! -nargs=? Fold :call     CocAction('fold', <f-args>)
"
"" use `:OR` for organize import of current buffer
"command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
"
"" Add status line support, for integration with other plugin, checkout `:h coc-status`
""set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
"
"" Using CocList
"" Show all diagnostics
"nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
"" Manage extensions
"nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
"" Show commands
"nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
"" Find symbol of current document
"nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
"" Search workspace symbols
"nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
"" Do default action for next item.
"nnoremap <silent> <space>j  :<C-u>CocNext<CR>
"" Do default action for previous item.
"nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
"" Resume latest coc list
"nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
"
"" Distraction Free Mode
"let g:dfm_width = 80 "absolute width or percentage, like 0.7
"let g:dfm_height = 0.8
"
"let s:dfm_enabled = 0
"
"function! ToggleDistractionFreeMode()
"  let l:w = g:dfm_width > 1 ? g:dfm_width : (winwidth('%') * g:dfm_width)
"  let l:margins = {
"	\ "l": ("silent leftabove " . float2nr((winwidth('%') - l:w) / 2 - 1) . " vsplit new"),
"	\ "h": ("silent rightbelow " . float2nr((winwidth('%') - l:w) / 2 - 1) . " vsplit new"),
"	\ "j": ("silent leftabove " . float2nr(winheight('%') * (1 - g:dfm_height) / 2 - 1) . " split new"),
"	\ "k": ("silent rightbelow " . float2nr(winheight('%') * (1 - g:dfm_height) / 2 - 1) . " split new"),
"	\ }
"  if (s:dfm_enabled == 0)
"    let s:dfm_enabled = 1
"    for key in keys(l:margins)
"      execute l:margins[key] . " | wincmd " . key
"    endfor
"    for key in ['NonText', 'VertSplit', 'StatusLine', 'StatusLineNC']
"      execute 'hi ' . key . ' ctermfg=bg ctermbg=bg cterm=NONE'
"    endfor
"    set wrap | set linebreak
"    map j gj
"    map k gk
"  else
"    let s:dfm_enabled = 0
"    for key in keys(l:margins)
"      execute "wincmd " . key . " | close "
"    endfor
"    set nowrap | set nolinebreak
"    unmap j
"    unmap k
"  endif
"endfunction
