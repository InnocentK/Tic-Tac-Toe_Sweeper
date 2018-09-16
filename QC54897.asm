; CMSC 313 - Spring 2018 - Project 3 - TicTacToe Sweeper
; Innocent Kironji
; wambugu1@umbc.edu

%define cmpb	cmp byte
%define	cmpd	cmp dword
%define decb	dec byte
%define	decw	dec word
%define incb	inc byte
%define xorb	xor byte
%define movb	mov byte
%define movw	mov word
%define	movd	mov dword
%define movq	mov qword

section .bss					; Uninitialized data
	buffer		resb	8
	dbuffer		resb	4
	pfunc		resq	1
	pXbomb		resb	4
	pObomb		resb	4

section .data				; Initialized data
	; Text
	mdbg		db		"Do you want to enable debug information?", 0xA
	mdbgl		equ		$ - mdbg

	; Board size text
	mb_size		db		"What kind of board will you be playing on? Enter 3(for 3x3), 4(for 4x4) or 5(for 5x5).", 0xA
	mb_sizel	equ		$ - mb_size

	msz_err		db		"Invalid board size entered", 0xA
	msz_errl	equ		$ - msz_err

	; Bomb text
	mbomb		db		", where would you like to place your bomb?", 0xA
	mbombl		equ		$ - mbomb

	mbomb_err	db		"Incorrect bomb location", 0xA
	mbomb_errl	equ		$ - mbomb_err

	mexplode	db		"Bomb exploded", 0xA
	mexplodel	equ		$ - mexplode

	; Player text
	mPXO		db		"Player X"
	mPXOl		equ		$ - mPXO
	
	mplay2_3x3	db		", choose your location (0-8):", 0xA, "Current board:", 0xA
	mplay2l_3x3	equ		$ - mplay2_3x3
	mplay2_4x4	db		", choose your location (0-15):", 0xA, "Current board:", 0xA
	mplay2l_4x4	equ		$ - mplay2_4x4
	mplay2_5x5	db		", choose your location (0-24):", 0xA, "Current board:", 0xA
	mplay2l_5x5	equ		$ - mplay2_5x5

	; Win condition text
	mwin2		db		" wins!", 0xA
	mwin2l		equ		$ - mwin2
	spot		equ		7		; Offset of X/O
	magic		equ		0x17		; Magic! =D

	mtie		db		"It's a draw (tie)!", 0xA
	mtiel		equ		$ - mtie
	mfinal		db		"Final board:", 0xA
	mfinall		equ		$ - mfinal
	merr		db		"That location is out of range or already taken.", 0xA
	merrl		equ		$ - merr

	; 3x3 game board
	pbd1_3x3	db		" | | ", 0xA
	pbd1l_3x3	equ		$ - pbd1_3x3
	pbd2_3x3	db		"-----", 0xA
	pbd2l_3x3	equ		$ - pbd2_3x3

	; 3x3 debug board
	dbd1_3x3	db		" 012345678 ", 0xA, "["
	dbd1l_3x3	equ		$ - dbd1_3x3
	board_3x3	db		"         "	; 3x3 linearized game board
	bdl_3x3		equ		$ - board_3x3
	dbd2_3x3	db		"]", 0xA
	dbd2l_3x3	equ		$ - dbd2_3x3

	; 4x4 game board
	pbd1_4x4	db		" | | | ", 0xA
	pbd1l_4x4	equ		$ - pbd1_4x4
	pbd2_4x4	db		"-------", 0xA
	pbd2l_4x4	equ		$ - pbd2_4x4

	; 4x4 debug board
	dbd1_4x4	db		" 0123456789ABCDEF ", 0xA, "[" 
	dbd1l_4x4	equ		$ - dbd1_4x4
	board_4x4	db		"                "	; 4x4 linearized game board
	bdl_4x4		equ		$ - board_4x4
	dbd2_4x4	db		"]", 0xA
	dbd2l_4x4	equ		$ - dbd2_4x4

	; 5x5 game board
	pbd1_5x5	db		" | | | | ", 0xA
	pbd1l_5x5	equ		$ - pbd1_5x5
	pbd2_5x5	db		"---------", 0xA
	pbd2l_5x5	equ		$ - pbd2_5x5

	; 5x5 debug board
	dbd1_5x5	db		" 0123456789ABCDEF... ", 0xA, "[" 
	dbd1l_5x5	equ		$ - dbd1_5x5
	board_5x5	db		"                         "	; 5x5 linearized game board
	bdl_5x5		equ		$ - board_5x5
	dbd2_5x5	db		"]", 0xA
	dbd2l_5x5	equ		$ - dbd2_5x5

	; More debug text
	ebd1_3x3	db	"Current board (hex):", 0xA, "  0  1  2  3  4  5  6  7  8 ", 0xA, "["
	ebd1l_3x3	equ		$ - ebd1_3x3
	
	ebd1_4x4	db	"Current board (hex):", 0xA, "  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F ", 0xA, "["
	ebd1l_4x4	equ		$ - ebd1_4x4
	
	eboard		db		"20 58 20 4F 20 58 20 20 4F"	; Hex linearized game board
	el		equ		$ - eboard
	ebd2		db		"]", 0xA
	ebd2l		equ		$ - ebd2

	hexdigits	db		'0123456789ABCDEF'
	mbd1		db		"Current board (mem):", 0xA, "&board = 0x"
	mbd1l		equ		$ - mbd1
	mboard		db		"FFFFFFFFFFFFFFFF"
	ml		equ		$ - mboard
	mbd2		db		0xA, "+offset / hex / ASCII", 0xA
	mbd2l		equ		$ - mbd2
	mbd3		db		"0x0/: 58h X", 0xA	; The '/' is not a typo
	mbd3l		equ		$ - mbd3
	
	; Pairs used to check for winning conditions
	lol_3x3			db		2,1,	6,3,	8,4,	9,9,\
						2,0,	7,4,	9,9,	9,9,\
						1,0,	8,5,	6,4,	9,9,\
						5,4,	6,0,	9,9,	9,9,\
						5,3,	7,1,	8,0,	6,2,\
						4,3,	8,2,	9,9,	9,9,\
						8,7,	3,0,	4,2,	9,9,\
						8,6,	4,1,	9,9,	9,9,\
						7,6,	5,2,	4,0,	9,9
	top_3x3			equ		lol_3x3+7  	; up to 9 moves can be played
	; Relates to how many inputs can be combined in tetrads (does not include "9")
	kek_3x3			db		5,3,5,3,7,3,5,3,5

	; 4x4 calculating for win (using triads)
	lol_4x4			db		3,2,1,		12,8,4,		15,10,5,	\
						3,2,0,		13,9,5,		16,16,16,	\
						3,1,0,		14,10,6,	16,16,16,	\
						2,1,0,		15,11,7,	12,9,6,		\
						7,6,5,		12,8,0,		16,16,16,	\
						7,6,4,		13,9,1,		15,10,0,	\
						7,5,4,		14,10,2,	12,9,3,		\
						6,5,4,		15,11,3,	16,16,16,	\
						11,10,9,	12,4,0,		16,16,16,	\
						11,10,8,	13,5,1,		12,6,3,		\
						11,9,8,		14,6,2,		15,5,0,		\
						10,9,8,		15,7,3,		16,16,16,	\
						15,14,13,	8,4,0,		9,6,3,		\
 						15,14,12,	9,5,1,		16,16,16,	\
						15,13,12,	10,6,2,		16,16,16,	\
						14,13,12,	11,7,3,		10,5,0
	top_4x4			equ		lol_4x4+15 	; up to 16 moves can be played
	; Relates to how many inputs can be combined in tetrads (does not include "16")
	kek_4x4			db		8,5,5,8,5,8,8,5,5,8,8,5,8,5,5,8

	; 5x5 calculating for win (using tetrads)
	lol_5x5		db	4,3,2,1,	20,15,10,5,	24,18,12,6,	25,25,25,25,	\
				4,3,2,0,	21,16,11,6,	25,25,25,25,	25,25,25,25,	\
				4,3,1,0,	22,17,12,7,	25,25,25,25,	25,25,25,25,	\
				4,2,1,0,	23,18,13,8,	25,25,25,25,	25,25,25,25,	\
				3,2,1,0,	24,19,14,9,	20,16,12,8,	25,25,25,25,	\
				9,8,7,6,	20,15,10,0,	25,25,25,25,	25,25,25,25,	\
				9,8,6,5,	21,16,11,1,	24,18,12,0,	25,25,25,25,	\
				9,7,6,5,	22,17,12,2,	25,25,25,25,	25,25,25,25,	\
				9,8,7,5,	23,18,13,3,	20,16,12,4,	25,25,25,25,	\
				8,7,6,5,	24,19,14,4,	25,25,25,25,	25,25,25,25,	\
				14,13,12,11,	20,15,5,0,	25,25,25,25,	25,25,25,25,	\
				14,13,12,10,	21,16,6,1,	25,25,25,25,	25,25,25,25,	\
				14,13,11,10,	22,17,7,2,	24,18,6,0,	20,16,8,4,	\
				14,12,11,10,	23,18,8,3,	25,25,25,25,	25,25,25,25,	\
				13,12,11,10,	24,19,9,4,	25,25,25,25,	25,25,25,25,	\
				19,18,17,16,	20,10,5,0,	25,25,25,25,	25,25,25,25,	\
				19,18,17,15,	21,11,6,1,	20,12,8,4,	25,25,25,25,	\
				19,18,16,15,	22,12,7,2,	25,25,25,25,	25,25,25,25,	\
				19,17,16,15,	23,13,8,3,	24,12,6,0,	25,25,25,25,	\
				18,17,16,15,	24,14,9,4,	25,25,25,25,	25,25,25,25,	\
				24,23,22,21,	15,10,5,0,	16,12,8,4,	25,25,25,25,	\
				24,23,22,20,	16,11,6,1,	25,25,25,25,	25,25,25,25,	\
				24,23,21,20,	17,12,7,2,	25,25,25,25,	25,25,25,25,	\
				24,22,21,20,	18,13,8,3,	25,25,25,25,	25,25,25,25,	\
				23,22,21,20,	19,14,9,4,	18,12,6,0,	25,25,25,25
	top_5x5			equ		lol_5x5+24 	; up to 25 moves can be played
	; Relates to how many inputs can be combined in tetrads (does not include "25")
	kek_5x5		db	11,7,7,7,11,7,11,7,11,7,7,7,15,7,7,7,11,7,11,7,11,7,7,7,11

section .text					; Code
global	_start					; Export entry point
	
print_int:						; ecx: const char* msg, edx: size_t msgl
	mov		eax,4				; System call number (sys_write)
	mov		ebx,1				; First argument: file descriptor (stdout == 1)
	int		0x80				; Call kernel
 ret

read_int:						; ecx: char* msg, ; edx: size_t msgl
	mov		eax,3				; System call number (sys_read)
	xor		ebx,ebx				; First argument: file descriptor (stdin == 0)
	int		0x80				; Call kernel
 ret

validate:			;used in conjunction with convert to set decimal of the input string
	xor 		ecx, ecx
	xor		eax, eax
	movzx		ecx, byte [buffer+1]
	movzx		eax, byte [buffer]
	sub		ax,'0'				; Poor man's atoi
 ret
	
bomb_err:
	call invalid_bomb
set_bomb:
	; Prompt player 1 for their bomb location
	mov		ecx,mPXO			; Second argument: pointer to message to write
	mov		edx,mPXOl			; Third argument: message length
    call	print_int
	mov		ecx,mbomb
	mov		edx,mbombl
     call	print_int
	; Read their desired location
	mov		ecx,buffer
	mov		edx,8
     call 	read_int
	xor 		ecx, ecx
	xor		eax, eax
	movzx		ecx, byte [buffer+1]
	movzx		eax, byte [buffer]
	sub		ax,'0'				; Poor man's atoi
	; convert number before saving it
	cmp		ecx,0xA
  je	ret_bomb
	cmpb		[buffer+2],0xA			; Checks for entries using 3 or more digits
  jne 	bomb_err		
     call	convert
ret_bomb: 					; Checks which bomb is being saved
	cmpb		[mPXO+spot],'X'
  jne	ret_pO	
ret_pX:	
	movw		[pXbomb],ax
 ret
ret_pO:
	movw		[pObomb],ax
 ret	
	
convert:			;only works for 2-digit numbers
	sub		cx,'0'		
	mov		bl,10
	imul		bl
	add		ax, cx
 ret

bomb_hit:
	mov		ecx,mexplode
	mov		edx,mexplodel
     call	print_int
 ret
	
check_line_3x3:					; The offsets are expected in esi and edi
	mov		bl,[mPXO+spot]		; One mark
	add		bl,bl			; Two marks
	sub		bl,[board_3x3+esi]	; One mark
	sub		bl,[board_3x3+edi]	; Zero marks
  jz		win_3x3
 ret
check_line_4x4:					; The offsets are expected in esi, edi and edx
	xor		bx,bx
	mov		bh,[mPXO+spot]		; One mark
	mov		bl,bh
	add		bl,bl			; Two marks
	add		bl,bh			; Three marks	
	sub		bl,[board_4x4+esi]	; Two marks
	sub		bl,[board_4x4+edi]	; One mark
	sub		bl,[board_4x4+edx]	; Zero marks
  jz		win_4x4
 ret
check_line_5x5:					; The offsets are expected in esi, edi, dx
		push	rbx
	xor		bx,bx
	mov		bl,[mPXO+spot]		; One mark
	add		bl,bl			; Two marks
	add		bl,bl			; Four marks	
	sub		bl,[board_5x5+esi]	; Three marks
	sub		bl,[board_5x5+edi]	; Two mark
	sub		bl,[board_5x5+edx]	; One mark
		pop	rdx
	sub		bl,[board_5x5+edx]	; Zero marks
  jz		win_5x5
 ret

; Setting bomb locations on final board 
tie_3x3:
	mov		eax,[pXbomb]
	movb		[board_3x3+eax],'1' ;1 represents player 1's bomb
	mov		eax,[pObomb]
	movb		[board_3x3+eax],'2' ;2 represents player 2's bomb
  jmp	tie
tie_4x4:
	mov		eax,[pXbomb]
	movb		[board_4x4+eax],'1'
	mov		eax,[pObomb]
	movb		[board_4x4+eax],'2'
  jmp	tie
tie_5x5:
	mov		eax,[pXbomb]
	movb		[board_5x5+eax],'1'
	mov		eax,[pObomb]
	movb		[board_5x5+eax],'2'
; Fallthrough 
tie:						; No return, (it's a tie)
	mov		ecx,mtie		; Second argument: pointer to message to write
	mov		edx,mtiel+mfinall	; Third argument: message length
    call	print_int
  jmp			pfinalb
	
check_bomb_3x3:
; Player can be identified by their mark ('X','O')
	cmpb		bl,'X'	; Assumes player's mark is saved in bl
  jne	pO_3x3
pX_3x3:	
	cmpd		eax,[pObomb] ; Checks if player 1 hit player 2's bomb
  jne	no_bomb
	; Bombs are revealed on board
	mov		eax,[pXbomb]
	movb		[board_3x3+eax],'1'
	mov		eax,[pObomb]
	movb		[board_3x3+eax],'@'
	xorb		[mPXO+spot],magic	; Ready the other player's mark
     call	bomb_hit
  jmp	win
pO_3x3:	
	cmpd		eax,[pXbomb] ; Checks if player 2 hit player 1's bomb
  jne	no_bomb
	; Bombs are revealed on board
	mov		eax,[pObomb]
	movb		[board_3x3+eax],'2'
	mov		eax,[pXbomb]
	movb		[board_3x3+eax],'!'
	xorb		[mPXO+spot],magic	; Ready the other player's mark
     call	bomb_hit
  jmp	win

check_bomb_4x4:
; Player can be identified by their mark ('X','O')
	cmpb		bl,'X'	; Assumes player's mark is saved in bl
  jne	pO_4x4
pX_4x4:	
	cmpd		eax,[pObomb] ; Checks if player 1 hit player 2's bomb
  jne	no_bomb
	; Bombs are revealed on board
	mov		eax,[pXbomb]
	movb		[board_4x4+eax],'1'
	mov		eax,[pObomb]
	movb		[board_4x4+eax],'@'
	xorb		[mPXO+spot],magic	; Ready the other player's mark
     call	bomb_hit
  jmp	win
pO_4x4:	
	cmpd		eax,[pXbomb] ; Checks if player 2 hit player 1's bomb
  jne	no_bomb
	; Bombs are revealed on board
	mov		eax,[pObomb]
	movb		[board_4x4+eax],'2'
	mov		eax,[pXbomb]
	movb		[board_4x4+eax],'!'
	xorb		[mPXO+spot],magic	; Ready the other player's mark
     call	bomb_hit
  jmp	win

check_bomb_5x5:
; Player can be identified by their mark ('X','O')
	cmpb		bl,'X'	; Assumes player's mark is saved in bl
  jne	pO_5x5
pX_5x5:	
	cmpd		eax,[pObomb] ; Checks if player 1 hit player 2's bomb
  jne	no_bomb
	; Bombs are revealed on board
	mov		eax,[pXbomb]
	movb		[board_5x5+eax],'1'
	mov		eax,[pObomb]
	movb		[board_5x5+eax],'@'
	xorb		[mPXO+spot],magic	; Ready the other player's mark
     call	bomb_hit
  jmp	win
pO_5x5:	
	cmpd		eax,[pXbomb] ; Checks if player 2 hit player 1's bomb
  jne	no_bomb
	; Bombs are revealed on board
	mov		eax,[pObomb]
	movb		[board_5x5+eax],'2'
	mov		eax,[pXbomb]
	movb		[board_5x5+eax],'!'
	xorb		[mPXO+spot],magic	; Ready the other player's mark
     call	bomb_hit
  jmp	win
	
no_bomb:
 ret

; Setting bomb locations on final board 
win_3x3:
	mov		eax,[pXbomb]
	movb		[board_3x3+eax],'1'
	mov		eax,[pObomb]
	movb		[board_3x3+eax],'2'
  jmp	win
win_4x4:
	mov		eax,[pXbomb]
	movb		[board_4x4+eax],'1'
	mov		eax,[pObomb]
	movb		[board_4x4+eax],'2'
  jmp	win
win_5x5:
	mov		eax,[pXbomb]
	movb		[board_5x5+eax],'1'
	mov		eax,[pObomb]
	movb		[board_5x5+eax],'2'
;Fallthrough 
win:						; No return, (someone won)
	mov		ecx,mPXO			; Second argument: pointer to message to write
	mov		edx,mPXOl			; Third argument: message length
    call	print_int
	mov		ecx,mwin2			; Second argument: pointer to message to write
	mov		edx,mwin2l			; Third argument: message length
    call	print_int
	mov		ecx,mfinal			; Second argument: pointer to message to write
	mov		edx,mfinall			; Third argument: message length
    call	print_int
; Fallthrough
pfinalb:						; No return, (print final board and exit)
	call	[pfunc]
	mov		eax,1				; System call number (sys_exit)
	xor		ebx,ebx				; First syscall argument: exit code
	int		0x80				; Call kernel
; No ret

; For a 3x3 Game Debug: 
debug_board_3x3:
	mov		ecx,dbd1_3x3			; Second argument: pointer to message to write
	mov		edx,dbd1l_3x3+bdl_3x3+dbd2l_3x3		; Third argument: message length
    call	print_int
	mov		ecx,8				; Locations
hexboard_3x3:
	mov		bl,[board_3x3+ecx]
	mov		dx,'20'
	cmp		bl,' '
	cmove	ax,dx
	mov		dx,'58'
	cmp		bl,'X'
	cmove	ax,dx
	mov		dx,'4F'
	cmp		bl,'O'
	cmove	ax,dx
	mov		[eboard+2*ecx+ecx],al
	mov		[eboard+2*ecx+ecx+1],ah
	dec		ecx
  jns		hexboard_3x3
	;Printing heaxboard
	mov		ecx,ebd1_3x3			; Second argument: pointer to message to write
	mov		edx,ebd1l_3x3		; Third argument: message length
    call	print_int
	mov		ecx,eboard		; Second argument: pointer to message to write
	mov		edx,el+ebd2l		; Third argument: message length
    call	print_int
	mov		ecx,mbd1			; Second argument: pointer to message to write
	mov		edx,mbd1l+ml+mbd2l	; Third argument: message length
    call	print_int
	mov		rsi,board_3x3
	mov		rdi,mbd3
memboard_3x3:
	incb	[rdi+3]				; Counter
	mov		bl,[rsi]			; Mark (ASCII)
	mov		[rdi+10],bl
	mov		dx,'20'
	cmp		bl,' '
	cmove	ax,dx
	mov		dx,'58'
	cmp		bl,'X'
	cmove	ax,dx
	mov		dx,'4F'
	cmp		bl,'O'
	cmove	ax,dx
	mov		[rdi+6],ax			; Mark (hex)
	mov		ecx,mbd3			; Second argument: pointer to message to write
	mov		edx,mbd3l			; Third argument: message length
    call	print_int
	inc		rsi
	cmp		rsi,board_3x3+9
  jne		memboard_3x3
	movb	[rdi+3],'/'			; Reset counter
 ret

; Printing a 3x3 game board: 
print_board_3x3:
	xor		esi,esi				; Row
nrow_3x3:
	mov		edi,2				; Col
ncol_3x3:
	mov		dl,[board_3x3+esi+edi]	; Src
	mov		[pbd1_3x3+edi*2],dl		; Dst
	dec		edi
  jns		ncol_3x3				; Three columns
	mov		ecx,pbd1_3x3			; Second argument: pointer to message to write
	add		esi,3				; Next row
	cmp		esi,9				; Last row
  je		pdone_3x3
	mov		edx,pbd1l_3x3+pbd2l_3x3		; Third argument: message length
    call	print_int
  jmp		nrow_3x3

pdone_3x3:
	mov		edx,pbd1l_3x3			; Third argument: message length
    call	print_int
 ret

; For a 4x4 Game Debug: 
debug_board_4x4:
	mov		ecx,dbd1_4x4			; Second argument: pointer to message to write
	mov		edx,dbd1l_4x4+bdl_4x4+dbd2l_4x4		; Third argument: message length
    call	print_int
	mov		ecx,15				; Locations
hexboard_4x4:
	mov		bl,[board_4x4+ecx]
	mov		dx,'20'
	cmp		bl,' '
	cmove	ax,dx
	mov		dx,'58'
	cmp		bl,'X'
	cmove	ax,dx
	mov		dx,'4F'
	cmp		bl,'O'
	cmove	ax,dx
	mov		[eboard+2*ecx+ecx],al
	mov		[eboard+2*ecx+ecx+1],ah
	dec		ecx
  jns		hexboard_4x4
	;Printing heaxboard
	mov		ecx,ebd1_4x4			; Second argument: pointer to message to write
	mov		edx,ebd1l_4x4		; Third argument: message length
    call	print_int
	mov		ecx,eboard		; Second argument: pointer to message to write
	mov		edx,el+ebd2l		; Third argument: message length
    call	print_int
	mov		ecx,mbd1			; Second argument: pointer to message to write
	mov		edx,mbd1l+ml+mbd2l	; Third argument: message length
    call	print_int
	mov		rsi,board_4x4
	mov		rdi,mbd3
memboard_4x4:
	incb	[rdi+3]				; Counter
	mov		bl,[rsi]			; Mark (ASCII)
	mov		[rdi+10],bl
	mov		dx,'20'
	cmp		bl,' '
	cmove	ax,dx
	mov		dx,'58'
	cmp		bl,'X'
	cmove	ax,dx
	mov		dx,'4F'
	cmp		bl,'O'
	cmove	ax,dx
	mov		[rdi+6],ax			; Mark (hex)
	mov		ecx,mbd3			; Second argument: pointer to message to write
	mov		edx,mbd3l			; Third argument: message length
    call	print_int
	inc		rsi
	cmp		rsi,board_4x4+9
  jne		memboard_4x4
	movb	[rdi+3],'/'			; Reset counter
 ret

; Printing 4x4 game board: 
print_board_4x4:
	xor		esi,esi				; Row
nrow_4x4:
	mov		edi,3				; Col
ncol_4x4:
	mov		dl,[board_4x4+esi+edi]		; Src
	mov		[pbd1_4x4+edi*2],dl		; Dst
	dec		edi
  jns		ncol_4x4				; Four columns
	mov		ecx,pbd1_4x4			; Second argument: pointer to message to write
	add		esi,4				; Next row
	cmp		esi,16				; Last row
  je		pdone_4x4
	mov		edx,pbd1l_4x4+pbd2l_4x4		; Third argument: message length
    call	print_int
  jmp		nrow_4x4

pdone_4x4:
	mov		edx,pbd1l_4x4			; Third argument: message length
    call	print_int
 ret

; For a 5x5 game:  
print_board_5x5:
	xor		esi,esi				; Row
nrow_5x5:
	mov		edi,4				; Col
ncol_5x5:
	mov		dl,[board_5x5+esi+edi]		; Src
	mov		[pbd1_5x5+edi*2],dl		; Dst
	dec		edi
  jns		ncol_5x5				; Four columns
	mov		ecx,pbd1_5x5			; Second argument: pointer to message to write
	add		esi,5				; Next row
	cmp		esi,25				; Last row
  je		pdone_5x5
	mov		edx,pbd1l_5x5+pbd2l_5x5		; Third argument: message length
    call	print_int
  jmp		nrow_5x5

pdone_5x5:
	mov		edx,pbd1l_5x5			; Third argument: message length
    call	print_int
 ret

; Error message for bomb location 
invalid_bomb:
	mov		ecx,mbomb_err
	mov		edx,mbomb_errl
    call	print_int
 ret
	
; Game Start 
_start:
	; Enable debug?
	mov		ecx,mdbg			; Second argument: pointer to message to write
	mov		edx,mdbgl			; Third argument: message length
    call	print_int
	; Read answer
	mov		ecx,dbuffer			; Store input at location 'buffer'
	mov		edx,8 				; Read these many bytes
    call	read_int

	; Choose what kind of game to play
	mov		ecx,mb_size			; Second argument: pointer to message to write
	mov		edx,mb_sizel			; Third argument: message length
    call	print_int
	; Read answer
	mov		ecx,buffer			; Store input at location 'buffer'
	mov		edx,8 				; Read these many bytes
    call	read_int
	; Switch case
	cmpb 		[buffer+1],0xA
  jne		invalid_bsize
	cmpb 		[buffer],'3'
  je		game_3x3
	cmpb		[buffer],'4'
  je		game_4x4
	cmpb		[buffer],'5'
  je		game_5x5

; Invalid board size given
invalid_bsize:	
	mov		ecx,msz_err			; Second argument: pointer to message to write
	mov		edx,msz_errl			; Third argument: message length
    call	print_int
  jmp	_start

; Game used for a 3x3 board 
game_3x3:
; Player 1 places their bomb 
pXbomb_3x3:	
     call	set_bomb
;Checks for valid input, if invalid reprompts user
	cmpb		al,8
  jbe	switch_pO_3x3
    call	invalid_bomb
  jmp	pXbomb_3x3

; Player 2 places their bomb 
switch_pO_3x3:
	xorb		[mPXO+spot],magic	; Switch marks for next player
pObomb_3x3:	
    call	set_bomb
;Checks for valid input
	cmpb		al,8
  jbe	check_debug_3x3
    call	invalid_bomb
  jmp	pObomb_3x3

; Game continues after picking bomb location 
check_debug_3x3:
	xorb		[mPXO+spot],magic	; Switch marks for next player
	; Switch case
	cmpb 		[dbuffer],'Y'
  je		do_debug_3x3
	cmpb		[dbuffer],'y'
  je		do_debug_3x3
	cmpb		[dbuffer],'D'
  je		do_debug_3x3
	cmpb		[dbuffer],'d'
  je		do_debug_3x3
	; Default
	movq		[pfunc],print_board_3x3
  jmp		play_3x3
do_debug_3x3:
	movq		[pfunc],debug_board_3x3
	mov		ecx,15				; Offset of last hexdigit of address
	mov		rdx, board_3x3			; rdx will be tampered with
	mov		rbx, hexdigits			; Table
memheader_3x3:
	mov		rax,rdx				; Need nibble in al
	and		rax,0x000000000000000f
	xlatb						; al updated
	mov byte		[mboard+ecx],al
	dec		ecx
	mov		rax,rdx				; Need nibble in al
	and		rax,0x00000000000000f0
	shr		rax,4				; This time, higher nibble
	xlatb						; al updated
	mov byte		[mboard+ecx],al
	shr		rdx,8				; Next byte (two nibbles)
	dec		ecx
  jns		memheader_3x3
  jmp		play_3x3
invalid_3x3:
	mov		ecx,merr			; Second argument: pointer to message to write
	mov		edx,merrl			; Third argument: message length
     call	print_int
; Fallthrough
play_3x3:
	; Print messages and board
	mov		ecx,mPXO			; Second argument: pointer to message to write
	mov		edx,mPXOl+mplay2l_3x3		; Third argument: message length
     call	print_int
     call	[pfunc]
	; Read input
	mov		ecx,buffer			; Store input at location 'buffer'
	mov		edx,8 				; Read these many bytes
     call	read_int
    ; Validate and convert (necessary to check two digit numbers)
     call	validate
	cmp		cx,0xA
  je		check_range_3x3
	cmpb		[buffer+2],0xA
  jne		invalid_3x3
     call 	convert
check_range_3x3:	
	cmp		al,8
  ja		invalid_3x3
	; Range is valid
	cmpb	[board_3x3+eax],' '		; Is empty?
  jne		invalid_3x3
	; Move is fully valid
	mov		bl,[mPXO+spot]
	mov		[board_3x3+eax],bl		; Place mark

    ; Check if bomb hit before winning move 
    call check_bomb_3x3
	; Check if winning move
	movzx		ecx, byte [kek_3x3+eax]	; Terms (adjusted)
pair:
	movzx		esi, byte [lol_3x3+eax*8+ecx]
	dec		ecx
	movzx		edi, byte [lol_3x3+eax*8+ecx]
    call	check_line_3x3
	dec		ecx
  jns		pair				; Next term pair
	decb		[top_3x3]		; Check if tie
  jz		tie_3x3
	xorb		[mPXO+spot],magic	; Ready the other player's mark
  jmp			play_3x3

; Game used for a 4x4 board 
game_4x4:
	
; Player 1 places their bomb 
pXbomb_4x4:	
     call	set_bomb	
;Checks for valid input, if invalid reprompts user
	cmpb		al,15
  jbe	switch_pO_4x4
    call	invalid_bomb
  jmp	pXbomb_4x4

; Player 2 places their bomb 
switch_pO_4x4:
	xorb		[mPXO+spot],magic	; Switch marks for next player
pObomb_4x4:	
    call	set_bomb
;Checks for valid input
	cmpb		al,15
  jbe	check_debug_4x4
    call	invalid_bomb
  jmp	pObomb_4x4

; Game continues after picking bomb location 
check_debug_4x4:
	xorb		[mPXO+spot],magic	; Switch marks for next player
	; Switch case
	cmpb 		[dbuffer],'Y'
  je		do_debug_4x4
	cmpb		[dbuffer],'y'
  je		do_debug_4x4
	cmpb		[dbuffer],'D'
  je		do_debug_4x4
	cmpb		[dbuffer],'d'
  je		do_debug_4x4
	; Default
	movq		[pfunc],print_board_4x4
  jmp		play_4x4
do_debug_4x4:
	movq		[pfunc],debug_board_4x4
	mov		ecx,15				; Offset of last hexdigit of address
	mov		rdx, board_4x4			; rdx will be tampered with
	mov		rbx, hexdigits			; Table
memheader_4x4:	
	mov		rax,rdx				; Need nibble in al
	and		rax,0x000000000000000f
	xlatb						; al updated
	mov 		byte[mboard+ecx],al
	dec		ecx
	mov		rax,rdx				; Need nibble in al
	and		rax,0x00000000000000f0
	shr		rax,4				; This time, higher nibble
	xlatb						; al updated
	mov 		byte[mboard+ecx],al
	shr		rdx,8				; Next byte (two nibbles)
	dec		ecx
  jns		memheader_4x4
  jmp		play_4x4

invalid_4x4:
	mov		ecx,merr			; Second argument: pointer to message to write
	mov		edx,merrl			; Third argument: message length
    call	print_int
; Fallthrough
play_4x4:
	; Print messages and board
	mov		ecx,mPXO			; Second argument: pointer to message to write
	mov		edx,mPXOl			; Third argument: message length
    call	print_int
	mov		ecx,mplay2_4x4			
	mov		edx,mplay2l_4x4	
    call	print_int
    call	[pfunc]
	; Read input
	mov		ecx,buffer			; Store input at location 'buffer'
	mov		edx,8 				; Read these many bytes
    call	read_int
	; Validate and convert
    call	validate
	cmp		cx,0xA
  je		check_range_4x4
	cmpb		[buffer+2],0xA
  jne		invalid_4x4
     call 	convert
check_range_4x4:	
	cmp		al,15
  ja		invalid_4x4
	; Range is valid
	cmpb	[board_4x4+eax],' '			; Is empty?
  jne		invalid_4x4
	; Move is fully valid
	mov		bl,[mPXO+spot]
	mov		[board_4x4+eax],bl		; Place mark

    ; Check if bomb hit before winning move 
    call check_bomb_4x4
	
	; Check if winning move
	movzx		ecx, byte [kek_4x4+eax]		; Terms (adjusted)

triad:
	mov		ebx,ecx
	add		ebx,eax

	movzx		esi, byte [lol_4x4+eax*8+ebx]
	dec		ebx
	dec		ecx
	movzx		edi, byte [lol_4x4+eax*8+ebx]
	dec		ebx
	dec		ecx
	movzx		edx, byte [lol_4x4+eax*8+ebx]
    call	check_line_4x4
	dec		ecx
  jns		triad				; Next term triad
    	decb 		[top_4x4]			; Check if tie
  jz		tie_4x4
	xorb		[mPXO+spot],magic	; Ready the other player's mark
  jmp		play_4x4

	
; Game used for a 5x5 board 
game_5x5:
	
; Player 1 places their bomb 
pXbomb_5x5:	
     call	set_bomb	
;Checks for valid input, if invalid reprompts user
	cmpb		al,24
  jbe	switch_pO_5x5
    call	invalid_bomb
  jmp	pXbomb_5x5

; Player 2 places their bomb 
switch_pO_5x5:
	xorb		[mPXO+spot],magic	; Switch marks for next player
pObomb_5x5:	
	call	set_bomb
;Checks for valid input
	cmpb		al,24
  jbe	check_debug_5x5
    call	invalid_bomb
  jmp	pObomb_5x5

; Game continues after picking bomb location 
check_debug_5x5:
	xorb		[mPXO+spot],magic	; Switch marks for next player
	; Switch case
	cmpb 		[dbuffer],'Y'
  je		do_debug_5x5
	cmpb		[dbuffer],'y'
  je		do_debug_5x5
	cmpb		[dbuffer],'D'
  je		do_debug_5x5
	cmpb		[dbuffer],'d'
  je		do_debug_5x5
	; Default
	movq		[pfunc],print_board_5x5
  jmp		play_5x5
do_debug_5x5:
	;movq		[pfunc],debug_board_5x5
	mov		ecx,15				; Offset of last hexdigit of address
	mov		rdx, board_4x4			; rdx will be tampered with
	mov		rbx, hexdigits			; Table
memheader_5x5:	
	mov		rax,rdx				; Need nibble in al
	and		rax,0x000000000000000f
	xlatb						; al updated
	mov 		byte[mboard+ecx],al
	dec		ecx
	mov		rax,rdx				; Need nibble in al
	and		rax,0x00000000000000f0
	shr		rax,4				; This time, higher nibble
	xlatb						; al updated
	mov 		byte[mboard+ecx],al
	shr		rdx,8				; Next byte (two nibbles)
	dec		ecx
  jns		memheader_5x5
  jmp		play_5x5

invalid_5x5:
	mov		ecx,merr			; Second argument: pointer to message to write
	mov		edx,merrl			; Third argument: message length
    call	print_int
; Fallthrough
play_5x5:
	; Print messages and board
	mov		ecx,mPXO			; Second argument: pointer to message to write
	mov		edx,mPXOl			; Third argument: message length
    call	print_int
	mov		ecx,mplay2_5x5			
	mov		edx,mplay2l_5x5	
    call	print_int
    call	[pfunc]
	; Read input
	mov		ecx,buffer			; Store input at location 'buffer'
	mov		edx,8 				; Read these many bytes
    call	read_int
	; Validate and convert
    call	validate
	cmp		cx,0xA
  je		check_range_5x5
	cmpb		[buffer+2],0xA
  jne		invalid_5x5
     call 	convert
check_range_5x5:	
	cmp		al,24
  ja		invalid_4x4
	; Range is valid
	cmpb	[board_5x5+eax],' '			; Is empty?
  jne		invalid_5x5
	; Move is fully valid
	mov		bl,[mPXO+spot]
	mov		[board_5x5+eax],bl		; Place mark

    ; Check if bomb hit before winning move 
    call check_bomb_5x5
	
	; Check if winning move
	movzx		ecx, byte [kek_5x5+eax]		; Terms (adjusted)
tetrad:
	xor	rbx,rbx
	xor	rdx,rdx
		push	rcx		;Holds original count in stack
		push	rax		;Holds original input in stack
	mov	bl,8
	imul	bl
	add		ecx,eax	;Calculates difference in lol_5x5 rows
		pop	rax		;Returns original input

	movzx		esi, byte [lol_5x5+eax*8+ecx]
	dec		ecx
	movzx		edi, byte [lol_5x5+eax*8+ecx]
	dec		ecx
	movzx		edx, byte [lol_5x5+eax*8+ecx]
	dec		ecx
	movzx		ebx, byte [lol_5x5+eax*8+ecx]
	
		pop	rcx	; Adjusting ecx to reflect actual count
	dec		ecx
	dec		ecx
	dec		ecx
    call	check_line_5x5
	dec		ecx
  jns		tetrad				; Next term tetrad
    	decb 		[top_5x5]			; Check if tie
  jz		tie_5x5
	xorb		[mPXO+spot],magic	; Ready the other player's mark
  jmp		play_5x5
