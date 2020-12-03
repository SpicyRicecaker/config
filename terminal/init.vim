set clipboard+=unnamedplus
if exists('g:vscode')
	nmap j gj
	nmap k gk
else
	nnoremap j gj
	nnoremap k gk
endif
