.model small
.data

file_path db 100 dup(0)
last_index dw 0
index_arr db 20 dup(0)
counter db 0
path db 100 dup(0)
bad_arguments_msg db "Error", 0dh, 0ah, "$"
program_path db 100 dup(0)
program_full_path db 100 dup(0)
EPB dw 0000
    dw offset commandline, 0
    dw 005ch, 0, 006ch, 0
commandline db 125
            db " /?"
command_text db 122 dup(?)

.stack 256

.code

output macro str
    lea dx, str
    mov ah, 9
    int 21h
output endm

start:
    mov ax, @data
    mov ds, ax

    
    ;jmp n99
    mov bl, es:[80h]
	add bx, 80h
	mov si, 82h
	mov di, offset file_path
	
	cmp si, bx
    ja bad_arguments
    
    get_path:
        cmp     BYTE PTR es:[si], '$' 
        je      n99
              
        mov     al, es:[si]
        mov     [di], al      
              
        inc     di
        inc     si
        cmp si, bx
    jbe get_path
	
    n99:

    lea di, file_path
    to_mask:
        cmp [di], 0
        je to_mask2
        inc di
        jmp to_mask
    to_mask2:
        mov [di], "*"
        inc di
        mov [di], "."
        inc di
        mov [di], "e"
        inc di
        mov [di], "x"
        inc di
        mov [di], "e"

    mov sp, program_length+100h+200h

    mov ah, 4ah
    stack_shift = program_length + 100h + 200h
    mov bx, stack_shift shr 4 + 1
    int 21h

    mov ax, cs
    mov word ptr EPB+4, ax
    mov word ptr EPB+8, ax
    mov word ptr EPB+0ch, ax
    
    xor ax, ax
    xor cx, cx
    mov ah, 4eh
    lea dx, file_path
    int 21h
    jc bad_arguments
    push 0
    lea di, program_full_path
    mov last_index, di
 
    n1:
    mov counter, 0
	mov si, 80h
    add si, 1eh
	mov di, offset program_path
    
    get_file:
        cmp     BYTE PTR es:[si], 0 
        je      n98
              
        mov     al, es:[si]
        mov     [di], al   
              
        inc     di
        inc     si
    jmp get_file
	
    n98:

open_prog:

    
    
    mov di, last_index
    lea si, file_path
    get_full_name:
        cmp [si], "*"
        je n2
        mov al, [si]
        mov [di], al
        inc counter
        inc si
        inc di
        jmp get_full_name

    n2:
        lea si, program_path
        get_full_name2:
            cmp [si], 0
            je n3
            mov al, [si]
            mov [di], al
            inc counter
            inc si
            inc di
            jmp get_full_name2

    n3:
        mov last_index, di
        pop ax
        lea di, index_arr
        add di, ax
        inc ax
        mov bl, counter
        mov [di], bl
        push ax

    xor ax, ax
    mov ah, 4fh
    int 21h
    jc n4
    jmp n1
    
    n4:


    lea di, index_arr
    xor cx, cx
    lea si, program_full_path
    get_counter_of_files:
        push di
        cmp [di], 0
        je exit
        mov cl, [di]
        lea di, path
        my_movsb:
            mov al, [si]
            mov [di], al
            inc si
            inc di
            loop my_movsb
        mov [di], 0
    
        mov ax, 4b00h
        mov dx, offset path
        mov bx, offset EPB
        int 21h

        pop di
        inc di
    jmp get_counter_of_files
        

    bad_arguments:
        output bad_arguments_msg

    exit:
    mov ax, 4C00H
    int 21h

program_length equ $-start
    end start