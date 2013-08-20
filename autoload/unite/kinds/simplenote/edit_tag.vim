let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#simplenote#edit_tag#define()"{{{
  return s:kind
endfunction"}}}

let s:kind = {
\ 'name' : 'simplenote/edit_tag',
\ 'default_action' : 'view',
\ 'action_table' : {},
\ 'alias_table' : {},
\}

" actions {{{
let s:kind.action_table.view = {
\ 'description' : 'view tags',
\ 'is_selectable' : 0,
\ 'is_quit' : 0,
\ 'is_invalidate_cache' : 0,
\}
function! s:kind.action_table.view.func(candidate)"{{{
  let data = a:candidate.action__data
  call echo('tags:    ' . data)
endfunction"}}}

" }}}

" local functions {{{
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

