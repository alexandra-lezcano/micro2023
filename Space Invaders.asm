.model small
.stack 100h
.data
invader db ".",13,10,'$' 
tablero db "|------------------------------------------------|",13,10,"|Puntaje:                 Balas:                 |",10,13, "|------------------------------------------------|",'$'
fil    DB 22
col    DB 1
nave DB '^','$'    

.code              
main proc
    mov AX,@data
    mov DS,AX
    mov es, ax 

    mov BL, 3 
        label1: 
            call mostrar_rojo
            call mover 
            ;call fire
            
            mov AH,2H
            mov BH,0            ;goto-XY
            mov DH,BL    
            mov DL,1
            INT 10H
        
            mov AH,9H
            mov DX,offset invader      ;print
            INT 21H
        
            mov AH, 6H 
            mov AL, 0    
            mov BH, 7         ;clear screen 
            mov CX, 0
            mov DL, 79
            mov DH, 24
            int 10H
        
            ADD BL,1
        
            cmp BL,22         ;?¦¦¦ COMPARE BL, NOT DH, BECAUSE
            jz label2         ;     YOU LOST DH WHEN CLEARED SCREEN.
            loop label1 
    
        label2:
            call mostrar_rojo
            call mover
            
            mov AH,2H           ;?¦¦¦ UNCOMMENT THIS BLOCK !!!
            mov BH,0            ;goto-XY
            mov DH,BL
            mov DL,1
            INT 10H
        
            mov AH,9H
            mov DX,offset invader      ;print
            INT 21H
        
            mov AH, 6H 
            mov AL, 0    
            mov BH, 7         ;clear screen 
            mov CX, 0
            mov DL, 79
            mov DH, 24
            int 10H
        
            SUB BL, 1
            cmp BL, 3         ;?¦¦¦ PERSONAL CHANGE : DETECT WHEN
            jz label1        ;     CURSOR REACHES THE TOP ?
            loop label2                             
        
        
        mostrar_rojo:
            push ax
            push bx
            push cx
            push dx  
             
            mov ah,13h
            mov bp, offset tablero
            mov bh,0
            mov bl,4
            mov cx, 154  ; string length
            mov dl,0
            mov dh,0  
            int 10h   
            
            pop dx
            pop cx
            pop bx
            pop ax
            ret
        
        mover:
            push ax
            push bx
            push cx
            push dx
            
            mov ah, 2  ;Move cursor 
            mov bh, 0 
            mov dh, fil
            mov dl, col  
            int 10h
            
            mov  ah, 9   ;print message
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
                ja okl
                mov ah, 2h
                mov dl, 07h
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
            
            
end main 