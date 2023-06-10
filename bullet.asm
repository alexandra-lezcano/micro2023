.model small
.data  
    bullet db "*",13,10,'$'
	explodedBullet db "#",13,10,'$'
    player db "^",13,10,'$'
    alien db "@",13,10,'$' 
    
	; Game world dimensions
    CEILING EQU 2 	
    FLOOR EQU 20
    LEFT EQU 2
    RIGHT EQU 40
	
	RED EQU 4
	LIGHT_GREEN EQU 10
	YELLOW EQU 14	
	WHITE EQU 15
	
    playerY db 20
    playerX db 20 
 
    bulletExists db 0
    tmpBulletY db 18 
    tmpBulletX db 20
	
	alienX db 20
	alienY db 5
	
	pointsMsg db "Puntaje: $"
	bulletsMsg db "  Balas: $"
	pointCount db 0
	bulletCount db 5

.code
game:
	mov ax,@data
    mov ds,ax
    mov  es,ax    
	
	call check_for_keypressed 
	call paint_game
	call clean_screen
	jmp game
	
	; wait for user input
	; if input then bala 
	; else 
	; print scene 
	; clean screan
	; wait for input
	

check_for_keypressed:
	mov ah, 0bh    
	int 21h  
	cmp al, 0
	jne get_key_pressed
	ret
		
    get_key_pressed: 
        mov  ah,0
        int 16h
        cmp ah, 48h    ;up arrow
        je set_bullet            
        jmp check_for_keypressed
        
    set_bullet: ; just say a bullet exists       
        mov bulletExists, 1   
        dec bulletCount 	
	    ret    
	
	clear_bullet: 
		mov bulletExists, 0    	
	    ret

paint_game:       
    call display_player
	call display_alien
    call check_for_bullets
	call show_messages 	
	
	cmp tmpBulletY, 0 ; end game if bullet is at 0
    je end_game 
	
    display_player:
        mov  ah,13h    
        mov  bp,offset player 
        mov  bh,0 
        mov  bl, YELLOW 
        mov  cx,3 
        mov  dl,playerX 
        mov  dh,playerY  
        int  10h 
        ret
    
	display_alien:
		mov  ah,13h    
        mov  bp,offset alien 
        mov  bh,0 
        mov  bl, LIGHT_GREEN 
        mov  cx,3 
        mov  dl,alienX 
        mov  dh,alienY  
        int  10h 
        ret
	
    check_for_bullets: 
        cmp bulletExists, 1
        je move_bullet  
        ret
        
    move_bullet: 
        mov ah,tmpBulletY  
        mov al, alienY
        sub ah, al
	    cmp ah, 0
		je explode
		
        mov  ah,13h    
    	mov  bp,offset bullet 
    	mov  bh,0 
    	mov  bl, WHITE 
    	mov  cx,3 
    	mov  dl,tmpBulletX        ;x
    	mov  dh,tmpBulletY        ;y
    	int  10h      
    	dec tmpBulletY  		
		ret
   
   ; make bullet count: 0 (no bullet exists) 
   ; make alien be a null string 
   explode:    
		call clear_bullet   		
		call kill_alien
		mov  ah,13h    
    	mov  bp,offset explodedBullet 
    	mov  bh,0 
    	mov  bl, RED 
    	mov  cx,3 
    	mov  dl,tmpBulletX        ;x
    	mov  dh,tmpBulletY        ;y
    	int  10h      
		ret
    
	kill_alien:
		mov byte ptr[alien],00h
		;mov byte ptr[bullet],00
		;call display_alien
		ret
	

;helpers

show_messages:    
    push ax
    push bx
    push dx
    
    mov ax,@data
    mov ds,ax
    mov  es,ax

    mov ah, 2    ; set cursor position  
    mov bh, 0
    mov dl, 2        
    mov dh, 23        
    int 10h
       
    mov dx, offset pointsMsg
    mov ah,9h 
    int 21h
	
	mov dl,pointCount   
    add dl, 30h ;convert ascii to decimal
    mov ah,2h
    int 21h 
	
	mov dx, offset bulletsMsg
    mov ah,9h 
    int 21h
	
	mov dl,bulletCount   
    add dl,30h 
    mov ah,2h
    int 21h 
    
    pop ax
    pop bx
    pop dx
    
	ret


	
clean_screen: 
	mov ah, 6h 
	mov al, 0    
	mov bh, 7         
	mov cx, 0
	mov dl, 79
	mov dh, 24
	int 10h 
	ret
 
end_game: 
	mov ah, 4ch
    int 21h     
end game