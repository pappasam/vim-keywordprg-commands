""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-keywordprg-commands: create commands to lookup keywords
" License:        MIT License
" Website:        https://github.com/pappasam/vim-keywordprg-commands
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Setup:

if exists("g:loaded_keywordprg_commands")
  finish
endif
let g:loaded_keywordprg_commands = v:true
let s:save_cpo = &cpo
set cpo&vim

" Configuration:

let s:default_commands = {
      \ 'Def': 'dict -d wn %s',
      \ 'Pydoc': ['pydoc %s', 'rst'],
      \ 'Syn': 'dict -d moby-thesaurus %s',
      \ }

function! s:configure_constants()
  if !exists('g:vim_keywordprg_commands')
    let g:vim_keywordprg_commands = {}
  elseif type(g:vim_keywordprg_commands) != v:t_dict
    throw 'g:vim_keywordprg_commands must be Dict'
  endif
  let g:vim_keywordprg_commands = extend(
        \ s:default_commands,
        \ g:vim_keywordprg_commands,
        \ )

  if !exists('g:vim_keywordprg_ft_default')
    let g:vim_keywordprg_ft_default = ''
  elseif type(g:vim_keywordprg_ft_default) != v:t_string
    throw 'g:vim_keywordprg_ft_default must be a String'
  endif
endfunction

function! s:configure_keyword_commands()
  for [cmdname, value] in items(g:vim_keywordprg_commands)
    if match(cmdname, '^[A-Z][A-Za-z0-9]*$') != 0
      throw printf('"%s" does not begin with [A-Z]', cmdname)
    endif

    if type(value) == v:t_string
      call keywordprg_commands#create(
            \ cmdname,
            \ value,
            \ g:vim_keywordprg_ft_default,
            \ )
    elseif type(value) == v:t_list
      call keywordprg_commands#create(
            \ cmdname,
            \ get(value, 0, ''),
            \ get(value, 1, g:vim_keywordprg_ft_default),
            \ )
    else
      throw printf('"%s" must be List or String', value)
    endif
  endfor
endfunction

" Finish:

try
  call s:configure_constants()
  call s:configure_keyword_commands()
catch /.*/
  throw printf('vim-keywordprg-commands: %s', v:exception)
finally
  " Teardown:
  let &cpo = s:save_cpo
  unlet s:save_cpo
endtry
