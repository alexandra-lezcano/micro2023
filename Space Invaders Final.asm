.model small
.data                                                                                        

    loseDesign db  "           \.   \.      __,-""-.__      ./   ./",13,10,0
                 db "       \.   \`.  \`.-'"" _,=""=._ ""`-.'/  .'/   ./",13,10,0
                 db "        \`.  \_`-''      _,=""=._      ``-'_/  .'/",13,10,0
                 db "         \ `-',-._   _.  _,=""=._  ,_   _.-,`-' /",13,10,0
                 db "      \. /`,-',-._""""  \ _,=""=._ /  """"_.-,`-,'\ ./",13,10,0
                 db "       \`-'  /    `-._  ""       ""  _.-'    \  `-'/",13,10,0
                 db "       /)   (         \    ,-.    /         )   (\",13,10,0
                 db "    ,-""     `-.       \  /   \  /       .-'     ""`-,",13,10,0
                 db "  ,'_._         `-.____/ /  _  \ \____.-'         _._`,",13,10,0
                 db " /,'   `.                \_/ \_/                .'   `,\",13,10,0
                 db "/'       )              GAME OVER!    _         (       `\ ",13,10,0
                 db "        /   _,-'""`-.  ,++|T|||T|++.  .-'""-,_   \",13,10,0
                 db "       / ,-'        \/|`|`|`|'|'|'| \/         `-, \",13,10,0
                 db "      /,'             | | | | | | |               `,\",13,10,0
                 db "     /'               ` | | | | | '                 `\ ",13,10,0
                 db "                        ` | | | '",13,10,0
                 db "                          ` | '",13,10,0
                 db "", '$'     
                 
    winDesign db " YOU WIN! ",13,10, '$'              
   
    bullet db "*",13,10,'$'
	explodedBullet db "#",13,10,'$'
    player db "^",13,10,'$'
    alien db "@",13,10,'$' 
    
	; Game world dimensions
    CEILING EQU 5 	
    FLOOR EQU 20
    LEFT_LIMIT EQU 15
    RIGHT_LIMIT EQU 25
	
	RED EQU 4
	LIGHT_GREEN EQU 10
	YELLOW EQU 14	
	WHITE EQU 15
	
    playerY db 19
    playerX db 20 
	
	alienX db 20 
	alienY db 5
	 
	; messages and alerts
	pointsMsg db "Puntaje: $"
	bulletsMsg db "  Balas: $"
	pointCount db 0
	bulletCount db 5      
	LIMIT db "NO PUEDES HUIR! REGRESA A AL MISION",13,10,'$'
	collision_msg db "BOOM! Mataste un alien! ",13,10,'$'  
	lost_bullet_msg db "BOOH! Perdiste una bala! ",13,10,'$'         
	no_more_bullets_msg db "Ya no tienes balas! ",13,10,'$'  
	 
	; bullet information: posX, posY, exists, hasCollision
	bulletPosX db 5 dup(0) 
	bulletPosY db 5 dup(18)   
	bulletExists db 5 dup(0)
	bulletCollision db 5 dup(0)  
    bulletIndex db 0 ; use as counter to access the bullet array

	alienPosX db 16, 17, 18, 19, 20, 21, 22, 23, 24
	alienPosY db 5, 6, 7, 5, 6, 7, 5, 6, 7
	alienExists db 9 dup(1)   
    alien_move_count db 2  
    
    alienDead db 0      
	
	gameOver db 0
	
.code   
mov ax,@data
mov ds,ax
mov es,ax 

game:     	
	call paint_game
	call check_for_keypressed 
	
	call calc_alienPosY
	call calc_bullet_position
	
	call show_messages
	call clean_screen
	jmp game

; HANDLE USER INPUT
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
		
		cmp ah, 4Bh  ;left arrow
		je move_player_left
		
		cmp ah, 4Dh  ;right arrow
		je move_player_right
    
		jmp check_for_keypressed
		
	;; handle keypress	
    ; create new bullet at bulletIndex   
    set_bullet:  
        ; if bulletCount ==0 or bulletIndex == 5 jump to ret
        mov al, bulletCount
        cmp al, 0
        je no_more_bullets

		mov al, bulletIndex
		cmp al, 5
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
		mov byte ptr[si], al  ; bulletPosX[bulletIndex] = playerX 
		
		; upadte the bullet counters for a new bullet
		inc bulletIndex 
		dec bulletCount
		 
		ret_from_set_bullet:			
		ret    
		
		no_more_bullets:
		call show_no_bullets_message
		ret
	
	move_player_left:
		cmp playerX, LEFT_LIMIT
		ja okl
		
		call show_player_limit_message
		add playerX, 1
		
		okl:
		    dec playerX
		    ret
	
	move_player_right:
	    cmp playerX, RIGHT_LIMIT
		jb okr  
		 
		call show_player_limit_message
		sub playerX,1
		
		okr:
		    inc playerX
		    ret	
 
; CALCULATE NEXT FRAME
 
; move bullet upwards - for each bullet, decrease postY if it exists    
calc_bullet_position:
 
	mov si, 0
	
	loop_bullets: 
		cmp si, 5
		je exit_loop_bullets ; if 5==5 break loop
		
		; if bullet exists 
		mov al, bulletExists[si]
		cmp al, 1
		je dec_bullet_posY

		; else ignore it
		inc si
		jmp loop_bullets
		
		; move bullet up
		dec_bullet_posY:
			; ignore bullets that exist and have a collision 
			mov ah, bulletCollision[si]
			cmp ah, 1
			je loop_bullets
			
			mov al, bulletPosY[si]  
			
			; remove bullet if it hit the cealing
			cmp al, CEILING 
			je remove_bullet 
			
			; check for collisions: 
			; if bulletX == alienX
			; 	if bulletY == alienY 
			mov bp, 0 
			
			forEach_alien:   
				cmp bp, 9
				je break_forEach_alien_loop
				
				mov bh, alienExists[bp]
				cmp bh, 0
				je continue_forEach_alien_loop
				
				mov bl, bulletPosX[si]
				mov bh, alienPosX[bp]				
				sub bl, bh
				cmp bl, 0
				jne continue_forEach_alien_loop
				
				mov bl, bulletPosY[si]
				mov bh, alienPosY[bp] 
				sub bl, bh
				cmp bl, 0				
				jne continue_forEach_alien_loop
				
				;if there was a collision I will take this branch
				jmp set_collision_and_exit
				
				; no collision or alien doesn't exist
				continue_forEach_alien_loop:
    				inc bp
    				jmp forEach_alien
			
			;;; branches for bullet position:    
		    ; collision detected
		    set_collision_and_exit:    
				mov cl, 1
				mov bulletCollision[si], cl
				
				mov ch, 0
				mov alienExists[bp], ch 
				
				inc pointCount
				inc si  
				call show_collision_message
				jmp loop_bullets
			     	 
			; there wasn't any collision this bullet continues moving upwards			
			break_forEach_alien_loop:	
    			dec al
    			mov bulletPosY[si], al			
    			inc si
    			jmp loop_bullets
		   
		    ; bullet gets to the ceiling
    		remove_bullet:
    			mov ah, 0
    			mov bulletExists[si], ah
				inc si				
				call lost_bullet_message
    			
    			jmp loop_bullets	
				
	exit_loop_bullets:
	ret	

calc_alienPosY:

	mov si, 0  
	
	; make aliens move only every 2 frames
	should_move_alien: 
		cmp alien_move_count, 0 ; if alien_move_count != 0 don't move aliens
		jne exit_loop_alien_dont_move  

		loop_alienPosY:         ; else move them
			cmp si, 9
			je exit_loop_alien
			
			mov ah, alienExists[si]
			cmp ah, 0
			je continue_loop_alienPostY
				 
			mov al, alienPosY[si] 
			inc al
			mov alienPosY[si], al
			
			cmp al, playerY
			je set_game_over ; break the loop if one alien is at player position 			
			
			continue_loop_alienPostY:
			inc si 
			jmp loop_alienPosY
		 
		set_game_over: 
			inc gameOver      
		
		exit_loop_alien: 
			mov al, 2
			mov alien_move_count, al ; reset move count
			ret	
		
		exit_loop_alien_dont_move:
			dec alien_move_count
			ret
		

; PAINT THE ACTUAL GAME				
paint_game:   
       
    call display_player
	call display_alien	
    call display_bullets	 	
	ret
   
   
    display_player:
        push ax
		push bx
		push dx
		push cx
				
        mov  ah,13h    
        mov  bp,offset player 
        mov  bh,0 
        mov  bl, YELLOW 
        mov  cx,1 
        mov  dl,playerX 
        mov  dh,playerY  
        int  10h 
        
        pop ax
		pop bx
		pop cx
		pop dx
				
        ret
    
	display_alien: 
	    push ax
		push bx
		push dx
		push cx  
		
		mov ax,@data
		mov ds,ax
		mov es,ax  
		
		mov si, 0 
		
		loop_paint_alien: 
			cmp si, 9
			je exit_loop_paint_alien
			
			mov ch, alienExists[si]
			cmp ch, 0
			je continue_painting_aliens
			
			mov ah,13h   
			mov bp,offset alien 
			mov bh,0 
			mov bl,LIGHT_GREEN 
			mov cx,1 
			mov dl,alienPosX[si]        ;x
			mov dh,alienPosY[si]        ;y
			int 10h      
			
			continue_painting_aliens:
			inc si
			jmp loop_paint_alien 
		
		exit_loop_paint_alien: 
		cmp gameOver, 0
		jne end_game 
        
        pop ax
		pop bx
		pop cx
		pop dx
        ret
	
	display_bullets:
		push ax
		push bx
		push dx
		push cx
					
		mov si, 0
		
		display_bullets_loop:
			cmp si, 5
			je exit_display_bullets_loop ; if 5==5 break loop
			
			; if bullet exists, check its state, could be moving or could be on a collision
			mov al, bulletExists[si]
			cmp al, 1
			je check_bullet_state
			
			; else ignore it
			jmp continue_painting_bullets 
			
				check_bullet_state:
					mov ch, bulletCollision[si]
					cmp ch, 0
					je paint_single_bullet
					
					mov  ah,13h    
					mov  bp,offset explodedBullet 
					mov  bh,0 
					mov  bl, RED 
					mov  cx,1 
					mov  dl,bulletPosx[si]        ;x
					mov  dh,bulletPosY[si]        ;y
					int  10h      
					
					mov cl, 0
					mov bulletExists[si], cl
				
					jmp continue_painting_bullets
				
					paint_single_bullet:
						mov  ah,13h    
						mov  bp,offset bullet 
						mov  bh,0 
						mov  bl, WHITE 
						mov  cx,1 
						mov  dl,bulletPosx[si]        ;x
						mov  dh,bulletPosY[si]        ;y
						int  10h      
							
				continue_painting_bullets:
    				inc si
    				jmp display_bullets_loop
				
				exit_display_bullets_loop:
    				pop ax
    				pop bx
    				pop cx
    				pop dx
    				ret

;helpers

show_messages:    
    push ax
    push bx
	push cx
    push dx
    
    mov ax,@data
    mov ds,ax
    mov es,ax

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
	pop cx
    pop dx
    
	ret

show_player_limit_message:     
    push ax
    push bx
	push cx
    push dx
	
	mov ah, 2h ; ping
	mov dl, 07h
	int 21h
	
    mov ah, 2h  ; set cursor position
    mov bh, 0            
    mov dh, 0           
    mov dl, 0           
    int 10h    
    
    mov ah, 9h
	mov dx, offset LIMIT
	int 21h
    
    pop ax
    pop bx
	pop cx
    pop dx
    ret
         
show_collision_message:     
    push ax
    push bx
	push cx
    push dx
	
	mov ah, 2h ; ping
	mov dl, 07h
	int 21h
	
    mov ah, 2h  ; set cursor position
    mov bh, 0            
    mov dh, 0           
    mov dl, 2           
    int 10h    
    
    mov ah, 9h
	mov dx, offset collision_msg
	int 21h
    
    pop ax
    pop bx
	pop cx
    pop dx
    ret   
    
lost_bullet_message:     
    push ax
    push bx
	push cx
    push dx
	
	mov ah, 2h ; ping
	mov dl, 07h
	int 21h
	
    mov ah, 2h  ; set cursor position
    mov bh, 0            
    mov dh, 0           
    mov dl, 4           
    int 10h    
    
    mov ah, 9h
	mov dx, offset lost_bullet_msg
	int 21h
    
    pop ax
    pop bx
	pop cx
    pop dx
    ret

show_no_bullets_message:
    push ax
    push bx
	push cx
    push dx
	
	mov ah, 2h ; ping
	mov dl, 07h
	int 21h
	
    mov ah, 2h  ; set cursor position
    mov bh, 0            
    mov dh, 0           
    mov dl, 6           
    int 10h    
    
    mov ah, 9h
	mov dx, offset no_more_bullets_msg
	int 21h
    
    pop ax
    pop bx
	pop cx
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
	call clean_screen
    
    mov ah, 2    ; set cursor position  
    mov bh, 0
    mov dl, 2        
    mov dh, 2        
    int 10h
     
    mov dx, offset loseDesign
    mov dx, si 
    mov ah,9h 
    int 21h
    
	mov ah, 4ch
    int 21h  
    
win_game: 
	call clean_screen
    
    mov ah, 2    ; set cursor position  
    mov bh, 0
    mov dl, 2        
    mov dh, 2        
    int 10h
     
    mov dx, offset winDesign
    mov dx, si 
    mov ah,9h 
    int 21h
    
	mov ah, 4ch
    int 21h        
end game