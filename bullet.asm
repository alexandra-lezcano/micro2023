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
 
    ;bulletExists db 0
    tmpBulletY db 18 
    tmpBulletX db 20
	
	alienX db 20
	alienY db 5
	
	pointsMsg db "Puntaje: $"
	bulletsMsg db "  Balas: $"
	pointCount db 0
	bulletCount db 5   
	 
	; bullet information: posX, posY, exists, hasCollision
	bulletPosX db 5 dup(0) 
	bulletPosY db 5 dup(18)   
	bulletExists db 5 dup(0)
	bulletCollision db 5 dup(0)  
    isShooting db 0   ; set true when the user clicks the up arrow
    bulletIndex db 0 ; use as counter to access the bullet array

.code   
mov ax,@data
mov ds,ax
mov  es,ax 

game:     	
	call check_for_keypressed          
	call calc_bullet_position
	call paint_game
	call clean_screen
	jmp game

check_for_keypressed:
	mov ah, 0bh    
	int 21h  
	cmp al, 0
	jne get_key_pressed
	ret
		
    get_key_pressed: 
        mov ah,0
        int 16h
        cmp ah, 48h    ;up arrow
        je set_bullet           
        jmp check_for_keypressed
     
    ; create new bullet at bulletIndex   
    set_bullet:  
        ; if we don't have bullets jump to ret
        mov al, bulletCount
        cmp al, 0
        je ret_from_set_bullet        
        
		; Set bullet X, Y if it doesn't exist      
		mov bx, 0
        mov al, bulletIndex       
        mov bl, al
		lea si, [ bulletExists + bx ] 
		mov dl, [si] ; dl = bulletExists[bulletIndex]	
        cmp dl, 1                  
        je ret_from_set_bullet 
		
		; else set bullet exists at index and give it X 
        mov al, 1
        mov byte ptr[si], al  ; bulletExists[bulletIndex] = 1 
		
		mov bx, 0
        mov al, bulletIndex       
        mov bl, al
		lea si, [ bulletPosX + bx ]
		mov al, playerX
		mov byte ptr[si], al  ; bulletPosX[bulletIndex] = playerPosX 
		
		; upadte the bullet counters for a new bullet
		inc bulletIndex 
		dec bulletCount
		
		ret_from_set_bullet:
	    ret    
	
	clear_bullet: 
		mov bulletExists, 0    	
	    ret
 
; move bullet upwards - for each bullet, decrease postY if it exists    
calc_bullet_position: 
	mov si, 0
	
	loop_bullets: 
		cmp si, 5
		je continue_calc ; if 5==5 break loop
		
		; if bullet exists 
		mov al, bulletExists[si]
		cmp al, 1
		je dec_bullet_posY
		
		; else ignore it
		inc si
		jmp loop_bullets
		
		
		; move bullet up
		dec_bullet_posY:
			mov al, bulletPosY[si] 
			dec al
			mov bulletPosY[si], al 				
			inc si
			jmp loop_bullets
	
	continue_calc:
	ret	
				
paint_game:   
       
    call display_player
	call display_alien
    call display_bullets
	
	continue_painting:	; helper tag for me to handle loop breaks
	call show_messages 	
	ret
   
   
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
	
	display_bullets:
		mov si, 0
		
		display_bullets_loop:
			cmp si, 5
			je continue_painting ; if 5==5 break loop
			
			; if bullet exists paint it
			mov al, bulletExists[si]
			cmp al, 1
			je paint_single_bullet
			
			; else ignore it
			inc si
			jmp loop_bullets 
			
			paint_single_bullet:
				push ax
				push bx
				push dx
				push cx
				
				mov  ah,13h    
				mov  bp,offset bullet 
				mov  bh,0 
				mov  bl, WHITE 
				mov  cx,1 
				mov  dl,bulletPosx[si]        ;x
				mov  dh,bulletPosY[si]        ;y
				int  10h      
				
				pop cx
				pop dx
				pop bx
				pop ax
				
				inc si
				jmp display_bullets_loop

	
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