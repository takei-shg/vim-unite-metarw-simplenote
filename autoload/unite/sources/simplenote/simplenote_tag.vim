let s:save_cpo = &cpo
set cpo&vim

let s:source = {
\ 'name' : 'sn/simplenote_tag',
\ 'description' : 'edit tags',
\ }

function! unite#sources#simplenote#simplenote_tag#define()"{{{
  return s:source
endfunction"}}}

function! s:source.gather_candidates(args, context)"{{{
  call unite#print_message('[sn/simplenote_tag]' . s:build_title())
  let candidates = metarw#sn#complete('', '', '')
  return map(len(candidates) > 0 ? candidates[0] : [], "{
  \ 'word': s:create_description(v:val),
  \ 'kind': 'simplenote/edit_tag',
  \ 'action__data': v:val.key,
  \}")
endfunction"}}}


" local functions {{{
let s:word_format = '%-16s %- 20s %s'
function! s:build_title()"{{{
  return printf(s:word_format,
  \   'modifydate',
  \   'tags',
  \   'title',
  \ )
endfunction"}}}
" }}}

function! s:create_description(candidate)"{{{
  return printf(s:word_format,
  \   a:candidate.modifydate,
  \   strlen(a:candidate.tags) >= 20 ? a:candidate.tags[0:18] . '~' : a:candidate.tags,
  \   a:candidate.title,
  \ )
endfunction"}}}

" context getter {{{
function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unite#sources#simplenote#simplenote#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

