set clipboard+=unnamedplus
if exists('g:vscode')
  nmap j gj
  nmap k gk
else
  call plug#begin("~/.config/nvim/plugged")
  Plug 'joshdick/onedark.vim'
  Plug 'itchyny/lightline.vim'
  Plug 'plasticboy/vim-markdown'
  call plug#end()
  if (has("termguicolors"))
    set termguicolors
  endif
  let g:lightline = {
        \ 'colorscheme': 'onedark',
        \ }
  let g:onedark_hide_endofbuffer = 1
  let g:onedark_terminal_italics = 1
  syntax on
  autocmd vimenter * ++nested colorscheme onedark
  set tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab autoindent
  set incsearch ignorecase smartcase hlsearch
  set wrap breakindent
  " autocmd FileType markdown setlocal shiftwidth=2 tabstop=2 softtabstop=2
  let g:vim_markdown_folding_disabled = 1
  nnoremap j gj
  nnoremap k gk
  :imap jk <Esc>
endif
