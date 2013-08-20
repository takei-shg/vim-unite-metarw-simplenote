let s:save_cpo = &cpo
set cpo&vim

let s:source = {
\ 'name' : 'simplenote_dev',
\ 'description' : 'candidates for simplenote',
\ }

function! unite#sources#simplenote#define()"{{{
  let sources = []
  for command in s:get_commands()
    let source = call(s:to_define_func(command), [])
    if type({}) == type(source)
      call add(sources, source)
    elseif type([]) == type(source)
      call extend(sources, source)
    endif
    unlet source
  endfor
  return add(sources, s:source)
endfunction"}}}

function! s:source.gather_candidates(args, context)"{{{
  call unite#print_message('[sn] simplenote sources')
  return map(s:get_commands(), '{
\   "word"   : v:val,
\   "source" : s:source.name,
\   "kind"   : "source",
\   "action__source_name" : "sn/" . v:val,
\ }')
endfunction"}}}

function! s:create_description(candidate)
  return a:candidate.modifydate . ':' . a:candidate.tags . ':' . a:candidate.title
endfunction

" local functions {{{
function! s:get_commands()"{{{
  return map(
\   split(
\     globpath(&runtimepath, 'autoload/unite/sources/simplenote/*.vim'),
\     '\n'
\   ),
\   'fnamemodify(v:val, ":t:r")'
\ )
endfunction"}}}

function! s:to_define_func(command)"{{{
  return 'unite#sources#simplenote#' . a:command . '#define'
endfunction}}}
" }}}

" context getter {{{
function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unite#sources#simplenote#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
