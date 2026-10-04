# `.vimrc` template

```vim
" ==============================
" General
" ==============================

" Enable syntax highlighting
syntax on

" Show line numbers
set number

" ==============================
" Indentation
" ==============================

" Use spaces instead of tabs
set expandtab

" Number of spaces for a tab
set tabstop=4

" Number of spaces for indentation
set shiftwidth=4

" Use shiftwidth when inserting <Tab>
set softtabstop=4

" ==============================
" Search
" ==============================

" Highlight search results
set hlsearch

" Incremental search
set incsearch

" ==============================
" Clipboard
" ==============================

" Automatically copy yanked text to macOS clipboard
augroup copy_to_macos
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y'
        \ | call system('pbcopy', getreg('"'))
        \ | endif
augroup END
```
