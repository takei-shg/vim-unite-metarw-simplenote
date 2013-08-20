let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#simplenote#define()"{{{
"   call s:add_edit_tag_action_on_command_kind()
  let kinds = []
  for command in s:get_commands()
    let kind = call(s:to_define_func(command), [])
    if type({}) == type(kind)
      call add(kinds, kind)
    elseif type([]) == type(kind)
      call extend(kinds, kind)
    endif
    unlet kind
  endfor
  return kinds
endfunction"}}}

" local functions {{{
function! s:get_commands()"{{{
  return map(
\   split(
\     globpath(&runtimepath, 'autoload/unite/kinds/simplenote/*.vim'),
\     '\n'
\   ),
\   'fnamemodify(v:val, ":t:r")'
\ )
endfunction"}}}

function! s:to_define_func(command)"{{{
  return 'unite#kinds#simplenote#' . a:command . '#define'
endfunction}}}

function! s:add_edit_tag_action_on_command_kind()"{{{
  let edit_tag = {
\   'description'   : 'edit tag',
\   'is_selectable' : 1,
\ }
  function! edit_tag.func(candidate)
    let note_key = a:candidate.action__path

    return echo(note_key)
"     call simplenote#print("git mv")
"     call simplenote#print(printf('from "%s"', source))
" 
"     let destination = simplenote#input('to: ', source)
"     let is_directory = isdirectory(destination)
" 
"     return simplenote#mv#run({
" \     'source'                : source,
" \     'destination'           : is_directory ? '' : destination,
" \     'destination_directory' : is_directory ? destination : '',
" \   })
  endfunction
  call unite#custom_action('file', 'edit_tag', edit_tag)
endfunction"}}}
" }}}

" context getter {{{
function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unite#kinds#simplenote#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__

