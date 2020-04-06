# vim-keywordprg-commands

A simple, functional Neovim/Vim "keywordprg command" authoring utility. If you have a command line program that you want to use as a keywordprg, this plugin will quickly make that desire a reality.

## Installation

If using [vim-plug](https://github.com/junegunn/vim-plug), place the following line in the Plugin section of your inti.vim / vimrc:

```vim
" ~/.vimrc
Plug 'pappasam/vim-keywordprg-commands'
```

Then run the Ex command:

```vim
:PlugInstall
```

I personally use [vim-packager](https://github.com/kristijanhusak/vim-packager), so if you'd like to go down the "package" rabbit hole, I suggest giving that a try.

## Full Documentation

From within Vim, type:

```vim
:help keywordprg-commands
```

## Key mappings

This plugin provides no mappings of its own, but it is intended to be used
alongside Vim's built-in keywordprg. You should associate keywordprg commands
Vim's keywordprg configuration value. For the plugin's provided commands, this
can be done in your init.vim / vimrc as follows:

```vim
augroup custom_keywordprg
  autocmd!
  autocmd FileType markdown,rst,tex,txt setlocal keywordprg=:Def
  autocmd FileType python setlocal keywordprg=:Pydoc
augroup end
```

For the above filetypes, if you type `K` while in normal mode, your keywordprg
command will be used to look up the word under the cursor. If you type `K`
while in visual mode, your keywordprg command will be used to look your visual
selection.

## Configurations

Use `g:vim_keywordprg_commands` to create and configure new keywordprg commands. See its documentation by typing `:help g:vim_keywordprg_commands`.

## Provided commands

Creating commands is super easy, but this plugin does come with some command implementations to get you started:

* `:Def` look up a word's English definition using [dict-wn](https://packages.debian.org/stretch/dict-wn). This uses a locally-installed version of [wordnet](https://wordnet.princeton.edu/).
* `:Syn` look up a word's English synonyms using [dict-moby-thesaurus](https://packages.debian.org/sid/text/dict-moby-thesaurus). This uses a locally installed version of [moby-thesaurus](http://www.moby-thesaurus.org/).
* `:Pydoc` look up a Python keyword using [pydoc](https://docs.python.org/3.8/library/pydoc.html).

## Notes

This plugin prioritizes simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is out of scope.

## Written by

Samuel Roeca _samuel.roeca@gmail.com_
