""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-keywordprg-commands: create commands to lookup keywords
" License:        MIT License
" Website:        https://github.com/pappasam/vim-keywordprg-commands
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:read_command_to_doc(word, command, command_name, ft) range
  let fp = printf('%s/%s.%s',
        \ fnamemodify(tempname(), ':p:h'),
        \ a:word,
        \ a:command_name)
  let ft = printf('%s.%s', a:command_name, a:ft == '' ? 'text' : a:ft)
  execute printf('silent ! %s > %s', printf(a:command, a:word), fp)
  execute printf('silent! %s %s', ft == &filetype ? 'edit!' : 'split!', fp)
  execute 'set filetype=' . ft
  execute 'file ' . fp
  execute 'setlocal keywordprg=:' . a:command_name
  set buftype=nowrite nomodifiable noswapfile readonly nomodified nobuflisted
  nnoremap <silent> <buffer> d <C-d>
  nnoremap <silent> <buffer> u <C-u>
  nnoremap <silent> <buffer> q :q<CR>
  redraw!
endfunction

function! keywordprg_commands#create(cmdname, cmd, filetype)
  execute printf(
        \ "command! -nargs=1 %s call " .
        \ "s:read_command_to_doc(<q-args>, '%s', '%s', '%s')",
        \ a:cmdname,
        \ a:cmd,
        \ a:cmdname,
        \ a:filetype,
        \ )
endfunction

function! keywordprg_commands#configure(commands)
  for [cmdname, arguments] in items(a:commands)
    if type(arguments) != v:t_list
      throw 'Dict values in g:vim_keywordprg_commands must be of type List'
    endif
    let cmd = arguments[0]
    let filetype = get(arguments, 1, '')
    call keywordprg_commands#create(cmdname, cmd, filetype)
  endfor
endfunction
