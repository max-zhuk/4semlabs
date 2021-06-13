.model medium
 
.stack  200h
 
.data
        ;Данные
        msgPressAnyKey  db      0Dh, 0Ah, 'Press any key to exit...', '$'
        CrLf            db      0Dh, 0Ah, '$'
        asPrompt        db      'Enter an array:', 0Dh, 0Ah, '$'
        count           dw      100 dup(?)
        asShowArray     db      0Dh, 0Ah, 'Entered array:', 0Dh, 0Ah, '$'
        press1          db      0Dh, 0Ah, '1 ---> -n',0Dh, 0Ah, '$'
        press2          db      0Dh, 0Ah, '2 ---> n^2',0Dh, 0Ah, '$'
        press3          db      0Dh, 0Ah, '3 ---> |n|',0Dh, 0Ah, '$'
        press4          db      0Dh, 0Ah, '4 ---> 1/n',0Dh, 0Ah, '$'
        press5          db      0Dh, 0Ah, 'q ---> exit ',0Dh, 0Ah, '$' 
        overf           db      'Overflow(', '$' 
        IncString     db      'Incorrect input', '$'
        skob           db      ')', '$'
        iAverage        dw      ?
        N               dw      ?
        Array           dw      100 dup(?)  
        k8k     db      '32768', '$'
        

.code

ShowInt16 proc
        pusha
        mov bx,10
        xor cx,cx      ;символов в модуле числа
        or ax,ax
        jns div1
            neg ax
            push ax
            mov ah,02h                                                                      
            mov dl,'-'
            int 21h
            pop ax
            
        div1:
            xor dx,dx
            div bx
            push dx
            inc cx      ;количество цифр в числе
            or ax,ax
            
        jnz div1
        mov ah,02h
        
        store1: 
        
            pop dx
            add dl,'0'
            int 21h
            
        loop store1
        popa
        ret
ShowInt16 endp
 
;Вывод массива слов (word)
;cx - количество выводимых элементов
;ds:dx - адрес массива слов
ShowArray proc
        pusha
                 
                   
          
        
                 
        jcxz saExit        ;если массив пустой - завершить
          jo exit
        mov si,1       ;индекс элемента массива
        mov di,dx      ;адрес текущего элемента массива
        
        saForI:
            mov ax,[di]  
            cmp ax,0
            jne correct
            lea dx,[IncString]
            call printStr
            jmp exit 
            
            
    correct:
            call ShowInt16
            mov ah,02h
            mov dl,' '
            int 21h
            ;переход к следующему элементу
            inc si
            add di,2
            
        loop saForI
        
saExit:
        popa
        ret        
ShowArray endp

printStr proc
        pusha
            mov ah,9
            int 21h
        popa
        ret
printStr endp

invers proc
        pusha
        lea dx,CrLf         ;загрузка данных
        call printStr
        mov cx,[N]
        lea si,[Array]
        xor bx,bx
        xor di,di
        
        for1:
            lodsw
            cwd
            
            neg ax           ;меняем знак у элемента
            lea dx,ax
            call ShowInt16   ;вывод элемента
            
            pusha
                mov ah,2         ;добавление пробела
                xor dx,dx
                mov dl,32
                int 21h
            popa
        loop for1
        
        popa
        lea dx,CrLf
        call printStr
        ret    
invers endp

square proc
        pusha
        lea dx,CrLf        
        call printStr
        mov cx,[N]
        lea si,[Array]
        xor bx,bx
        xor di,di
        
        for2:
            lodsw
            cwd    
            
            
            cmp dx,-1
            je minsss
            cmp ax,181   ;181^2 < 32767 < 182^2   
            jle nooverf
            jmp overfff 
        minsss:
             cmp ax,-181     
            jge nooverf
              
        overfff:    
            lea dx, [overf] 
            call printStr
             mul ax           ;возводим в квадрат
            lea dx,ax
            call ShowInt16
            lea dx,[skob]
            call printStr
            jmp nextElement
            
            nooverf:
            mul ax           ;возводим в квадрат
            lea dx,ax
            call ShowInt16   ;вывод элемента   
            
            nextElement:
            pusha            
                mov ah,2
                xor dx,dx
                mov dl,32
                int 21h
            popa
        loop for2
        
        popa
        lea dx,CrLf        
        call printStr
        ret    
square endp

abs proc
        pusha
        lea dx,CrLf    
        call printStr
        mov cx,[N]
        lea si,[Array]
        xor bx,bx
        xor di,di
        
        for3:
            lodsw
            cwd
             
            
            cmp ax,8000h
            je skippps
            getAbs:         ;меняем знак
            neg ax
            js getAbs 
            skippps:      ;есть ли знак?
            lea dx,ax       
            call ShowInt16  ;вывод элемента
          rret:  
            pusha
                mov ah,2
                xor dx,dx
                mov dl,32
                int 21h
            popa
            
        loop for3
            
        popa 
        lea dx,CrLf         
        call printStr 
       
        ret
abs endp

invert proc
        pusha
        lea dx,CrLf    
        call printStr
        mov cx,[N]
        lea si,[Array]
        xor bx,bx
        xor di,di
        
        for4:
            lodsw            ;ax=n
            cwd
            
            cmp ax,0         ;проверяем знак
            jns pos
            min:             ;меняем знак если отрицательное число
                pusha
                mov ah,2
                mov dl,45
                int 21h
                popa
                neg ax
            
            pos:   
            mov bx,1         ;bx=1
            
            xchg ax,bx       ;swap(ax,bx)
            cmp bx,0
            jne next2
            loop for4
            
            next2:
            cwd
            
            cmp bx,0
            je exit
            
            idiv bx          ;ax=ax/bx=1/n ax-целая dx-остаток
               
            push ax          ;сохраняем целую часть
            push bx          ;сохраняем делитель
            push dx          ;сохраняем делимое(остаток)                   
            
            lea dx,ax        ;вывод целой части
            call ShowInt16   
            
            mov ah,2         ;вывод точки
            mov dl,'.'
            int 21h
            
            pop dx
            pop bx
            pop ax 
            
            push cx          ;сохраняем счётчик массива for4
            
            push ax
            push bx
            push dx
            
            mov cx,3         ;количество знаков после запятой
            
            for5:
                pop dx       ;возвращаем делимое(остаток)    
                pop bx       ;возвращаем делитель
                pop ax       ;возвращаем целое
                                
                mov ax,bx    ;                                bx=ax
                push bx
                xchg ax,dx   ;увеличиваем остаток в 10 раз    dx=3 ax=1            
                mov bx,10    ;                                bx=10
                mul bx
                pop bx
                
                cmp bx,0     ;проверяем деление на ноль
                je next1
                
                idiv bx      ;делим
                
                push ax
                push bx
                push dx
                
                lea dx,ax    ;вывод целой части
                call ShowInt16
            loop for5
            
            next1:           ;преход к следуещему элементу массива
                pop dx
                pop bx
                pop ax
                pop cx
                pusha        ;вывод пробела после элемента
                    mov ah,2
                    mov dl,32
                    int 21h
                popa
        loop for4
            
        popa
        lea dx,CrLf         
        call printStr
    ret
invert endp

main    proc
        mov ax,@data
        mov ds,ax
 
        mov ah,09h
        lea dx,[asPrompt]
        int 21h
        
        mov [count],0                               ;ввод массива
        lea di,[Array]                 ;
        xor cx,cx                      ; n=0
        xor bx,bx                      ; x=0
        xor si,si                      ; sign=0
        
        do:  
            cmp [count], 100
            ja break                         ; do{
            mov ah,01h                 ;    al=getch()
            int 21h
            inc [count]
            cmp al,'-'                 ;    if(al=='-')
            jne IsDigit
                mov si, -1             ;      sign=-1;
                jmp do
                
        IsDigit:
                
                
                cmp al,'0'             ;    if(isdigit(al))
                jb  store
                cmp al,'9'
                ja store
                    push ax            ;      x=x*10+al-'0'
                    mov ax,10
                    mul bx
                    pop bx
                    sub bl,'0'
                    xor bh,bh
                    add  bx,ax
                                       ;проверить знак
                    jmp next
                    
                store: 
                      
                    cmp si,-1
                    je mins  
                    cmp bx, 7FFFh 
                    ja exit
                    jmp aboba
                    mins:
                    cmp bx,8000h 
                    jbe aboba
                    lea dx,[overf]
                    call printStr
                    jmp exit 
                     
                    
                    
                    aboba:               ;    else{
                    xor bx,si          ;      if(sign==-1)
                    sub bx,si          ;      { x= -x;
                    xor si,si          ;        sign=0}; 
                    
                      
                    
                    mov [di],bx        ;      a[n]=x
                    add di,2
                    inc cx             ;      n=n+1
                    xor bx,bx          ;      x=0
                    cmp al,0Dh         ;      if(al=enter)
                    je break           ;        break;
                                       ;    }
        next:
        jmp do
                                       ;  }while(1)
break:   
        ;cmp [count],200
        

        cmp cx,0
        jne notempty
        lea dx,[IncString]
        call printStr
        jmp exit
        
 notempty:
        mov [N],cx
 
        mov ah,09h
        lea dx,[asShowArray]
        int 21h
        mov cx,[N]
        lea dx,[Array]
        call ShowArray
        
menu:
        lea dx,press1       ;menu messages
        call printStr
        lea dx,press2
        call printStr
        lea dx,press3
        call printStr
        lea dx,press4
        call printStr
        lea dx,press5
        call printStr
input:        
        mov ah,1            ;выбор пункта меню
        int 21h
        
        cmp al,'1'          ;инверсия
        jne no_invers
        call invers
        
        no_invers:
        cmp al,'2'          ;квадрат
        jne no_square                                                                     
        call square
        
        no_square:
        cmp al,'3'          ;модуль
        jne no_abs
        call abs
        
        no_abs:
        cmp al,'4'          ;обратное
        jne no_invert
        call invert
        
        no_invert:
        cmp al,'q'          ;выход
        je exit
        lea dx,CrLf        
        call printStr
        jmp input
exit:
        mov ax,4C00h
        int 21h                
main endp
end main