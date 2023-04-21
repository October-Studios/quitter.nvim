autocmd! QuitPre * if &modified | lua require('quitter').setup() | endif
