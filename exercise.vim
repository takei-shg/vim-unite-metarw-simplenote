if exists("g:loaded_exercise")
  finish
endif
let g:loaded_exercise = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:ToggleDone(line)
  if a:line =~ '^"*\s*\[D\]'
    call setline('.', substitute(a:line, '\[D\]<.*>', '[ ]', ''))
  else
    call setline('.', substitute(a:line, '\[ \]', '[D]<'.strftime("%Y/%m/%d %H:%M").'>', ''))
  endif
endfunction

" command! -nargs=0 MyExercise call s:read(':sn:aaa:xyz')
command! -nargs=0 MyExercise call s:create_description()

function! s:complete()
  echo [s:mocklist(), 'sn:', '']
endfunction

function! s:timeconvert()
  echo strftime('%Y/%m/%d %H:%M',  float2nr(1234567.933))
endfunction

function! s:read(fakepath)
  let l = split(a:fakepath, ':', 1)
  echo l[1]
  echo l[2]
  if len(l) < 2
    echohl ErrorMsg | echomsg 'Unexpected fakepath: %s', string(a:fakepath) | echohl None
    echoerr l[1]
    return ['error', printf('Unexpected fakepath: %s', string(a:fakepath))]
  endif
"   if len(s:authorization()) > 0
"     return ['error', 'auth error']
"   endif
"   let url = printf('https://simple-note.appspot.com/api/note?key=%s&auth=%s&email=%s', l[1], s:token, s:email)
"   let res = webapi#http#get(url)
"   if res.header[0] == 'HTTP/1.1 200 OK'
"     setlocal noswapfile
"     put =iconv(res.content, 'utf-8', &encoding)
"     let b:sn_key = l[1]
"     return ['read', l[1]]
"   endif
"   echoerr l[1]
  return ['error']
endfunction

function! s:mocklist()
  let candidates = []
  for e in [1,2,3,4]
    let title = 'title is ' . e
    call add(candidates, printf('sn:%s:%s', string(e), escape(title, ' \/#%')))
  endfor
  return candidates
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
