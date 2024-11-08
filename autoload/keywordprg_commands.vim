""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-keywordprg-commands: create commands to lookup keywords
" License:        MIT License
" Website:        https://github.com/pappasam/vim-keywordprg-commands
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:possible_singulars(word)
  let mut_singulars = []
  let word = tolower(a:word)

  " Common irregular plurals
  let irregulars = {
        \ 'children': 'child',
        \ 'mice': 'mouse',
        \ 'men': 'man',
        \ 'women': 'woman',
        \ 'teeth': 'tooth',
        \ 'feet': 'foot',
        \ 'geese': 'goose',
        \ 'oxen': 'ox',
        \ 'lice': 'louse',
        \ 'phenomena': 'phenomenon',
        \ 'criteria': 'criterion',
        \ 'data': 'datum',
        \ 'cacti': 'cactus',
        \ 'indices': 'index',
        \ 'matrices': 'matrix',
        \ 'quizzes': 'quiz',
        \ 'bases': 'basis',
        \ 'analyses': 'analysis'
        \ }

  " Check for irregular plurals
  if has_key(irregulars, word)
    call add(mut_singulars, irregulars[word])
  else
    if word =~# 's$'
      call add(mut_singulars, substitute(word, 's$', '', ''))
    endif
    if word =~# 'ies$'
      call add(mut_singulars, substitute(word, 'ies$', 'y', ''))
    endif
    if word =~# 'es$'
      call add(mut_singulars, substitute(word, 'es$', '', ''))
    endif
    if word =~# 'ves$'
      call add(mut_singulars, substitute(word, 'ves$', 'f', ''))
    endif
    if word =~# 'ves$'
      call add(mut_singulars, substitute(word, 'ves$', 'fe', ''))
    endif
    if word =~# 'i$'
      call add(mut_singulars, substitute(word, 'i$', 'us', ''))
    endif
    if word =~# 'a$'
      call add(mut_singulars, substitute(word, 'a$', 'um', ''))
    endif
    if word =~# 'ice$'
      call add(mut_singulars, substitute(word, 'ice$', 'ouse', ''))
    endif
    if word =~# 'en$'
      call add(mut_singulars, word[:-3])
    endif
    if word =~# 'ices$'
      call add(mut_singulars, substitute(word, 'ices$', 'ex', ''))
    endif
    if word =~# 'eaux$'
      call add(mut_singulars, substitute(word, 'eaux$', 'eau', ''))
    endif
    if word =~# 'ae$'
      call add(mut_singulars, substitute(word, 'ae$', 'a', ''))
    endif
    if word =~# 'ies$' && len(word) > 4
      let stem = word[:-4]
      if stem =~# '[aeiou].$'
        call add(mut_singulars, stem . 'y')
      endif
    endif
    if word =~# 'oes$'
      call add(mut_singulars, substitute(word, 'oes$', 'o', ''))
    endif
    if word =~# 'ing$'
      call add(mut_singulars, substitute(word, 'ing$', '', ''))
    endif
    if word =~# 'ing$'
      call add(mut_singulars, substitute(word, 'ing$', 'e', ''))
    endif
  endif
  " Additional checks for words that might not be plural
  let non_plural_endings = ['ss', 'us', 'is', 'sis']
  for ending in non_plural_endings
    if word =~# ending . '$'
      call add(mut_singulars, word)
      break
    endif
  endfor
  " Remove duplicates, empty strings, and the original word if it's in the list
  call filter(mut_singulars, 'v:val != "" && v:val != word')
  return uniq(mut_singulars)
endfunction

function! s:select_win_same_ft(expected_ft)
  let current_tab = tabpagenr()
  let current_window = winnr()

  for window in getwininfo()
    if window.tabnr == current_tab
      if a:expected_ft == getwinvar(window.winnr, '&filetype')
        execute window.winnr .. 'wincmd w'
        return
      endif
    endif
  endfor
endfunction

function! s:read_command_to_doc(word, command, command_name, ft) range
  let fp = printf('%s/%s.%s',
        \ fnamemodify(tempname(), ':p:h'),
        \ a:word,
        \ a:command_name,
        \ )
  let ft_keyword = 'keywordprg' .. a:command_name
  let ft = a:ft == '' ? ft_keyword : printf('%s.%s', ft_keyword, a:ft)

  " reuse keywordprg window if present
  if ft != &filetype
    call s:select_win_same_ft(ft)
  endif

  " if buffer already exists, enter it...
  if bufnr(fp) != -1
    execute printf('silent! %s %s', ft == &filetype ? 'edit!' : 'split!', fp)
    return
  endif

  " otherwise, create and configure it...
  let cmd = printf(a:command, a:word)
  execute printf('silent ! %s > %s', cmd, fp)
  let mut_shell_error = v:shell_error
  if mut_shell_error
    for singular in s:possible_singulars(a:word)
      let depluralize_attempt_cmd = printf(a:command, singular)
      execute printf('silent ! %s > %s', depluralize_attempt_cmd, fp)
      let mut_shell_error = v:shell_error
      if !mut_shell_error
        break
      endif
    endfor
    if mut_shell_error
      " re-run first command so that output is not silly
      execute printf('silent ! %s > %s', cmd, fp)
    endif
  endif
  execute printf('silent! %s %s', ft == &filetype ? 'edit!' : 'split!', fp)
  execute printf('set filetype=%s', ft)
  execute printf('setlocal keywordprg=:%s', a:command_name)
  if mut_shell_error
    silent! call append(0, printf('No matches for "%s":', a:word))
    silent! call append(1, printf('  "%s" did not return any matches', cmd))
  endif
  silent write!
  nnoremap <silent> <buffer> d <C-d>
  nnoremap <silent> <buffer> u <C-u>
  nnoremap <silent> <buffer> q :q<CR>
  setlocal noswapfile nobuflisted nomodifiable readonly nospell
  redraw!
endfunction

function! keywordprg_commands#create(cmdname, cmd, filetype)
  execute printf(
        \ "command! -nargs=1 %s call s:read_command_to_doc(<q-args>, '%s', '%s', '%s')",
        \ a:cmdname, a:cmd, a:cmdname, a:filetype)
endfunction
