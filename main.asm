 include macros2.inc 
 Delay MACRO
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 7h
    mov dx, 0FFFFh                                      ;0a120  F424
    ;wait for half second
    mov ah, 86
    int 15h
    
    pop dx
    pop cx
    pop bx
    pop ax
    
ENDM Delay

.MODEL small
.STACK 64    
.DATA 
 
 RBTop       db 6
 RBCenterU   db 7
 RBCenterD   db 8
 RBBottom    db 9 
 
 line        db 0
               
 ask_p1_name db 'Player 1 Name: ','$'
 ask_p2_name db 'Player 2 Name: ','$'
 score_msg db "'s score:$"
 p1_name db 30, ?, 30 dup('$')
 p2_name db 30, ?, 30 dup('$')
  
 p1_score db 0  ;Intially player 1 score is 0
 p2_score db 0  ;Intially player 2 score is 0
 
 GoalDim db 71, 3, 75, 11 ;X1,Y1, X2,Y2
 current_player db 1   
 
 
 
 Coordinate_BallCurve dw  0205h , 6     

temp dw ? 
cx_value dw ?
Shoot_Key  db  1Ch; Enter scan code
 
Total_Shoots db 1       ;inc until 10 (5 for each player)

p1_win db 'Player 1 Wins','$'
p2_win db 'Player 2 Wins','$'
Draw   db 'It is A Draw','S'
 
 
.CODE   
MAIN    PROC   
    
    mov ax, @DATA
    mov ds, ax
    mov ax, 0
    
    mov ah, 0
    mov al, 3
    int 10h 
    
    GetNames
        
    DrawInterface
    
    WriteOneFifthScreen              
         
    
    
   mov Ah,03h
   int 10h    
   mov Bh, 00
   mov Cx, 01  

   mov ah,1
   mov cx,2b0bh
   int 10h 
   
   
   
   Print RBCenterU,70,20h     
   Print RBCenterD,70,20h  
 
   
   ;DrawCurve_Only
   
   ;DrawCurve_Shoot  
    
   ;activeLoop:
   
   ;mov ah, 01h
   ;int 16h         ;ZF=1 no charachter in buffer
   ;jz activeLoop
   ;mov Ah,00
   ;int 16h     ;waits for buffer till it's not empty
   ;CALL Move            

   ;JMP activeLoop
   ;CALL  Active       



;Wait for key from keyboard to shoot
    CHECK:
        ;DrawCurve   macro
        ;DrawCurve Macro    
        ;Get Curve co
        ;mov bx,Coordinate_BallCurve[0] ;start      
        mov bl,0 
        mov cx,Coordinate_BallCurve[2] ; radius
    
    FirstHalfCycle:                                                             
        mov ah,2
        mov dx, Coordinate_BallCurve[0]
        add dl,bl                ;inc X Coordinate --> right  
        ; add dl,bl                ;inc X Coordinate --> right
        ;inc dl
        add dh,bl                ;inc Y Coordinate --> down
        int 10h      
        push dx
                                           
        ;Draw 'o'
        mov ah,2
        mov dl,'o'
        int 21h  
        pop dx
        mov si,dx    
        ;To clear the last 'o'       
        mov ah,2
        mov dx,si
        int 10h  
        ;Delay    
        ;Draw space
        mov ah,2
        mov dl,' '
        int 21h  
                                            
        inc bl   
                                                                                
        MOV AH,1              ;Get key pressed
        INT 16H  
        JNZ Key_Pressed1
        JMP NO_Key_Pressed1               
    
    Key_Pressed1:   
        MOV AH,0             ;clear used scan code from buffer
        INT 16H  
        cmp ah,Shoot_Key   
        JZ Shoot
        cmp ah,01H                  ;Esc
        JZ Exit     
        push ax
        push bx
        push cx
        push dx
        mov cx_value,cx   
        Call Move 
        mov cx ,cx_value 
        pop dx
        pop cx
        pop bx
        pop ax
    
    NO_Key_Pressed1:    
        loop FirstHalfCycle                
        ;mov bl,0  
        mov bl,1
        mov cx,Coordinate_BallCurve[2] ; radius 
        dec cx 
        mov temp,si               
      
      
      
      
    SecondHalfCycle:   
        mov ah,2
        mov dx, temp
        sub dl,bl         ;dec X Coordinate -->left
        ;dec dl
        add dh,bl         ;inc Y Coordinate -->down
        int 10h    
        push dx
        ;Draw 'o'
        mov ah,2
        mov dl,'o'
        int 21h  
        pop dx
        mov si,dx
                                          
        ;To clear the last 'o'       
        mov ah,2
        mov dx,si
        int 10h 
        ;Delay     
        ;Draw space
        mov ah,2
        mov dl,' '
        int 21h  
                                               
        inc bl     
                                                                                 
        MOV AH,1              ;Get key pressed
        INT 16H  
        JNZ Key_Pressed2
        JMP NO_Key_Pressed2               
    
    Key_Pressed2:   
        MOV AH,0             ;clear used scan code from buffer
        INT 16H 
        cmp ah,Shoot_Key   
        JZ Shoot
        cmp ah,1H                  ;Esc
        JE Exit      
        push ax
        push bx
        push cx
        push dx
        mov cx_value,cx   
        Call Move 
        mov cx ,cx_value 
        pop dx
        pop cx
        pop bx
        pop ax
    
    NO_Key_Pressed2:                                             
        loop SecondHalfCycle
                                                                     
    
    ;ENDM DrawCurve           
    cmp ah,Shoot_Key        
    JNZ CHECK 

Exit:
    mov ah,004CH
    int 21H   
                
    ;si contains co-ordinate of start of shooting line
    Shoot:                                                                 
        mov cx,11 ;Horizontal shoot  
        mov bl,1   
        mov temp,si
    
    Horizontal:                  
        MOV AH,1              ;Get key pressed
        INT 16H  
        JNZ Key_Pressed3
        JMP NO_Key_Pressed3               
    
    Key_Pressed3:   
        MOV AH,0             ;clear used scan code from buffer
        INT 16H
        push ax
        push bx
        push cx
        push dx
        mov cx_value,cx   
        Call Move 
        mov cx ,cx_value 
        pop dx
        pop cx
        pop bx
        pop ax
                                                                   
    NO_Key_Pressed3:
        mov ah,2
        mov dx,temp
        add dl,bl     ;inc X horizonatally -->right
        int 10h   
        push dx
        ;Draw
        mov ah,2                                                                                  
        mov dl,'o'
        int 21h
        pop dx
        mov si,dx    
        ;Delay
                            
        ;To clear the last 'o'       
        mov ah,2
        mov dx,si
        int 10h      
        ;Draw space
        mov ah,2
        mov dl,' '
        int 21h  
                             
        add bl ,6
        
        ;Fady's Part
        mov ah,3h
        mov bh,0h
        int 10h
        
        
         
        cmp dl,69
        JAE Passed       
                                                                  
    Loop Horizontal         
                       
                       
    Passed: 
        ;Check if it is saved
        cmp dh,RBCenterU
        JE Saved
        
        cmp dh,RBCenterD
        JE Saved
        
    
        ;Between the Goal's Region
        mov line,1 
        cmp dh,3
        JBE Switch
        cmp dh,11
        JAE Switch
        
        JMP Goal
        
        
        
    Saved:
        JMP Switch
          
    
    Goal:
      cmp current_player,1
      JE incp1
      
      cmp current_player,2 
      JE incp2
         
         
    incp1:
      inc p1_score      
      jmp Switch  
      
    incp2:
      inc p2_score      
      jmp Switch 
      
      
      
    Switch:
       ;Switch the players
       cmp current_player ,1
       JE Setp1
                            
       cmp current_player ,2                             
       JE Setp2
       
     
    Setp1:
          mov current_player ,2
          jmp Final
    
    Setp2:
          mov current_player ,1
          jmp Final  
    
      
   Final:   
      ChangeScore  
      
      cmp Total_Shoots,10
      JE Result
      
      inc Total_Shoots
      
      jmp Check         
                                          
    
    Result:
        mov ah, 0
        mov al, 3h
        int 10h 
    
        mov dh,p1_score
        mov dl,p2_score
        cmp dl,dh
        JB P1Win
        
        cmp dl,dh
        JA P2Win
        
        
        JMP Draws
    
    
    P1Win:
        mov ah,2
        mov dh,12
        mov dl,40
        int 10h
    
        mov ah, 9
        mov dx, offset p1_win
        int 21h
        jmp Exit
        
    P2Win:
        mov ah,2
        mov dh,12
        mov dl,32
        int 10h
    
        mov ah, 9
        mov dx, offset p2_win
        int 21h 
        jmp Exit         
        
     Draws:
        mov ah,2
        mov dh,12
        mov dl,32
        int 10h
    
        mov ah, 9
        mov dx, offset Draw
        int 21h
        
        jmp Exit
    
         
 hlt
MAIN        ENDP    
 
  
  
  
Move PROC
   RightU:
    CMP Ah,48h
    JNZ RightD    
    Call RightUp
   RightD:    
    CMP Ah,50h
    JNZ ENDD       
    CALL RightDown
   ENDD:ret
Move ENDP    

RightUp PROC
   
    cmp RBCenterU,0
    jz ENDRU
    dec RBCenterU
    print RBCenterU,70,20h
    Delete RBCenterD,70 
    DEC RBCenterD
   
    ENDRU:ret
RightUp ENDP

RightDown PROC
    cmp RBCenterD,14
    jz ENDRD
    
    inc RBCenterD
    print RBCenterD,70,20h 
    Delete RBCenterU,70 
    INC RBCenterU
   
    ENDRD:ret
RightDown ENDP
END MAIN 
