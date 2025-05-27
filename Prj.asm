IDEAL


;Macro for Random procedure
MACRO NEW_LINE
	mov dl,13   ; CR = Caridge Return - go to row start position
	mov ah,2   
	int 21h
	mov dl,10   ;  LF = Line Feed - go down to the next line
	int 21h
ENDM LINE


macro RND
 mov ax, 40h

mov es, ax

mov ax, [es:6Ch]

and ax, 7
endm

;end Macro


MODEL small




STACK 100h


DATASEG

    OneBmpLine 	db 320 dup (0)  ; One Color line read buffer
   
    ScrLine 	db 324 dup (0)  ; One Color line read buffer


	;BMP File data
	RndCurrentPos dw start
	matrix dw ?
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
;bmp pictures variebels
	Net 	db 'images\Net.bmp' ,0
	goalkeeper db 'images\keeper.bmp' , 0
	diveleft db 'images\dlgk.bmp' , 0
	diveright db 'images\drgk.bmp' , 0
	diveRightLow db 'images\drgkl.bmp' , 0
	diveLeftLow db 'images\dlgkl.bmp' , 0
	FirstPlayer db 'images\firstP.bmp' , 0
	SecondPlayer db 'images\SecondP.bmp' , 0
	ThirdPlayer db 'images\ThirdP.bmp' , 0
	FourthPlayer db 'images\FourthP.bmp' , 0
	FifthPlayer db 'images\FifthP.bmp' , 0 
	ball db 'images\eball.bmp' , 0
	ballBackround db 289 dup(?)
	Goal db 'images\Goal.bmp' , 0
	Miss db 'images\Miss.bmp' , 0
	startScreen db 'images\start.bmp' , 0
	startbutton db 'images\button.bmp' , 0
	Score db 'images\Score.bmp' , 0
	Green db 'images\Green.bmp' , 0
	Red db 'images\Red.bmp' , 0
	GameOver db 'images\GameOver.bmp' , 0
	
	
	CurrScorePos dw ?
	
	
	KeeperXSize dw 60
	KeeperYSize dw 85
	KeeperBackRound db 5100 dup(?)
	
	ScoreXSize dw 100
	ScoreYSize dw 34
	ScoreAdd db 3400 dup(?)
	
	PlayerXSIze dw 60
	PlayerYsize dw 85
	PlayerBackRound db 5100 dup(?)
	
	FinalXball dw ?
	FinalYball dw ?
	
	CurrXball dw ?
	CurrYball dw ?
	
	
	
	BallSize dw 17
	
	
	DiveDirection dw ?                          
			  
			  			  
	; see http://cs.nyu.edu/~yap/classes/machineOrg/info/mouse.htm
	
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ? 
	
	
CODESEG
 


 
start:
	mov ax, @data
	mov ds, ax
	
	;Set graphic mode
	call SetGraphic
	
	;hide mouse
	mov ax  , 2
	int 33h
	

Set:
	mov [CurrScorePos] , 230 ; first Score x position for red or green
	mov [DiveDirection] , 0 ;first Dive direction set
	call StartGame
	
;move to cx how many times we want the game loop to run
	mov cx , 5
MainLoopGame:
	push cx ; push cx to save it 

;set all the objects in the field , and also before set them save thier backround to move them afterwards with the saveBackround tecnic
	call SetNet
	call SaveFisrtKeeperBackround
	call SaveFirstBallBackRound
	call SaveFirstPlayerBackRound
	call SetGoalkeeper
	call SetBall
	call SetPlayer
Check: ; this check is to check if we need to print the score bmp , if its the first time print it as it is , if not the first time , 
;add green or red according to the shoot(goal or not)
	pop cx
	push cx
	cmp cx , 5
	jl NfirstTime
	je FirstTime
NfirstTime:
	call PutScore
	jmp CheckIfClicked
FirstTime:	
	call SetScore
	jmp CheckIfClicked
CheckIfClicked: ; check if user clicked on the screen(if clicked means he is shooting the ball)
	mov ax , 1
	int 33h
	mov ax , 3
	int 33h
	cmp bx , 1
	jne CheckIfClicked ; it means he hasnt clicked

Cont:
;hide mouse because we need to print things on the screen and if we wont hide the mouse it wont do it properly
	mov ax , 2
	int 33h
;shift right cx because in this mouse function it gives you cx from 1 - 640 and our screen is 320 pixels in x and 200 in y 
	shr cx , 1
	sub cx , 5
	call ChangeFinalXYBall
	mov [FinalYball] , dx ; move to final ball the y
	call MovePlayer ; move player first
	call MoveKeeper ; move keeper after
	call MoveBall ; move ball last
	call CheckIfGoal ; check if goal  , if true print green on the screen  , if not prints red
	call SaveScore ; after we print green or red we save the score picture so we can print it afterwards with the last score
	call DelyOneSec
	
	
Loopp:
	mov ah, 1 ; waits to user tap after user tap it goes back for the loop
	int 21h
	pop cx
	loop MainLoopGame



CheckIfPlayAgain:
	call GameOverProc
	cmp ax , 0
	je Set
	cmp ax , 1
	je exit
	
	
	
exit:

	
;exit graphic mode , goes back to text mode
	mov ax,2
	int 10h

	
	mov ax, 4c00h
	int 21h
	

	
;==========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================


proc ChangeFinalXYBall
;in cx Final x ball

	mov [FinalXball] , cx
	mov [FinalYball] , dx

;random Change
@@Rand:
	mov bl , 1
	mov bh , 4
	call RandomByCs
	
@@Check:
	cmp al , 1
	je @@end
	cmp al , 2
	je @@ChangeX
	cmp al , 3
	je @@ChangeY

@@ChangeX:
	mov bl , 1
	mov bh , 2
	call RandomByCs
	cmp al , 1
	je @@AddX
	cmp al , 2
	je @@SubX
@@AddX:
	add [FinalXball] , 30
	jmp @@StopX
@@SubX:
	sub [FinalXball] , 30
	
@@StopX:
	jmp @@end





@@ChangeY:
	mov bl , 0	
	mov bh , 2
	call RandomByCs
	cmp al , 1
	je @@AddY
	cmp al , 2
	je @@SubY
@@AddY:
	add [FinalYball] , 30
	jmp @@StopY
@@SubY:
	sub [FinalYball] , 30
	
	
@@StopY:
	jmp @@end




@@end:

	ret
endp ChangeFinalXYBall


proc StartGame
	;shows start screen 
	mov dx, offset startScreen
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] , 200
	call OpenShowBmp

	;shows start button
	mov dx , offset startbutton
	mov [BmpLeft],110
	mov [BmpTop] , 160
	mov [BmpColSize], 100
	mov [BmpRowSize] , 24
	call OpenShowBmp

;check if the user clicked on the button 
@@CheckIfClicked:
	mov ax , 1
	int 33h
	mov ax , 3
	int 33h
	cmp bx , 1
	jne @@CheckIfClicked

@@Clicked:

@@CheckX:
	shr cx , 1
	cmp cx , 110
	jl @@CheckIfClicked
	cmp cx , 210
	ja @@CheckIfClicked
@@CheckY:
	cmp dx , 160
	jl @@CheckIfClicked
	cmp dx , 184
	ja @@CheckIfClicked

@@ClickedOnButton:




	ret
endp StartGame



proc GameOverProc
;if ax = 0 , restart , if ax = 1 exit 

	mov dx, offset GameOver
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] , 200
	call OpenShowBmp




@@CheckIfClicked:
	mov ax , 1
	int 33h
	mov ax , 3
	int 33h
	cmp bx , 1
	jne @@CheckIfClicked


@@CheckIfRestart:

@@CheckYRestart:
	cmp dx , 100
	jae @@ContCheckYRestart
	jl @@CheckIfClicked
@@ContCheckYRestart:
	cmp dx , 140
	jle @@Restart
	ja @@CheckExit







@@CheckExit:

@@CheckYExit:
	cmp dx , 150
	jae @@ContCheckYExit
	jl @@CheckIfClicked


@@ContCheckYExit:	
	cmp dx , 190
	jle @@Exit
	ja @@CheckIfClicked






@@Restart:
	mov ax , 0
	jmp @@End

@@Exit:
	mov ax , 1
	jmp @@End

@@End:
	push ax
	mov ax , 2
	int 33h     ;hide mouse
	pop ax

	ret
endp GameOverProc











proc PrintGoal
;print goal on to sides of the screen 
	mov dx, offset goal
	mov [BmpLeft],0
	mov [BmpTop],10
	mov [BmpColSize], 100
	mov [BmpRowSize] , 30
	call OpenShowBmp
	
	
	
	mov dx, offset goal
	mov [BmpLeft],220
	mov [BmpTop],10
	mov [BmpColSize], 100
	mov [BmpRowSize] , 30
	call OpenShowBmp
	ret
endp PrintGoal


proc PrintMiss
;print miss on to sides of the screen 
	mov dx, offset Miss
	mov [BmpLeft],0
	mov [BmpTop],10
	mov [BmpColSize], 100
	mov [BmpRowSize] , 30
	call OpenShowBmp
	
	
	
	mov dx, offset Miss
	mov [BmpLeft],220
	mov [BmpTop],10
	mov [BmpColSize], 100
	mov [BmpRowSize] , 30
	call OpenShowBmp
	ret
endp PrintMiss

proc SaveScore
;in dx x cordination
;in cx , y cordination
	mov dx , 210
	mov cx , 160
;push registers
	push dx
	push cx
	push bx
	push ax
;calculate di
	mov bx , 320
	inc cx
	mov ax , cx
	
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
;end calculate
;put data on the registers for the getMatrixFromScreen procedure
	mov dx , [ScoreXSize]
	mov cx , [ScoreYSize]
	mov bx , offset ScoreAdd
	mov [matrix] , bx
	call getMatrixFromScreen


;pop registers
	pop ax
	pop bx 
	pop cx 
	pop dx
	
	ret
endp SaveScore

proc PutScore

;this procedure print the score bytes on the screen (score after goal or not)



;in dx x cordination
;in cx , y cordination
	mov dx , 210
	mov cx , 160
	push dx
	push cx
	push bx
	
	
	;calculate di
	mov bx , 320
	inc cx
	mov ax , cx
	
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
	;end calculate 
	
	
	mov bx , offset ScoreAdd ; as you see its not the score bmp picture , just the bytes
	mov [matrix] ,  bx
	
	
	mov cx , [ScoreYSize]
	mov dx , [ScoreXSize]
	call PutMatrixOnScreen
	
	pop bx
	pop cx
	pop dx
	

	ret
endp PutScore



proc SetScore
;prints the score bmp , when its the first time
	mov dx, offset Score
	mov [BmpLeft],210
	mov [BmpTop],160
	mov ax , [ScoreXSize]
	mov [BmpColSize], ax
	mov ax , [ScoreYSize]
	mov [BmpRowSize] , ax
	call OpenShowBmp
	
	
	
	;puts a ball in the blue hole just for astetics
	mov dx , offset ball 
	mov [BmpLeft] , 213
	mov [BmpTop] , 170
	mov ax , [BallSize]
	mov [BmpColSize] , ax
	mov [BmpRowSize] , ax
	call OpenShowBmp
	
	
	ret
endp SetScore



proc PrintGreen
;print green on the score when its a goal
	mov dx, offset Green
	mov ax , [CurrScorePos]
	mov [BmpLeft],ax
	mov [BmpTop],164
	mov [BmpColSize], 20
	mov [BmpRowSize] , 30
	call OpenShowBmp
	ret
endp PrintGreen


proc PrintRed
;print red on the score when its a miss
	mov dx, offset Red
	mov ax , [CurrScorePos]
	mov [BmpLeft],ax
	mov [BmpTop],164
	mov [BmpColSize], 20
	mov [BmpRowSize] , 30
	call OpenShowBmp
	ret
endp PrintRed


proc CheckIfGoal



CheckIfOutOfNet: ; checks if its in the net if not print miss
	
	cmp [FinalXball] , 255
	jae @@Missed
	cmp [FinalXball] , 50
	jle @@Missed
	
	cmp [FinalYBall] , 6
	jle @@Missed
	
	cmp [FinalYBall] , 90
	jae @@Missed

@@Cont: ; check keeper dive direction 
	cmp [DiveDirection] , 0
	je @@CheckBallMiddle
	
	
	cmp [DiveDirection] , 1
	je @@CheckBallLeft
	
	
	cmp [DiveDirection] , 2
	je @@CheckBallRight


;check middle
@@CheckBallMiddle:
	cmp [FinalXball] , 140
	jae @@ContCheck
	jmp @@goal
@@ContCheck:
	cmp [FinalXball] , 160
	jle @@Missed
	jmp @@goal
;end check middle
	
	
@@CheckBallLeft:
;check if ball is on the side of the keeper(in left side now)
	cmp [FinalXball] , 100
	jle @@missed
	jmp @@Goal
	

@@CheckBallRight:
;check if ball is on the side of the keeper(in right side now)
	cmp [FinalXball] , 160
	jae @@Missed
	jmp @@goal
	
	

	
@@goal:
	call PrintGoal
	call PrintGreen
	add [CurrScorePos] , 15 ; add for next red or green paint
	jmp @@endd
@@Missed:
	call PrintMiss
	call PrintRed
	add [CurrScorePos] , 15 ; add for next red or green paint
	jmp @@endd

@@endd:
	
	ret
endp CheckIfGoal





;Sets all the mbappe pictures for animation
proc SetPlayer
	mov dx, offset FirstPlayer
	mov [BmpLeft],60
	mov [BmpTop],120
	mov ax , [PlayerXSIze]
	mov [BmpColSize], ax
	mov ax , [PlayerYsize]
	mov [BmpRowSize] , ax
	call OpenShowBmp

	ret
endp SetPlayer


proc PrintSecondPlayer

	mov dx, offset SecondPlayer
	mov [BmpLeft],70
	mov [BmpTop],115
	mov ax , [PlayerXSIze]
	mov [BmpColSize], ax
	mov ax , [PlayerYsize]
	mov [BmpRowSize] , ax
	call OpenShowBmp


	ret
endp PrintSecondPlayer


proc PrintThirdPlayer

	mov dx, offset ThirdPlayer
	mov [BmpLeft],80
	mov [BmpTop],110
	mov ax , [PlayerXSIze]
	mov [BmpColSize], ax
	mov ax , [PlayerYsize]
	mov [BmpRowSize] , ax
	call OpenShowBmp


	ret
endp PrintThirdPlayer



proc PrintFourthPlayer

	mov dx, offset FourthPlayer
	mov [BmpLeft],90
	mov [BmpTop],105
	mov ax , [PlayerXSIze]
	mov [BmpColSize], ax
	mov ax , [PlayerYsize]
	mov [BmpRowSize] , ax
	call OpenShowBmp


	ret
endp PrintFourthPlayer



proc PrintFifthPlayer

	mov dx, offset FifthPlayer
	mov [BmpLeft],100
	mov [BmpTop],100
	mov ax , [PlayerXSIze]
	mov [BmpColSize], ax
	mov ax , [PlayerYsize]
	mov [BmpRowSize] , ax
	call OpenShowBmp


	ret
endp PrintFifthPlayer

;end Sets picturs





proc SavePlayerBackRound

;in dx x cordination
;in cx , y cordination

;push registers
	push dx
	push cx
	push bx
	push ax
;calculate di
	mov bx , 320
	inc cx
	mov ax , cx
	
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
;end calculate
	mov dx , [PlayerYSIze]
	mov cx , [PlayerXSIze]
	mov bx , offset PlayerBackRound
	mov [matrix] , bx
	call getMatrixFromScreen


;pop registers
	pop ax
	pop bx 
	pop cx 
	pop dx
	
	ret
endp SavePlayerBackRound


proc PrintPlayerBackRound
;in dx x cordination
;in cx , y cordination
	push dx
	push cx
	push bx
	
	
	;calculate di
	mov bx , 320
	inc cx
	mov ax , cx
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
	;end calculate 
	
	
	mov bx , offset PlayerBackRound ; put offset in matrix
	mov [matrix] ,  bx
	
	
	mov cx , [PlayerYSIze]
	mov dx , [PlayerXSIze]
	call PutMatrixOnScreen
	
	pop bx
	pop cx
	pop dx


	ret
endp PrintPlayerBackRound



proc SaveFirstPlayerBackRound ; save first because we call this procedure only in MovePlayer but we still need to know the first backround
	mov dx , 60
	mov cx , 120
	call SavePlayerBackRound
	ret
endp SaveFirstPlayerBackRound



proc MovePlayer


@@FirstPrintBackround:
;print first bakcround
	call DelyOneSec
	
	mov dx , 60
	mov cx , 120
	call PrintPlayerBackRound
	
	
	
	
;start animation , print all the player pictures with delay and it will look like the player is moving
@@PlayerTwo:
	mov dx , 70
	mov cx , 115
	call SavePlayerBackRound
	call PrintSecondPlayer
	mov dx , 70
	mov cx , 115
	call DelyOneSec
	
	call PrintPlayerBackRound
	
@@PlayerThree:
	mov dx , 80
	mov cx , 110
	call SavePlayerBackRound
	
	call PrintThirdPlayer
	call DelyOneSec
	
	mov dx , 80
	mov cx , 110
	call PrintPlayerBackRound
	
	


@@PlayerFour:
	mov dx , 90
	mov cx , 105
	call SavePlayerBackRound
	
	call PrintFourthPlayer
	call DelyOneSec
	
	mov dx , 90
	mov cx , 105
	call PrintPlayerBackRound
	
@@PlayerFive:
	mov dx , 100
	mov cx , 100
	call SavePlayerBackRound
	
	call PrintFifthPlayer
	
	
	
	
	
	
	
	
	

	ret
endp MovePlayer

















;Description:
;will get the matrix in the specified location on the screen

;input:
; in dx how many cols
; in cx how many rows
; in matrix - the bytes
; in di start byte in screen (0 64000 -1)

;output:
;variable who's offset is in [matrix]
proc getMatrixFromScreen
	push es
	push ax
	push si

	mov ax, 0A000h
	mov es, ax
	
	push dx
	mov ax, cx
	mul dx

	mov bp, ax
	pop dx
	mov si, [matrix]

@@NextRow:
	push cx
	
	mov cx, dx
@@GetLinesFromScreen:
	mov bl, [es:di]
	mov [ds:si], bl
	inc si
	inc di
	loop @@GetLinesFromScreen
	
	sub di,dx
	add di, 320
	pop cx
	loop @@NextRow

@@ret:
	pop si
	pop ax
	pop es
	ret
endp getMatrixFromScreen






;Description:
;will print the matrix in the specified location on the screen
;input:
; in dx how many cols
; in cx how many rows
; in matrix - the picture or bytes
; in di start byte in screen (0 64000 -1)
;output:
;pictue in the specific place in screen
proc PutMatrixOnScreen


	cld 
	mov si , [matrix]

@@NextRow:
	push cx
	mov cx , dx
	rep movsb
	sub di , dx
	add di , 320
	pop cx
	loop @@NextRow
	



	ret
endp PutMatrixOnScreen





proc SaveFisrtKeeperBackround
	mov dx , 130
	mov cx , 35
	call SaveKeeperBackRound




	ret
endp SaveFisrtKeeperBackround


proc goalkeeperDiveLeft

	cmp [FinalYball] , 45
	jle @@DiveHigh
	ja @@DiveLow
	
@@DiveHigh:
	mov dx, offset diveLeft
	mov [BmpLeft],65
	mov [BmpTop],30
	mov [BmpColSize], 85
	mov [BmpRowSize] , 60
	call OpenShowBmp
	jmp @@end
@@DiveLow:
	call goalkeeperDiveLeftLow



@@end:


	ret
endp goalkeeperDiveLeft

proc goalkeeperDiveLeftLow
	mov dx, offset diveleftLow
	mov [BmpLeft],50
	mov [BmpTop],60
	mov [BmpColSize], 85
	mov [BmpRowSize] , 45
	call OpenShowBmp

	ret
endp goalkeeperDiveLeftLow










proc goalkeeperDiveRight
	cmp [FinalYball] , 45
	jle @@DiveHigh
	ja @@DiveLow
	
@@DiveHigh:
	mov dx, offset diveright
	mov [BmpLeft],170
	mov [BmpTop],27
	mov [BmpColSize], 95
	mov [BmpRowSize] , 60
	call OpenShowBmp
	jmp @@end
@@DiveLow:
	call goalkeeperDiveRightLow



@@end:

	ret
endp goalkeeperDiveRight

proc goalkeeperDiveRightLow

	mov dx, offset diverightLow
	mov [BmpLeft],180
	mov [BmpTop],50
	mov [BmpColSize], 85
	mov [BmpRowSize] , 60
	call OpenShowBmp
	
	
	


	ret
endp goalkeeperDiveRightLow






proc SaveKeeperBackRound

;in dx x cordination
;in cx , y cordination

;push registers
	push dx
	push cx
	push bx
	push ax
;calculate di
	mov bx , 320
	inc cx
	mov ax , cx
	
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
;end calculate
	mov dx , [KeeperXSize]
	mov cx , [KeeperYSize]
	mov bx , offset KeeperBackRound
	mov [matrix] , bx
	call getMatrixFromScreen


;pop registers
	pop ax
	pop bx 
	pop cx 
	pop dx
	
	ret
endp SaveKeeperBackRound




proc PrintKeeperBackRound
;in dx x cordination
;in cx , y cordination
	push dx
	push cx
	push bx
	
	
	;calculate di
	mov bx , 320
	inc cx
	mov ax , cx
	
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
	;end calculate 
	
	
	mov bx , offset KeeperBackRound ; put offset in matrix
	mov [matrix] ,  bx
	
	
	mov cx , [KeeperYSize]
	mov dx , [KeeperXSize]
	call PutMatrixOnScreen
	
	pop bx
	pop cx
	pop dx


	ret
endp PrintKeeperBackRound



proc MoveKeeper

	push dx
	push cx
	push bx
	
	

	mov dx , 130
	mov cx , 35
	call PrintKeeperBackRound
	
@@RndDir: ; this generate the direction of the dive 
	xor ax , ax
	mov bl , 0
	mov bh , 3
	call RandomByCs
	cmp al , 1
	je @@DiveLeft
	cmp al , 2
	je @@DiveRight
	cmp al , 3
	je @@Stay
@@DiveRight:
	call goalkeeperDiveRight
	mov [DiveDirection] , 2
	jmp @@end
@@DiveLeft:
	call goalkeeperDiveLeft
	mov [DiveDirection] , 1
	jmp @@end
@@Stay:
	call SetGoalkeeper
	mov [DiveDirection] , 0
	jmp @@end
	

@@end:
	pop bx 
	pop cx
	pop dx
	




	ret
endp MoveKeeper





proc SetNet
	mov ax , 2
	int 33h
	mov dx, offset Net
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	call OpenShowBmp
	ret
endp SetNet


proc SetGoalkeeper

	mov dx, offset goalkeeper
	mov [BmpLeft],130
	mov [BmpTop],35
	mov ax , [KeeperXSize]
	mov [BmpColSize], ax
	mov ax , [KeeperYSize]
	mov [BmpRowSize] , ax
	call OpenShowBmp



	ret
endp SetGoalkeeper




proc SetBall
	mov [CurrXball] , 152
	mov [CurrYball] , 168
	mov dx, offset ball
	mov [BmpLeft],152
	mov [BmpTop],168
	mov [BmpColSize], 17
	mov [BmpRowSize] , 17
	call OpenShowBmp
	ret
endp SetBall

proc SaveFirstBallBackRound
	mov dx , 152
	mov cx , 168
	call SaveBallBackRound


endp SaveFirstBallBackRound

proc PrintBallBackRound
;in dx x cordination
;in cx , y cordination
	push dx
	push cx
	push bx
	
	
	;calculate di
	mov bx , 320
	inc cx
	mov ax , cx
	
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
	;end calculate 
	
	
	mov bx , offset ballBackround ; put offset in matrix
	mov [matrix] ,  bx
	
	
	mov cx , [BallSize]
	mov dx , [BallSize]
	call PutMatrixOnScreen
	
	pop bx
	pop cx
	pop dx






	ret
endp PrintBallBackRound

proc SaveBallBackRound

;in dx x cordination
;in cx , y cordination
	push dx
	push cx
	push bx
	push ax
	
	mov bx , 320
	inc cx
	mov ax , cx
	
	push dx ;dx become 0 after mul
	mul bx
	pop dx
	
	
	mov di , ax
	add di , dx
	
	
	
	
	
	
	mov dx , [BallSize]
	mov cx , [BallSize]
	
	mov bx , offset ballBackround
	mov [matrix] , bx
	call getMatrixFromScreen
	
	
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp SaveBallBackRound







proc MoveBall
	

@@Fisrt: ; first time we print the backround of the ball to vanish the ball
	mov dx , [CurrXball]
	mov cx , [CurrYball]
	call PrintBallBackRound
	

@@StartLoop:

;check 
CheckOne:
	; this check is to check if the y ball cordination is similar to the final y ball cordination if true check x
	mov ax , [FinalYBall]
	mov cx , [CurrYball]
	sub cx , ax
	cmp cx , 15
	jle CheckTwo
	jg @@ContMove
CheckTwo: ; this check is to check if the x cordination of the is similar to the y cordination of the final ball if true print final ball
	mov ax , [FinalXball]
	mov cx , [CurrXball]
	sub cx , ax
	cmp cx , 15
	jle ContCheckTwo
	jg @@ContMove
ContCheckTwo:
	cmp cx , -15
	jge FinalBall
	jl @@ContMove

;end Check

;save ball Backround


	
@@ContMove: ; now we check wich direction should we move the ball
	mov bx , [CurrXball]
	cmp [FinalXball] , bx
	jle MoveLeft
	jae MoveRight
MoveLeft:
	sub [CurrXball] , 4
	sub [CurrYball] , 4
	jmp @@Savebackround
MoveRight:
	add [CurrXball] , 4
	sub [CurrYball] , 4
	jmp @@Savebackround
	
@@Savebackround:
	mov dx , [CurrXball]
	mov cx , [CurrYball]
	call SaveBallBackRound
	
	
	

PrintNewBall:
	mov dx, offset ball
	mov ax , [CurrXball]
	mov [BmpLeft], ax
	mov ax , [CurrYball]
	mov [BmpTop], ax
	mov [BmpColSize], 17
	mov [BmpRowSize] , 17
	call OpenShowBmp
	
Dely:
	call DelyBall


PrintBackRound:
	mov dx , [CurrXball]
	mov cx , [CurrYball]
	call PrintBallBackRound
	

	
SetVals:
	
	jmp @@StartLoop
	

	
FinalBall: ; now after the current ball is close enough to the final ball we print the final ball
	mov dx, offset ball
	mov ax , [FinalXball]
	mov [BmpLeft], ax
	mov ax , [FinalYball]
	mov [BmpTop], ax
	mov [BmpColSize], 17
	mov [BmpRowSize] , 17
	call OpenShowBmp

	ret 
endp MoveBall


















proc DelyBall
	push cx
	mov cx , 7
@@Self:
	push cx
	mov cx , 3000
@@self2:
	loop @@self2
	pop cx
	loop @@self
	pop cx
	ret


	ret
endp DelyBall



proc DelyOneSec

	push cx
	mov cx , 37
@@Self:
	push cx
	mov cx , 3000
@@self2:
	loop @@self2
	pop cx
	loop @@self
	pop cx
	ret
endp DelyOneSec





















;bmp photos
proc OpenShowBmp near
	push ax
	push cx
	push bx
	push dx
	
	
	call OpenBmpFile
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBmp
	
	 
	call CloseBmpFile

@@ExitProc:
	pop dx
	pop bx
	pop cx
	pop ax
	ret
endp OpenShowBmp

 

; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	
	mov [FileHandle], ax
	jmp @@ExitProc

@@ExitProc:	
	ret
endp OpenBmpFile

	
; output file dx filename to open
proc CreateBmpFile	near						 
	 
	
CreateNewFile:
	mov ah, 3Ch 
	mov cx, 0 
	int 21h
	
	jnc Success
	
Success:
	mov [FileHandle], ax
@@ExitProc:
	ret
endp CreateBmpFile





proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette

 


proc ShowBMP
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine

@@Copying:
	cmp [byte ds:si], 0d
	je @@Transperant
	jmp @@MovsbLabel
	
@@Transperant:
	inc si
	inc di
	jmp @@LoopLabel

@@MovsbLabel:
	movsb ; Copy line to the screen
		;mov [es:di], [ds:si]
		;inc si
		;inc di
@@LoopLabel:
	loop @@copying

	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP
	

; Read 54 bytes the Header
proc PutBmpHeader	near					
	mov ah,40h
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp PutBmpHeader
 



proc PutBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	mov ah,40h
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp PutBmpPalette


 
proc PutBmpDataIntoFile near
			
    mov dx,offset OneBmpLine  ; read 320 bytes (line) from file to buffer
	
	mov ax, 0A000h ; graphic mode address for es
	mov es, ax
	
	mov cx, 200
	
	cld 		; forward direction for movsb
@@GetNextLine:
	push cx
	dec cx
										 
	mov si,cx    ; set si at the end of the cx line (cx * 320) 
	shl cx,6	 ; multiply line number twice by 64 and by 256 and add them (=320) 
	shl si,8
	add si,cx
	
	mov cx,320    ; line size
	mov di,dx
    
	 push ds 
     push es
	 pop ds
	 pop es
	 rep movsb
	 push ds 
     push es
	 pop ds
	 pop es
 
	
	
	 mov ah,40h
	 mov cx,320
	 int 21h
	
	 pop cx ; pop for next line
	 loop @@GetNextLine
	
	
	
	 ret 
endp PutBmpDataIntoFile

   
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic














; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. Bl = min (from 0) , BH , Max (till 255)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        Al - rnd num from bl to bh  (example 50 - 150)
; More Info:
; 	Bl must be less than Bh 
; 	in order to get good random value again and agin the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCs
    push es
	push si
	push di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di
	pop si
	pop es
	ret
endp RandomByCs


; Description  : get RND between any bl and bh includs (max 0 - 65535)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di
 
	
	mov ax, 40h
	mov	es, ax
	
	sub dx,bx  ; we will make rnd number between 0 to the delta between bx and dx
			   ; Now dx holds only the delta
	cmp dx,0
	jz @@ExitP
	
	push bx
	
	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter
	
	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	
	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
		 
@@ExitP:
	
	pop di
	pop si
	pop es
	ret
endp RandomByCsWord

; make mask acording to bh size 
; output Si = mask put 1 in all bh range
; example  if bh 4 or 5 or 6 or 7 si will be 7
; 		   if Bh 64 till 127 si will be 127
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask


Proc MakeMaskWord    
    push dx
	
	mov si,1
    
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop dx
	ret
endp  MakeMaskWord



; get RND between bl and bh includs
; output al - rnd num from bl to bh
; the distance between bl and bh  can't be greater than 100 
; Bl must be less than Bh 
proc RndBlToBh  ; by Dos  with delay
	push  cx
	push dx
	push si 


	mov     cx, 1h
	mov     dx, 0C350h
	mov     ah, 86h
	int     15h   ; Delay of 50k micro sec
	
	sub bh,bl
	cmp bh,0
	jz @@EndProc
	
	call MakeMask ; will put in si the right mask (example for 28 will put 31)
RndAgain:
	mov ah, 2ch   
	int 21h      ; get time from MS-DOS
	mov ax, dx   ; DH=seconds, DL=hundredths of second
	and ax, si  ;  Mask for Highst num in range  
	cmp al,bh    ; we deal only with al (0  to 100 )
	ja RndAgain
 	
	add al,bl

@@EndProc:
	pop si
	pop dx
	pop cx
	
	ret
endp RndBlToBh



	 
proc printAxDec  
	   
       push bx
	   push dx
	   push cx
	           	   
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_next_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_next_to_stack

	   cmp ax,0
	   jz pop_next_from_stack  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next_from_stack: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next_from_stack

	   pop cx
	   pop dx
	   pop bx
	   
       ret
endp printAxDec    

  

 
; int 15h has known bug dont use it.
proc timeAx
    push  cx
	push dx
	
 	mov     cx, 0h
	mov     dx, 0C350h
	mov     ah, 86h
	int     15h   ; Delay of 50k micro sec

	
    mov ah, 2ch   
	int 21h      ; get time from MS-DOS
	mov ax, dx   ; DH=seconds, DL=hundredths of second
	
	pop dx
	pop cx
	
    ret	
endp timeAx





EndOfCsLbl:
END start

 




