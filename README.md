README
------

  ** This repository is only for development.
  Tried to use metarw / unite for simplenote plugin for vim.
  Using metarw is not practical, since the update via network is slow.

FEATURES
--------

- Show note list with `:Unite simplenote`.
- Edit the selected note.
- Save the contents with `:w`.
- Edit tags with unite action `edit_tag`.

TO SETUP DEV-ENV
----------------

- `$ mkdir ~/.vim/plugin`
- Clone this repo to ~/.vim/plugin
- Edit .vimrc

```VimL
let s:plugindev_root = expand('~/.vim/plugin')`
if has('vim_starting')
  execute "set runtimepath+=" . s:plugindev_root
endif
```

NOTE
----

  The codes below is for development only. You should exclude it on shipment.

```VimL
if exists("g:loaded_sn")
  finish
endif
let g:loaded_sn = 1
```
