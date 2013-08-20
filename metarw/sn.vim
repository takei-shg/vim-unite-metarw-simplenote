if exists("g:loaded_sn")
  finish
endif
let g:loaded_sn = 1

" Variables "{{{1
let s:FALSE = 0
let s:TRUE = !s:FALSE


if !exists('s:token')
  let s:titles = {}
  let s:tags_map = {}
  let s:modifydates = {}
endif

let s:AUTH_URL = 'https://simple-note.appspot.com/api/login'
let s:DATA_URL = 'https://simple-note.appspot.com/api2/data/'
let s:INDX_URL = 'https://simple-note.appspot.com/api2/index?'
let s:NOTE_FETCH_LENGTH = 20

function! metarw#sn#complete(arglead, cmdline, cursorpos)"{{{
  if metarw#service#simplenote#authorization() == s:FALSE
    return [['auth error'], 'sn:', '']
  endif

  let candidates = []
  let res = metarw#service#simplenote#get_notelist()
  if res.result == s:FALSE
    echoerr printf('error in get notelist : %s', res.message)
    return candidates
  endif
  for node in res.data.data
    if !node.deleted
      if !has_key(s:titles, node.key)
        let res_content = metarw#service#simplenote#read_note(node.key)
        if res_content.result == s:TRUE
          let lines = split(iconv(res_content.data.content, 'utf-8', &encoding), "\n")
          let s:titles[node.key] = len(lines) > 0 ? lines[0] : ''

          let taglist = map(res_content.data.tags, iconv('v:val', 'utf-8', &encoding))
          let s:tags_map[node.key] = join(taglist, ',')

          let modifydate = iconv(res_content.data.modifydate, 'utf-8', &encoding)
          let s:modifydates[node.key] = modifydate

        else
          echoerr printf('cannot get content for the key: %s, error: %s ', node.key, res_content.message)
        endif
      endif
      call add(candidates, {
      \ "modifydate" : s:modifydates[node.key],
      \ "tags" : '[' . s:tags_map[node.key] . ']',
      \ "title" : escape(s:titles[node.key], ' \/#%'),
      \ "key" : node.key
      \})
    endif
  endfor
  return [candidates, 'sn:', '']
"   return [s:mocklist(), 'sn:', '']
endfunction"}}}

function! metarw#sn#read(fakepath)"{{{
  let note_key = s:parse_note_key(a:fakepath)

  if metarw#service#simplenote#authorization() == s:FALSE
    return ['error', 'error in authorization']
  endif
  let res = metarw#service#simplenote#read_note(note_key)

  if res.result == s:TRUE
    setlocal noswapfile
    put = res.data.content
    let b:sn_key = note_key
    return ['done', '']
  else
    echoerr printf('cannot get content for the key: %s, reason: %s', note_key, res[1])
  endif
  return ['error', res.message]
endfunction"}}}

function! metarw#sn#write(fakepath, line1, line2, append_p)
  let g:sn_write_fakepath = string(a:fakepath)
  let g:sn_write_append_p = string(a:append_p)
  let l = split(a:fakepath, ':')
  if len(l) < 2
    return ['error', printf('Unexpected fakepath: %s', string(a:fakepath))]
  endif

  let note_key = l[1]
  let g:sn_note_key = note_key

  if metarw#service#simplenote#authorization() =~ s:FALSE
    return ['error', 'error in authorization']
  endif

"   if len(note_key) > 0 && line('$') == 1 && getline(1) == ''
"     let url = printf('https://simple-note.appspot.com/api/delete?key=%s&auth=%s&email=%s', note_key, s:token, s:email)
"     let res = webapi#http#get(url)
"     if res.status =~ '^2'
"       echomsg 'deleted'
"       return ['done', '']
"     endif
"   endif
  if len(note_key) > 0
    " update with key
    let url = printf('https://simple-note.appspot.com/api2/data/%s?auth=%s&email=%s', note_key, s:token, webapi#http#encodeURI(s:email))
  else
    " create new note
    let url = printf('https://simple-note.appspot.com/api2/data?auth=%s&email=%s', s:token, s:email)
  endif
  let g:sn_update_url = url
  let res = webapi#http#post(url,
  \  webapi#http#encodeURI(iconv(webapi#json#encode({
  \    'content': join(getline(a:line1, a:line2), "\n"),
  \  }),
  \ 'utf-8',
  \ &encoding))
  \)
  if res.status =~ '^2'
    if len(note_key) == 0
      let key = res.content
      silent! exec 'file '.printf('sn:%s', escape(key, ' \/#%'))
      set nomodified
    endif
    return ['done', '']
  endif
  return ['error', 'status code : ' . res.status]
endfunction

" local functions {{{
function! s:parse_note_key(fakepath)"{{{
  " fakepath = sn: . {note_key}
  let l = split(a:fakepath, ':')
  if len(l) < 2
    echoerr  printf('Unexpected fakepath: %s', string(a:fakepath))
    return ''
  endif

  return l[1]
endfunction"}}}

function! s:mocklist()"{{{
  let candidates = []
  for e in [1, 2, 3]
    call add(candidates, {
    \ "modifydate" : '123456789.980',
    \ "tags" : '[' . 'aaa, bbb, ccc' . ']',
    \ "title" : escape('Test Test Test', ' \/#%'),
    \ "key" : 'agtzaw1wbgutbm90zxiqcxietm90zsigmdfiytfizjdmmmu0ndiwzmeyyjfmowjmzjdjmtk2y2um'
    \})
  endfor
  return candidates
endfunction"}}}

" }}}

