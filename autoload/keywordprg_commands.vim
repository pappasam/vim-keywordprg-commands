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
        \ a:command_name,
        \ )
  let ft_keyword = 'keywordprg' . a:command_name
  let ft = a:ft == '' ? ft_keyword : printf('%s.%s', ft_keyword, a:ft)
  let cmd = printf(a:command, a:word)
  execute printf('silent ! %s > %s', cmd, fp)
  let shell_error = v:shell_error
  execute printf('silent! %s %s', ft == &filetype ? 'edit!' : 'split!', fp)
  execute 'set filetype=' . ft
  execute 'file ' . fp
  execute 'setlocal keywordprg=:' . a:command_name
  if shell_error
    set modifiable
    let msg0 = printf('No matches for "%s":', a:word)
    let failure = append(0, msg0)
    let msg1 = printf('  "%s" did not return any matches', cmd)
    let failure = append(1, msg1)
  endif
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
