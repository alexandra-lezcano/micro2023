.model small
.stack 100h
.data
inv_linea1 db "M   Y   T   M   Y   T   M   Y",13,10,'$' 
inv_linea2 db "  M   Y   T   M   Y   T   M   Y",13,10,'$' 
inv_linea3 db "M   Y   T   M   Y   T   M   Y",13,10,'$' 
linea_base db 3
tablero db "|------------------------------------------------|",13,10,"|Puntaje:                 Balas:                 |",10,13, "|------------------------------------------------|",'$'
fil    DB 22
col    DB 1  
line_max db 7
line_min db 3  
misil db "!" ,'$'
nave DB 'A','$'    

.code              
main proc
    mov AX,@data
    mov DS,AX
    mov es, ax 

    mov BL, 2    ;Y inicial
    mov CH, 1    ;X inicial
        mover_der: 
            call mostrar_tabla
            call mover 
            ;call fire
            
                inc bl
            print_inv: 
                
                mov cl,3  
                push ax
                push bx           ;guardar datos
                push cx
                push dx
                 
                dibujar_linea:  
                
                    ;IMPRIMIR 1ER INVASOR 
                    mov AH,2H
                    mov BH,0            
                    mov DH,BL           ;Y
                    mov DL,CH           ;X
                    INT 10H
                
                    mov AH,9H
                    mov DX,offset inv_linea1    
                    INT 21H        
                    
                    ;IMPRIMIR 2DO INVASOR
                    mov AH,2H
                    mov BH,0          
                    mov DH,BL   
                    mov DL,CH
                    add dh, 1
                    INT 10H  
                    
                    mov AH,9H
                    mov DX,offset inv_linea2    
                    INT 21H 
                    
                    ;IMPRIMIR 3ER INVASOR
                    mov AH,2H
                    mov BH,0          
                    mov DH,BL 
                    mov DL,CH
                    add dh, 2
                    INT 10H
                    
                    mov AH,9H
                    mov DX,offset inv_linea3    
                    INT 21H   
                                         
                                         
                    call finish
                                         
                    add ch, 12  
                    dec cl    
                    cmp cl, 0
                    jne dibujar_linea 
                    ;jmp sgte_linea  
                    
                    
                
        
            ;RESETEAR TODA LA PANTALLA   
            resetear_pantalla: 
                inc line_max
                mov bl, line_min 
                push ax
                push bx           ;guardar datos
                push cx
                push dx 
                
                mov AH, 6H 
                mov AL, 0    
                mov BH, 7         ;clear screen 
                mov CX, 0
                mov DL, 55
                mov DH, 25
                int 10H   
                
                pop dx
                pop cx            ;recuperar datos
                pop bx
                pop ax
            
            ;MOVIMIENTO INVADERS
            inc ch
        
            cmp CH, 3          
            je mover_izq        
            jmp mover_der 
    
        mover_izq:
            call mostrar_tabla
            call mover
            
            mov AH,2H           
            mov BH,0           
            mov DH,BL
            mov DL,1
            INT 10H
        
            mov AH,9H
            mov DX,offset inv_linea1    
            INT 21H
        
            mov AH, 6H 
            mov AL, 0    
            mov BH, 7         ;clear screen 
            mov CX, 0
            mov DL, 79
            mov DH, 24
            int 10H
        
            SUB BL, 1
            cmp BL, 3         
            jz mover_der        
            jmp mover_izq                             
        
        
        mostrar_tabla:
            push ax
            push bx
            push cx
            push dx  
             
            mov ah, 13h
            mov bp, offset tablero
            mov bh, 0
            mov bl, 4
            mov cx, 154  ; string length
            mov dl,0
            mov dh,0  
            int 10h   
            
            pop dx
            pop cx
            pop bx
            pop ax
            ret
        
        mover:          ;Nave
            push ax
            push bx
            push cx
            push dx
            
            mov ah, 2  ;imprimir nave (x,y) 
            mov bh, 0 
            mov dh, fil
            mov dl, col  
            int 10h
            
            mov  ah, 9   
            mov  dx,OFFSET nave
            int  21h
             
            mov ah,0bh  ;returns al=0 : no key pressed
            int 21h     ;al!=0 : key pressed
            
            cmp al, 0
            je no_mover
            
            mov ah, 00h  ;enter the keyboard
            int 16h
        
            cmp ah, 48h  ;Up Arrow key 
            je fire
        
            cmp ah, 4Dh  ;Right Arrow key 
            je right
        
            cmp ah, 4Bh  ;Left Arrow key 
            je left
        
            fire:
                ;sub fil, 1
                call fire
                  
                pop dx
                pop cx
                pop bx
                pop ax
                ret
            
            right:
                cmp col, 0
                ja okr
                mov ah, 2h
                mov dl, 07h
                int 21h 
                mov col, 1
                okr: 
                inc col
                pop dx
                pop cx
                pop bx
                pop ax
                ret
            
            left:
                cmp col, 1
                ja okl          ;cuando la nave llega un borde y se le
                mov ah, 2h      ;insiste en ir mas alla de la izquierda
                mov dl, 07h     ;conserva su posicion y genera un beep
                int 21h 
                mov col, 2
                okl:
                sub col, 1
                pop dx
                pop cx
                pop bx
                pop ax
                ret
                  
            no_mover: 
                pop dx
                pop cx
                pop bx
                pop ax        
                ret
            
            finish:
                mov ax, 4c0h
                int 21h
            
end main 