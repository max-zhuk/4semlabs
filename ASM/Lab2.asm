
.model small

.stack 100h

.data

max_string_size equ 200

message db max_string_size, ?, max_string_size dup ('?')

ent_str db "Enter string...", 0Dh, 0Ah, '$' 
inc_str db "Incorrect string", 0Dh, 0Ah, '$'

print_symb macro symb
    mov dl, symb  
    mov ah, 06h
    int 21h    
endm

.code     
begin: 
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	mov ah, 09h
	lea dx, ent_str
	int 21h
	
	
	mov ah, 0ah
    lea dx, message
    int 21h   
    
    
	
	xor bh, bh
	mov bl, message[1]
	inc bl
	inc bl
	   
	cmp message[3], '?'
	je RET1
	mov message[bx], 0 

	
	cld
	xor ch, ch
	mov cl, message[1]
	mov al, ' '         
    lea di, message[2]      
	xor dh, dh 
wordcount:       
    repe scasb
    jcxz break
    inc dl
    repne scasb
	jcxz check
    jmp wordcount
break:
	dec di                                                          
    cmp [di], al      
    je check
    inc dl
check:
	dec dl
	cmp dl, 0
	;jle nesort
	jg wordnumok
	jmp nesort
wordnumok:
	
	
	xor ch, ch
	mov cl, dl
sort:
	push cx
	xor dx, dx
	lea bx, message[2]
findword1:
	mov al, ' '
	;mov cx, max_string_size
	dec bx
skipspace:
	inc bx
	cmp [bx], al
	;inc bx
	je skipspace
	;dec bx
	
	mov si, bx ;remember 1-st word adress
	
skipword:
	inc bx
	inc dh
	cmp [bx], al
	jne skipword
	;dec bx
	;dec dl
	
findword2:
	;mov dh, dl ;2-nd word is now 1-st word
	xor dl, dl
	;mov si, di ;2-nd word is now 1-st word but address
	
                                                	;dh - 1-st word length
                                                	;dl - 2-nd word length
                                                	;si - 1-st word address
                                                	;di - 2-nd word address
	
skipspace2:
	mov al, ' '
	inc bx
	cmp [bx], al
	je skipspace2
	;dec bx
	
	mov di, bx ;remember 2-nd word adress
	
nextsym:
	cmp byte ptr [bx], ' '
	je tocmp
	cmp byte ptr [bx], 0
	je tocmp
	inc bx
	inc dl
	jmp nextsym
	
tocmp:
	
	push di
	push si
	push cx
	xor ch, ch
	mov cl, dh
	inc cx
tocmpbs:
	repe cmpsb
	dec di
	dec si
	cmp byte ptr [si], 'A'
	jb notb
	cmp byte ptr [si], 'z'
	ja notb
	cmp byte ptr [si], 'Z'
	ja neshigh
	mov al, [si]
	jmp todi
neshigh:
	cmp byte ptr [si], 'a'
	jb neslow
	mov al, [si]
	sub al, 32
	jmp todi
neslow:
	jmp notb
todi:
	cmp byte ptr [di], 'A'
	jb notb
	cmp byte ptr [di], 'z'
	ja notb
	cmp byte ptr [di], 'Z'
	ja nedhigh
	mov ah, [di]
	jmp tocmpb
nedhigh:
	cmp byte ptr [di], 'a'
	jb notb
	mov ah, [di]
	sub ah, 32
	
tocmpb:
	cmp al, ah
	jne torev
	inc si
	inc di
	jmp tocmpbs

notb:
	cmpsb
torev:
	pop cx
	pop si
	pop di
	jb skipswap
	
	push si
	push di
	
	mov di, si
	xor  ah, ah
	mov al, dh
	add di, ax
	dec di
reverseword1:
	mov al, [si]
	mov ah, [di]
	mov [si], ah
	mov [di], al
	inc si
	dec di
	cmp si, di
	jb reverseword1
	
	pop di
	
	mov si, di
	xor ah, ah
	mov al, dl
	add di, ax
	dec di
	
	push di
	
reverseword2:
	mov al, [si]
	mov ah, [di]
	mov [si], ah
	mov [di], al
	inc si
	dec di
	cmp si, di
	jb reverseword2
	
	pop di
	pop si
	mov bp, di
reversestring:
	mov al, [si]
	mov ah, [di]
	mov [si], ah
	mov [di], al
	inc si
	dec di
	cmp si, di
	jb reversestring
	;si in the right place
	mov si, bp
	xor ah, ah
	mov al, dh
	sub si, ax
	inc si
	jmp neskipswap
skipswap:
	mov si, di ;2-nd word is now 1-st word but address
	mov dh, dl ;2-nd word length is now 1-st word length
neskipswap:
	;loop findword2
	dec cx
	cmp cx, 0
	jbe nefindword2
	jmp findword2
nefindword2:
	pop cx
	;loop sort
	dec cx
	;test cx, cx
	cmp cx, 0
	;ja near ptr sort
	jbe nesort
	jmp sort
nesort:

	print_symb 0dh
	print_symb 0ah
	;mov dx, offset message[2]
	;mov ah, 9h
	;int 21h
	mov ah, 06h
	xor ch, ch
	mov cl, message[1]
	lea bx, message[2]
printstring:
	mov dl, [bx]
	int 21h
	inc bx
	loop printstring	
	mov ah, 4Ch
	int 21h
	
RET1:
	mov ah, 09h
	lea dx, inc_str
	int 21h
	
	mov ah, 4Ch
	int 21h	
end begin