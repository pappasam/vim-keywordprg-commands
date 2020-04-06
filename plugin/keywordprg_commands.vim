""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-keywordprg-commands: create commands to lookup keywords
" License:        MIT License
" Website:        https://github.com/pappasam/vim-keywordprg-commands
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:default_commands = {
      \ 'Def': ['dict -d gcide %s', 'gitcommit'],
      \ 'Pydoc': ['pydoc %s', 'rst'],
      \ 'Syn': ['dict -d moby-thesaurus %s', 'gitcommit'],
      \ }

if !exists('g:vim_keywordprg_commands')
  let g:vim_keywordprg_commands = {}
elseif type(g:vim_keywordprg_commands) != v:t_dict
  throw 'User-configured g:vim_keywordprg_commands must be Dict'
endif
let g:vim_keywordprg_commands = extend(
      \ s:default_commands,
      \ g:vim_keywordprg_commands)

call keywordprg_commands#configure(g:vim_keywordprg_commands)
