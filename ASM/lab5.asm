.model small
.data   
file    db 30 dup(?)    
sizee equ 32000
resfilename db 'result.txt', 0 
buf	db 20,21 dup(0)
checkrename db '111.txt', 0 
buffer dw sizee dup(0)
identifier dw 1  
identifier2 dw 1
strSize dw 1
errorMessageR db "Error R!", 10, 13, '$' 
debug db "__________", 10, 13, '$'     
errorMessageA db "Error A!", 10, 13, '$'
errorMessageH db "Error H!", 10, 13, '$'
.stack 256
.code

output MACRO str
    mov ah, 09h
    mov dx, offset str
    int 21h
endm

fopen proc
    
    mov ah, 3Dh
    mov al, 2    
    lea dx, buf[2]
    int 21h
    
    jb endWithErrorH
       
    mov identifier, ax
   
    ret     
endp 

fopen2 proc
    
    mov ah, 3Dh
    mov al, 2
    lea dx, resfilename  
    int 21h
    
    jb endWithErrorH
       
    mov identifier2, ax
   
    ret     
endp

fread proc
    
    mov bx, identifier
    mov ah, 3Fh
    mov cx, sizee
    lea dx, buffer
    int 21h
    
    jb endWithErrorR
    
    ret    
endp  

fread2 proc
    
    mov bx, identifier
    mov ah, 3Fh
    mov cx, sizee
    lea dx, buffer
    int 21h
    
    jb endWithErrorA
    
    ret    
endp
fclose1 proc
    
    mov ah, 3Eh
    mov bx, identifier
    int 21h
    
    jb endWithErrorA
    
    ret
endp  
fclose2 proc
    
    mov ah, 3Eh
    mov bx, identifier2
    int 21h
    
    jb endWithErrorA
    
    ret
endp  
    
deleteEmptyStr proc
    
    lea di, buffer
    lea si, buffer
    push di
    
    searchFirstStr:
        cmp [di], 0
        je endDelete
        
        cmp [di], 13
        je next
        
        cmp [di], 10
        je next
        
        cmp [di], 32
        je next
        
        jmp endSearchFirstStr
        
        next:
        inc di
        jmp searchFirstStr
        
    endSearchFirstStr:
        cmp di, si
        je deleteNextStr
    
        cmp [di], 10
        je deleteFirstStr
        
        dec di
        jmp endSearchFirstStr

    deleteFirstStr:
        inc di
        lea si, buffer
        
        deleteFirstStrLoop:
             mov dl, [di]
             mov [si], dl
                
             inc si
             inc di
                
             cmp [di], 0
             jne deleteFirstStrLoop
             
        mov [si], 0
        
    deleteNextStr:    
        pop di 
    
    search:
        cmp [di], 0
        je endDelete
        
        cmp [di], 13
        je checkNext
        
        inc di
        jmp search        
                    
                    
        checkNext:
            mov si, di
            add si, 2
            mov ax, si
            inc di
            
        checkNextLoop:
            inc di
            cmp [di], 0
            je endDelete
            
            cmp [di], 13
            je delete
                                                                        cmp [di], 32
                                                                        je checkNextLoop
            mov di, ax
            jmp search
            
        delete:
            add di, 2
            
            loopDelete:
                mov dl, [di]
                mov [si], dl
                
                inc si
                inc di
                
                cmp [di], 0
                jne loopDelete
            
            mov [si], 0
            mov di, ax
            sub di, 2
            jmp search    
            
endDelete:
    ret
endp

getStrSize proc

    lea di, buffer
    xor cx, cx
    
    whileNotEnd:
        cmp [di], 0
        je endGetStrSize
        
        inc di
        inc cx                 
        jmp whileNotEnd

    endGetStrSize:
        mov strSize, cx
        ret            
    
endp

fwrite1 proc
    
   ; call fclose
    mov ah, 41h
    lea dx, resfilename
    int 21h
    
    mov ah, 3Ch
    mov cx, 00h
    lea dx, resfilename
    int 21h
    call fopen2
    
    mov ah, 40h
    mov bx, identifier2
    mov cx, strSize
    lea dx, buffer
    int 21h
    
    jb endWithErrorH 
    
    ret    
endp   
fwrite2 proc
    
   
   
    
    mov ah, 40h
    mov bx, identifier2
    mov cx, strSize
    lea dx, buffer
    int 21h
    
    jb endWithErrorH 
    
    ret    
endp
    
    







     
start:
    
    mov ax,@data	;настраиваем сегментный регистр
	mov ds,ax
	mov di,81h	;начало командной строки
	mov cl,es:[80h]	;длина командной строки
	mov ch,0
		;Если нет командной строки
			;то ввод имени файла
	mov al,' '
	repz scasb	;пропускаем пробелы перед параметром
		;если командная строка закончилась
	        ;то ввод имени файла
	dec di          ;корректируем указатель на командную строку
	inc cx		;и количество обработанных символов

	lea si,buf[2]	;начало имени входного файла
;копируем имя первого файла из командной строки в сегмент данных
lp11:	mov al,es:[di]	;читаем символ
	cmp al,' '	;если пробел
	jz kk		;то закончить копирование
	mov [si],al	;сохраняем символ в сегменте данных
	inc si		;Следующий символ
	inc di		;Следующий символ
	loop lp11
	kk:
	
    call fopen
    call fread
    call deleteEmptyStr
    call getStrSize
    call fwrite1
    
  again: 
    cld 
    lea di, buffer
    mov cx, sizee
    sub al, al
    rep stosb
    call fread2
    cmp ax,0
    je endWithoutError
    call deleteEmptyStr
    call getStrSize
    call fwrite2
    jmp again
    
    
    endWithErrorR:
        output errorMessageR
            mov ax,4c00h
            int 21h 
    endWithErrorH:
        output errorMessageH
            mov ax,4c00h
            int 21h
    endWithErrorA:
        output errorMessageA
            mov ax,4c00h
            int 21h
    endWithoutError: 
            call fclose1
            call fclose2           
           
            mov ax,4c00h
            int 21h
end start 
