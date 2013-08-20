if exists("g:loaded_simplenote_service")
  finish
endif
let g:loaded_simplenote_service = 1

if !exists('s:token')
  let s:email = ''
  let s:token = ''
  let s:titles = {}
  let s:tags_map = {}
  let s:modifydates = {}
endif

let s:AUTH_URL = 'https://simple-note.appspot.com/api/login'
let s:DATA_URL = 'https://simple-note.appspot.com/api2/data/'
let s:INDX_URL = 'https://simple-note.appspot.com/api2/index?'
let s:NOTE_FETCH_LENGTH = 20

" note_key :: String
" modifydate :: String
function! metarw#service#simplenote#check_modified(note_key, modifydate)

  if len(s:authorization())
    return [['auth error'], 'sn:', '']
  endif

  let url = printf(s:DATA_URL . '%s?auth=%s&email=%s', a:note_key, s:token, s:email)
  let res = webapi#http#get(url)
  let g:metarw_service_sn_edit_tag_noteres = res " TODO : Debug
  if res.status =~ '^2'
    let res_content = webapi#json#decode(iconv(res.content, 'utf-8', &encoding))
    " FIXME cofirm we can use modifydate to check tag updated
    let modifydate = iconv(res_content.modifydate, 'utf-8', &encoding)
    if modifydate != a:modifydate
      return [['note is updated'], 'sn:', '']
    endif

  else
    echoerr printf('cannot get content for the key: %s \n', node.key)
  endif
endfunction

function! metarw#service#simplenote#get_notelist(note_key, modifydate)
endfunction
" note_key :: String
" newtags :: [String]
function! metarw#service#simplenote#edit_tag(note_key, modifydate, newtags)

  let update_url = printf('https://simple-note.appspot.com/api2/data/%s?auth=%s&email=%s', a:note_key, s:token, webapi#http#encodeURI(s:email))
  let res = webapi#http#post(update_url,
  \  webapi#http#encodeURI(iconv(webapi#json#encode({
  \    'tags': a:newtags,
  \  }),
  \ 'utf-8',
  \ &encoding))
  \)
  if res.status =~ '^2'
    if len(note_key) == 0
      let key = res.content
      echo 'tag update succeeded.'
      " silent! exec 'file '.printf('sn:%s', escape(key, ' \/#%'))
      set nomodified
    endif
    return ['done', '']
  endif
  return ['error', 'status code : ' . res.status]
endfunction

function! metarw#sn#write(fakepath, line1, line2, append_p)
  let g:sn_write_fakepath = string(a:fakepath)
  let g:sn_write_append_p = string(a:append_p)
  let l = split(a:fakepath, ':')
  if len(l) < 2
    return ['error', printf('Unexpected fakepath: %s', string(a:fakepath))]
  endif

  let note_key = l[1]
  let g:sn_note_key = note_key

  if len(s:authorization())
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

function! s:authorization()
  if len(s:token) > 0
    return ''
  endif
  " let s:email = input('email:')
  " FIXME: hard coded email address
  let s:email = 'takei.shg@gmail.com'
  let password = inputsecret('password:')
  let creds = webapi#base64#b64encode(printf('email=%s&password=%s', s:email, password))
  let res = webapi#http#post(s:AUTH_URL, creds)
  if res.status =~ '^2'
    let s:token = res.content
    return ''
  endif
  return 'failed to authenticate'
endfunction

