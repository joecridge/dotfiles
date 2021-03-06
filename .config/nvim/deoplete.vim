"------------------------------------------------------------------------------
" Shougo/Deoplete.nvim: asynchronous keyword completion
"------------------------------------------------------------------------------

set completeopt-=preview

let g:echodoc#enable_at_startup = 1
let g:deoplete#enable_at_startup = 1

call deoplete#custom#option('smart_case', v:true)
call deoplete#custom#option('sources', {
  \   'javascript.jsx': ['buffer', 'file', 'ternjs']
  \ })

call deoplete#custom#source('omni', 'functions', {
  \   'javascript': ['tern#Complete', 'jspc#omni']
  \ })

let g:tern#command = ['tern']
let g:tern#arguments = ['--persistent']

" Use tab for autocompletion.
inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<Tab>"

" Use `gb` to go to definition using Tern.
augroup GotoDefinition
  autocmd!
  autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
augroup END
