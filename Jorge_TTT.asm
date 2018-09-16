; CMPE 310 - Fall 2017 - Project 1 - TicTacToe
; Jorge Teixeira
; jt11@umbc.edu

%define cmpb	cmp byte
%define decb	dec byte
%define incb	inc byte
%define xorb	xor byte
%define movb	mov byte
%define movq	mov qword

section .bss					; Uninitialized data
	buffer		resb	4
	pfunc		resq	1

section .data					; Initialized data
	mdbg		db		"Do you want to enable debug information?", 0xA
	mdbgl		equ		$ - mdbg

	mPXO		db		"Player X"
	mPXOl		equ		$ - mPXO
	mplay2		db		", choose your location (0-8):", 0xA, "Current board:", 0xA
	mplay2l		equ		$ - mplay2
	mwin2		db		" wins!", 0xA
	mwin2l		equ		$ - mwin2
	spot		equ		7		; Offset of X/O
	magic		equ		0x17	; Magic! =D

	mtie		db		"It's a draw (tie)!", 0xA
	mtiel		equ		$ - mtie
	mfinal		db		"Final board:", 0xA
	mfinall		equ		$ - mfinal
	merr		db		"That location is out of range or already taken.", 0xA
	merrl		equ		$ - merr

	pbd1		db		" | | ", 0xA
	pbd1l		equ		$ - pbd1
	pbd2		db		"-----", 0xA
	pbd2l		equ		$ - pbd2

	dbd1		db		" 012345678 ", 0xA, "["
	dbd1l		equ		$ - dbd1
	board		db		"         "	; 3x3 linearized game board
	bdl			equ		$ - board
	dbd2		db		"]", 0xA
	dbd2l		equ		$ - dbd2

	ebd1		db		"Current board (hex):", 0xA, "  0  1  2  3  4  5  6  7  8 ", 0xA, "["
	ebd1l		equ		$ - ebd1
	eboard		db		"20 58 20 4F 20 58 20 20 4F"	; Hex linearized game board
	el			equ		$ - eboard
	ebd2		db		"]", 0xA
	ebd2l		equ		$ - ebd2

	hexdigits	db		'0123456789ABCDEF'
	mbd1		db		"Current board (mem):", 0xA, "&board = 0x"
	mbd1l		equ		$ - mbd1
	mboard		db		"FFFFFFFFFFFFFFFF"
	ml			equ		$ - mboard
	mbd2		db		0xA, "+offset / hex / ASCII", 0xA
	mbd2l		equ		$ - mbd2
	mbd3		db		"0x0/: 58h X", 0xA	; The '/' is not a typo
	mbd3l		equ		$ - mbd3

	lol			db		2,1,6,3,8,4,9,9, \
						2,0,7,4,9,9,9,9, \
						1,0,8,5,6,4,9,9, \
						5,4,6,0,9,9,9,9, \
						5,3,7,5,8,0,6,2, \
						4,3,8,2,9,9,9,9, \
						8,7,3,0,4,2,9,9, \
						8,6,5,4,9,9,9,9, \
						7,6,5,2,4,0,9,9
	top			equ		lol+7
	kek			db		5,3,5,3,7,3,5,3,5

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

check_line:						; The offsets are expected in esi and edi
	mov		bl,[mPXO+spot]		; One mark
	add		bl,bl				; Two marks
	sub		bl,[board+esi]		; One mark
	sub		bl,[board+edi]		; Zero marks
	jz		win
ret

tie:							; No return, (it's a tie)
	mov		ecx,mtie			; Second argument: pointer to message to write
	mov		edx,mtiel+mfinall	; Third argument: message length
	call	print_int
jmp			pfinalb

win:							; No return, (someone won)
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

debug_board:
	mov		ecx,dbd1			; Second argument: pointer to message to write
	mov		edx,dbd1l+bdl+dbd2l	; Third argument: message length
	call	print_int
	mov		ecx,8				; Locations
hexboard:
	mov		bl,[board+ecx]
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
	jns		hexboard
	mov		ecx,ebd1			; Second argument: pointer to message to write
	mov		edx,ebd1l+el+ebd2l	; Third argument: message length
	call	print_int
	mov		ecx,mbd1			; Second argument: pointer to message to write
	mov		edx,mbd1l+ml+mbd2l	; Third argument: message length
	call	print_int
	mov		rsi,board
	mov		rdi,mbd3
memboard:
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
	cmp		rsi,board+9
	jne		memboard
	movb	[rdi+3],'/'			; Reset counter
ret

print_board:
	xor		esi,esi				; Row
nrow:
	mov		edi,2				; Col
ncol:
	mov		dl,[board+esi+edi]	; Src
	mov		[pbd1+edi*2],dl		; Dst
	dec		edi
	jns		ncol				; Three columns
	mov		ecx,pbd1			; Second argument: pointer to message to write
	add		esi,3				; Next row
	cmp		esi,9				; Last row
	je		pdone
	mov		edx,pbd1l+pbd2l		; Third argument: message length
	call	print_int
	jmp		nrow
pdone:
	mov		edx,pbd1l			; Third argument: message length
	call	print_int
ret

_start:
	; Enable debug?
	mov		ecx,mdbg			; Second argument: pointer to message to write
	mov		edx,mdbgl			; Third argument: message length
	call	print_int
	; Read answer
	mov		ecx,buffer			; Store input at location 'buffer'
	mov		edx,2 				; Read these many bytes
	call	read_int
	; Switch case
	cmpb 	[buffer],'Y'
	je		do_debug
	cmpb	[buffer],'y'
	je		do_debug
	cmpb	[buffer],'D'
	je		do_debug
	cmpb	[buffer],'d'
	je		do_debug
	; Default
	movq	[pfunc],print_board
	jmp		play
do_debug:
	movq	[pfunc],debug_board
	mov		ecx,15				; Offset of last hexdigit of address
	mov		rdx, board			; rdx will be tampered with
	mov		rbx, hexdigits		; Table
memheader:
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
	jns		memheader
	jmp		play
invalid:
	mov		ecx,merr			; Second argument: pointer to message to write
	mov		edx,merrl			; Third argument: message length
	call	print_int
; Fallthrough
play:
	; Print messages and board
	mov		ecx,mPXO			; Second argument: pointer to message to write
	mov		edx,mPXOl+mplay2l	; Third argument: message length
	call	print_int
	call	[pfunc]
	; Read input
	mov		ecx,buffer			; Store input at location 'buffer'
	mov		edx,2; 				; Read these many bytes
	call	read_int
	; Validate
	movzx	eax, byte [buffer]
	sub		al,'0'				; Poor man's atoi
	cmp		al,8
	ja		invalid
	; Range is valid
	cmpb	[board+eax],' '		; Is empty?
	jne		invalid
	; Move is fully valid
	mov		bl,[mPXO + spot]
	mov		[board+eax],bl		; Place mark
	; Check if winning move
	movzx	ecx, byte [kek+eax]	; Terms (adjusted)
pair:
	movzx	esi, byte [lol+eax*8+ecx]
	dec		ecx
	movzx	edi, byte [lol+eax*8+ecx]
	call	check_line
	dec		ecx
	jns		pair				; Next term pair
	decb	[top]				; Check if tie
	jz		tie
	xorb	[mPXO+spot],magic	; Ready the other player's mark
jmp			play
