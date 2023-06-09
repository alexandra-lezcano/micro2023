.model small
.data  
    bullet db " * ",13,10,'$'
	explodedBullet db "#",13,10,'$'
    player db "(&)",13,10,'$'
    alien db "öwö",13,10,'$'
    
    GAME_HEIGHT EQU 15 	
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
	    ret    
	
	clear_bullet: 
		mov bulletExists, 0    	
	    ret

paint_game:
    call display_player
	call display_alien
    call check_for_bullets   
	
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
   
   explode:    
		call clear_bullet   
		;kill alien: set the var at this memory address to empty
		mov  ah,13h    
    	mov  bp,offset explodedBullet 
    	mov  bh,0 
    	mov  bl, RED 
    	mov  cx,3 
    	mov  dl,tmpBulletX        ;x
    	mov  dh,tmpBulletY        ;y
    	int  10h      
		ret
    

;helpers
clean_screen: 
	mov AH, 6H 
	mov AL, 0    
	mov BH, 7         
	mov CX, 0
	mov DL, 79
	mov DH, 24
	int 10H 
	ret
 
end_game: 
	mov ah, 4ch
    int 21h     
end game