augroup netrw
    autocmd!
    autocmd FileType netrw nmap <silent> <buffer> <leader>e :Rex<CR>
    autocmd FileType netrw nmap <silent> <buffer> l <CR>
    autocmd FileType netrw nmap <silent> <buffer> h -^
    autocmd FileType netrw nmap <silent> <buffer> H gh
    autocmd FileType netrw nmap <silent> <buffer> y :let @*=expand("%:p")<CR>
augroup end
