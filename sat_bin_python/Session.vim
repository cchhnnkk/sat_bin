let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
inoremap <silent> <Plug>(neocomplcache_start_omni_complete) 
inoremap <silent> <Plug>(neocomplcache_start_auto_complete_no_select) 
inoremap <silent> <Plug>(neocomplcache_start_auto_complete) =neocomplcache#mappings#popup_post()
inoremap <silent> <expr> <Plug>(neocomplcache_start_unite_quick_match) unite#sources#neocomplcache#start_quick_match()
inoremap <silent> <expr> <Plug>(neocomplcache_start_unite_complete) unite#sources#neocomplcache#start_complete()
map! <S-Insert> *
map  3
map  3
vmap  "*d
nmap d :cs find d =expand("<cword>")	
nmap i :cs find i ^=expand("<cfile>")$
nmap f :cs find f =expand("<cfile>")	
nmap e :cs find e =expand("<cword>")	
nmap t :cs find t =expand("<cword>")	
nmap c :cs find c =expand("<cword>")	
nmap g :cs find g =expand("<cword>")	
nmap s :cs find s =expand("<cword>")	
nmap <silent> ,mr :MultieditReset
nmap <silent> ,md :MultieditClear
nmap ,C :Multiedit!
nmap ,M :Multiedit
nmap ,mu :MultieditRestore
nmap ,mm viw:MultieditAddRegion
vmap ,m :MultieditAddRegion  
nmap ,mI ^:MultieditAddMark i
nmap ,mA $:MultieditAddMark a
nmap ,mO O:MultieditAddMark i
nmap ,mo o:MultieditAddMark i
nmap ,mi :MultieditAddMark i
nmap ,ma :MultieditAddMark a
nmap ,caL <Plug>CalendarH
nmap ,cal <Plug>CalendarV
map ,e :e =expand("%:p:h") . "/"  
map [m :MultieditHop -1
map ]m :MultieditHop 1
nmap gx <Plug>NetrwBrowseX
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
nmap <Nul><Nul>d :vert scs find d =expand("<cword>")
nmap <Nul><Nul>i :vert scs find i ^=expand("<cfile>")$	
nmap <Nul><Nul>f :vert scs find f =expand("<cfile>")	
nmap <Nul><Nul>e :vert scs find e =expand("<cword>")
nmap <Nul><Nul>t :vert scs find t =expand("<cword>")
nmap <Nul><Nul>c :vert scs find c =expand("<cword>")
nmap <Nul><Nul>g :vert scs find g =expand("<cword>")
nmap <Nul><Nul>s :vert scs find s =expand("<cword>")
nmap <Nul>d :scs find d =expand("<cword>")	
nmap <Nul>i :scs find i ^=expand("<cfile>")$	
nmap <Nul>f :scs find f =expand("<cfile>")	
nmap <Nul>e :scs find e =expand("<cword>")	
nmap <Nul>t :scs find t =expand("<cword>")	
nmap <Nul>c :scs find c =expand("<cword>")	
nmap <Nul>g :scs find g =expand("<cword>")	
nmap <Nul>s :scs find s =expand("<cword>")	
nnoremap <silent> <Plug>CalendarH :cal calendar#show(1)
nnoremap <silent> <Plug>CalendarV :cal calendar#show(0)
nmap <silent> <F9> :TlistToggle    "´ò¿ªtag´°¿Ú
vmap <C-Del> "*d
vmap <S-Del> "*d
vmap <C-Insert> "*y
vmap <S-Insert> "-d"*P
nmap <S-Insert> "*P
let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set autoread
set background=dark
set cindent
set completefunc=neocomplcache#complete#manual_complete
set completeopt=preview,menuone
set cscopetag
set cscopeverbose
set expandtab
set fileencodings=utf-8,chinese
set guifont=Bitstream_Vera_Sans_Mono:h11
set guifontwide=Yahei_Mono:h11
set guioptions=egt
set helplang=cn
set history=50
set hlsearch
set incsearch
set omnifunc=pythoncomplete#Complete
set shiftwidth=4
set showmatch
set smartindent
set softtabstop=4
set tabstop=4
set wildignore=*.pyc
set window=52
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd E:\sat_bin\sat_bin_python
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +0 sat_bin_dynamic_partition.py
args sat_bin_dynamic_partition.py
edit sat_bin_dynamic_partition.py
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
exe 'vert 1resize ' . ((&columns * 106 + 106) / 212)
exe 'vert 2resize ' . ((&columns * 105 + 106) / 212)
argglobal
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal balloonexpr=
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:XCOMM,n:>,fb:-
setlocal commentstring=#%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=neocomplcache#complete#auto_complete
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'python'
setlocal filetype=python
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
set foldlevel=99
setlocal foldlevel=99
setlocal foldmarker={{{,}}}
setlocal foldmethod=indent
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=s*\\(from\\|import\\)
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal indentexpr=GetPythonIndent(v:lnum)
setlocal indentkeys=0{,0},:,!^F,o,O,e,<:>,=elif,=except
setlocal noinfercase
setlocal iskeyword=@,48-57,63,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=pythoncomplete#Complete
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal smartindent
setlocal softtabstop=4
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.py
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'python'
setlocal syntax=python
endif
setlocal tabstop=4
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
29
normal! zo
29
normal! zc
61
normal! zo
61
normal! zc
87
normal! zo
87
normal! zc
97
normal! zo
97
normal! zc
151
normal! zo
152
normal! zo
155
normal! zc
152
normal! zc
151
normal! zc
163
normal! zo
182
normal! zc
195
normal! zo
195
normal! zc
203
normal! zo
203
normal! zc
229
normal! zo
229
normal! zc
248
normal! zo
248
normal! zc
277
normal! zo
277
normal! zc
291
normal! zo
291
normal! zc
302
normal! zo
303
normal! zc
302
normal! zc
311
normal! zo
311
normal! zc
364
normal! zo
572
normal! zo
572
normal! zc
364
normal! zc
684
normal! zo
696
normal! zo
696
normal! zc
707
normal! zo
707
normal! zc
742
normal! zo
744
normal! zo
742
normal! zc
684
normal! zc
752
normal! zo
755
normal! zc
775
normal! zo
775
normal! zc
790
normal! zo
790
normal! zc
798
normal! zo
798
normal! zc
820
normal! zo
820
normal! zc
832
normal! zo
832
normal! zc
840
normal! zo
860
normal! zo
840
normal! zc
891
normal! zo
891
normal! zc
912
normal! zo
912
normal! zc
939
normal! zo
939
normal! zc
978
normal! zo
978
normal! zc
990
normal! zo
990
normal! zc
1011
normal! zo
1011
normal! zc
1041
normal! zo
1041
normal! zc
1221
normal! zo
1221
normal! zc
1285
normal! zo
1285
normal! zc
1295
normal! zc
1316
normal! zo
1316
normal! zc
1331
normal! zo
1331
normal! zc
1377
normal! zc
let s:l = 891 - ((138 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
891
normal! 01|
wincmd w
argglobal
edit sat_bin_dynamic_partition.py
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal balloonexpr=
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:XCOMM,n:>,fb:-
setlocal commentstring=#%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=neocomplcache#complete#auto_complete
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'python'
setlocal filetype=python
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
set foldlevel=99
setlocal foldlevel=99
setlocal foldmarker={{{,}}}
setlocal foldmethod=indent
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=s*\\(from\\|import\\)
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal indentexpr=GetPythonIndent(v:lnum)
setlocal indentkeys=0{,0},:,!^F,o,O,e,<:>,=elif,=except
setlocal noinfercase
setlocal iskeyword=@,48-57,63,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=pythoncomplete#Complete
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal smartindent
setlocal softtabstop=4
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.py
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'python'
setlocal syntax=python
endif
setlocal tabstop=4
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
29
normal! zo
29
normal! zc
61
normal! zo
61
normal! zc
87
normal! zo
97
normal! zo
117
normal! zo
117
normal! zc
130
normal! zo
130
normal! zc
144
normal! zo
144
normal! zc
151
normal! zo
152
normal! zo
152
normal! zc
163
normal! zo
182
normal! zc
195
normal! zo
195
normal! zc
203
normal! zo
207
normal! zo
210
normal! zo
211
normal! zo
203
normal! zc
229
normal! zo
231
normal! zo
233
normal! zo
237
normal! zo
229
normal! zc
248
normal! zo
261
normal! zo
264
normal! zo
266
normal! zo
248
normal! zc
277
normal! zo
277
normal! zc
291
normal! zo
293
normal! zo
294
normal! zo
291
normal! zc
163
normal! zc
302
normal! zo
311
normal! zo
311
normal! zc
364
normal! zo
391
normal! zo
391
normal! zc
409
normal! zo
413
normal! zo
409
normal! zc
433
normal! zo
453
normal! zo
475
normal! zo
476
normal! zo
433
normal! zc
485
normal! zo
498
normal! zo
502
normal! zo
485
normal! zc
538
normal! zo
538
normal! zc
572
normal! zo
588
normal! zo
589
normal! zo
596
normal! zo
606
normal! zo
608
normal! zo
572
normal! zc
622
normal! zo
622
normal! zc
658
normal! zo
664
normal! zo
673
normal! zo
658
normal! zc
364
normal! zc
684
normal! zo
752
normal! zo
752
normal! zc
1041
normal! zo
1113
normal! zo
1147
normal! zo
1156
normal! zo
1221
normal! zo
1235
normal! zo
1235
normal! zo
1242
normal! zo
1285
normal! zo
1285
normal! zc
1295
normal! zc
1316
normal! zo
1316
normal! zc
1331
normal! zo
1331
normal! zc
1377
normal! zc
let s:l = 709 - ((403 * winheight(0) + 25) / 51)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
709
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 106 + 106) / 212)
exe 'vert 2resize ' . ((&columns * 105 + 106) / 212)
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
