let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#simplenote#edit_note#define()"{{{
  return s:kind
endfunction"}}}

" Variables "{{{1
let s:FALSE = 0
let s:TRUE = !s:FALSE


let s:kind = {
\ 'name' : 'simplenote/edit_note',
\ 'default_action' : 'edit',
\ 'action_table' : {},
\ 'alias_table' : {},
\}

" actions {{{
let s:kind.action_table.create_note = {
\ 'description' : 'create note',
\ 'is_selectable' : 0,
\ 'is_quit' : 1,
\ 'is_invalidate_cache' : 0,
\}

function! s:kind.action_table.create_note.func(candidate)"{{{
  if metarw#service#simplenote#authorization() == s:FALSE
    echoerr printf('failed for authorization.')
  endif
  let response = metarw#service#simplenote#create_note()
  if response.result == s:FALSE
    echoerr printf('failed to create new note. error: %s', response.message)
    return
  endif
  let note_key = response.key

  let g:sn_kind_create_new_note_key = note_key " TODO DEBUG
  " let command = 'file ' . printf('sn:%s', escape(note_key, ' \/#%'))
  let command = 'tabnew ' . printf('sn:%s', escape(note_key, ' \/#%'))
  let type = ':'
  call s:add_history(type, command)
  silent! exec type . command
  set nomodified
  return
endfunction"}}}

let s:kind.action_table.edit = {
\ 'description' : 'edit note',
\ 'is_selectable' : 0,
\ 'is_quit' : 1,
\ 'is_invalidate_cache' : 0,
\}

function! s:kind.action_table.edit.func(candidate)"{{{
  let note_key = a:candidate.action__data.key
  let g:sn_kind_edit_note_key = note_key " TODO DEBUG
  let command = printf('Edit sn:%s', note_key)
  let type = get(a:candidate, 'action__type', ':')
  call s:add_history(type, command)
  execute type . command
endfunction"}}}

let s:kind.action_table.edit_tags = {
\ 'description' : 'view tags',
\ 'is_selectable' : 0,
\ 'is_quit' : 0,
\ 'is_invalidate_cache' : 0,
\}

function! s:kind.action_table.edit_tags.func(candidate)"{{{
  let data = a:candidate.action__data
  let newtags = input('Edit tags:', data.tags)
  let command = 'call metarw#service#simplenote#edit_tag(data.key, newtags)'
  let type = get(a:candidate, 'action__type', ':')
  call s:add_history(type, command)
  execute type . command

  let g:unite_kinds_sn_edit_note_edit_tag_key = a:candidate.action__data.key
  let g:unite_kinds_sn_edit_note_edit_tag_modifydate = a:candidate.action__data.modifydate

endfunction"}}}
" }}}

" local functions {{{
function! s:add_history(type, command)"{{{
  call histadd(a:type, a:command)
  if a:type ==# '/'
    let @/ = a:command
  endif
endfunction"}}}
" }}}

" context getter {{{
function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unite#kinds#simplenote#edit_tag#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__

