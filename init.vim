set mouse=a
set number
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4

call plug#begin()
Plug 'https://github.com/vim-airline/vim-airline'
Plug 'https://github.com/preservim/nerdtree'
Plug 'https://github.com/rafi/awesome-vim-colorschemes'
Plug 'https://github.com/preservim/tagbar'
Plug 'https://github.com/andweeb/presence.nvim'
Plug 'https://github.com/ryanoasis/vim-devicons'
Plug 'https://github.com/xiyaowong/nvim-transparent'
Plug 'liuchengxu/vim-clap'
Plug 'https://github.com/goolord/alpha-nvim'
call plug#end()

let g:dashboard_default_executive ='clap'

let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="-"
let g:transparent_enabled = v:true

:colorscheme jellybeans

nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>

nmap <F8> :TagbarToggle<CR>

set encoding=UTF-8
