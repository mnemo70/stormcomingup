***************************************************
* STORM - STORM COMING UP
*
* Disassembly by MnemoTroN/Spreadpoint in 2024.
*
* Tools used:
*   ReSource 6.06 for code
*   Maptapper for graphics
*   VS Code with Amiga Assembly extension
*
* Info: https://www.pouet.net/prod.php?which=14748
***************************************************

BitplaneSize	EQU	200*42	;200 lines with 42 bytes each

	SECTION	Main,CODE,CHIP

;Include modern startup code by StingRay.
;startup.i will return to the OS for us.
	INCLUDE	"startup.i"

lbC000000:
	JMP	MAIN

ScrollText:
	dc.b	'     the fucking best                       '
	dc.b	'STORMI          '
	dc.b	'presents another release !                  '
	dc.b	'a storm is coming up.....                    '
	dc.b	'remember STORMI rules!                      '
	dc.b	'we have only one destiny         '
	dc.b	'to be the best                            '
	dc.b	'-- use orgasm rat to control --              '
	dc.b	'business regards go to : quartex - acu - spreadpoint'
	dc.b	' - supreme - scoopex - black monks - tristar'
	dc.b	' - europe - paranoimia.....    '
	dc.b	'                         '
	dc.b	'fucks go to all incompetend local lamers in our district!'
	dc.b	'        '
	dc.b	'stop talking shit about us or you have a war!  o.k.!        '
	dc.b	'STORMIA elite pirates are:'
	dc.b	' waremaster - m.i.g. - chris - elite........'
	dc.b	'             ',$A0,'  ',$A0,'      '
	dc.b	'we don t must release every day something coz we are no'
	dc.b	$A0
	dc.b	'ugly zombies like ???? who have nothing better to do!        '
	dc.b	$A0,'    ',$A0,$A0
	dc.b	'            '
	dc.b	$A0,$A0
	dc.b	'  call soon our bbs in italy and the states!'
	dc.b	'     look in our further release for the number to your dreams!    '
	dc.b	$A0,$A0,$A0
	dc.b	'     '
	dc.b	'watch out for more and more in our fight for the crime!'
	dc.b	'                            '
	dc.b	'                                            '
	dc.b	'                                            '
	dc.b	'                                            '
	dc.b	'                          '
	dc.b	$A0
	dc.b	0
	even

MAIN:
	BSR	InitDemo
	BSR	mt_init
	BSR.S	MainLoop
	BSR	mt_stop
;	BSR	RestoreSystem		;obsolete
;	MOVEQ	#0,D0			;obsolete
	RTS

MainLoop:
	MOVE.L	4(A6),D0		;VPOSR+VHPOSR
	LSR.L	#8,D0
	AND.W	#$1FF,D0
	CMP.W	#300,D0
	BNE.S	MainLoop

	BSR	FlipScreens
	BSR	ScrollBoardY		;Move squares in y direction
	BSR	ScrollBoardX		;Move squares in x direction
	BSR	DoScrollText

	LEA	BoardRotation(PC),A0
	BSR	RotateBoardMatrix
	BSR	PrepBlitterForLines
	BSR	DrawLinesPlane1
	BSR	FillBoardPlane1

	LEA	BoardCoordTable(PC),A0
	BSR	RotateXYCoords
	BSR	PrepBlitterForLines
	BSR	DrawLinesPlane2
	BSR	FillBoardPlane2

	BSR	FillAndClear

	BSR	BlitScrolltext
	LEA	BoardYTable(PC),A0
	BSR	CalcYRotPos
	BSR	WriteCopperList

	CMP.W	#$300,IntroCounter	;Check counter for the startup delay
	BGT.S	IntroNoScroll
	BSR	ScrollBoard

IntroNoScroll:
	TST.W	IntroCounter
	BEQ.S	DoAnimation
	SUBQ.W	#1,IntroCounter		;Decrease counter until zero
	BRA.S	NoMove
DoAnimation:
	BSR.S	HandleAnimTable

NoMove:
	MOVE.W	RotationDelta(PC),D0
	ADD.W	D0,BoardRotation

	MOVE.W	DistanceDelta(PC),D0
	EXT.L	D0
	ADD.L	D0,BoardDistance

	MOVE.L	A6,-(SP)
	BSR	mt_music
	MOVE.L	(SP)+,A6

	BTST	#6,$BFE001	;Test LMB
	BNE	MainLoop
	RTS

RotationDelta:
	dc.w	0
lbW000566:
	dc.w	0
DistanceDelta:
	dc.w	0
IntroCounter:
	dc.w	1152

HandleAnimTable:
	LEA	AnimFrameCounter(PC),A2
	LEA	CommandTablePtr(PC),A3
	TST.W	(A2)
	BNE.S	DecrAnimFrameCounter
	LEA	lbC000000(PC),A1
	MOVE.L	(A3),A0
	MOVE.W	(A0),D0
	BNE.S	NotTableEnd
	NOT.W	AnimNegateFlag
	MOVE.L	#AnimCommandTable,(A3)
	BRA.S	HandleAnimTable

NotTableEnd:
	BMI.S	SetAnimFrames
	MOVE.W	2(A0),D1
	TST.W	AnimNegateFlag
	BEQ.S	DontNegateValue
	NEG.W	D1
DontNegateValue:
	MOVE.W	D1,0(A1,D0.W)		;Set value
	ADDQ.W	#4,A0			;Advance Command Ptr
	MOVE.L	A0,(A3)
	RTS

SetAnimFrames:
	MOVE.W	2(A0),(A2)		;Set number for frames
	ADDQ.W	#4,A0			;Advance command ptr
	MOVE.L	A0,(A3)
	RTS

DecrAnimFrameCounter:
	SUBQ.W	#1,(A2)			;Frame countdown
	RTS

;After the AnimCommandTable has completed, this flag is set and
;on the next run the set values are negated to provide more variation.
AnimNegateFlag:
	dc.w	0

CommandTablePtr:
	dc.l	AnimCommandTable

AnimFrameCounter:
	dc.w	0

; -1 is followed by the frame count for that animation sequence
AnimCommandTable:
	dc.w	RotationDelta-lbC000000,1
	dc.w	-1,100
	dc.w	DistanceDelta-lbC000000,2000
	dc.w	RotationDelta-lbC000000,4
	dc.w	-1,25
	dc.w	RotationDelta-lbC000000,8
	dc.w	-1,50
	dc.w	RotationDelta-lbC000000,16
	dc.w	-1,100
	dc.w	RotationDelta-lbC000000,8
	dc.w	-1,50
	dc.w	RotationDelta-lbC000000,4
	dc.w	-1,25
	dc.w	RotationDelta-lbC000000,-1
	dc.w	-1,40
	dc.w	RotationDelta-lbC000000,-4
	dc.w	-1,80
	dc.w	RotationDelta-lbC000000,-2
	dc.w	-1,40
	dc.w	DistanceDelta-lbC000000,0
	dc.w	RotationDelta-lbC000000,0
	dc.w	0

lbW000616:
	dc.w	0

FlipScreens:
	LEA	ScreenPtr1(PC),A0
	MOVEM.L	(A0),D0-D2
	EXG	D0,D1
	EXG	D1,D2
	MOVEM.L	D0-D2,(A0)
	LEA	CopperPtr1(PC),A0
	MOVE.L	(A0)+,D1
	MOVE.L	(A0),-(A0)
	MOVE.L	D1,4(A0)
	MOVE.L	D1,$80(A6)		;COP1LCx
	MOVE.L	D1,A0
	LEA	CopperBplOffset(A0),A0	;$142 Offset to screen ptrs in Copper list
	MOVE.W	D0,4(A0)		;ScreenPtr in D0
	SWAP	D0
	MOVE.W	D0,(A0)
	SWAP	D0
	ADD.L	#BitplaneSize,D0	;Next bitplane
	MOVE.W	D0,12(A0)
	SWAP	D0
	MOVE.W	D0,8(A0)
	RTS

ScreenPtr1:
	dc.l	ScreenBuffer1
ScreenPtr2:
	dc.l	ScreenBuffer2
ScreenPtr3:
	dc.l	ScreenBuffer3
CopperPtr1:
	dc.l	CopperList1
CopperPtr2:
	dc.l	CopperList2

FillAndClear:
	BSR	WaitBlitter
	MOVE.W	#$400,$96(A6)		;DMACON
	MOVE.L	#$3AA000A,D0
	ADD.B	lbB000D84(PC),D0	;Add 0 or 4, alternating
	MOVE.L	D0,$40(A6)		;BLTCON0+1
	CLR.W	$60(A6)			;BLTCMOD
	CLR.W	$66(A6)			;BLTDMOD
	MOVE.L	ScreenPtr2(PC),A0
	LEA	BitplaneSize,A1		;offset to bitplane 2
	LEA	-2(A0,A1.L),A0
	MOVE.L	A0,$48(A6)		;BLTCPTx
	MOVE.L	A0,$54(A6)		;BLTDPTx
	MOVE.W	#$3215,$58(A6)		;BLTSIZE
	BSR.S	ClearAreaScreen3
	BSR	WaitBlitter
	MOVE.L	#$3AA000A,$40(A6)	;BLTCON0+1
	CLR.W	$62(A6)			;BLTBMOD
	CLR.W	$66(A6)			;BLTDMOD
	MOVE.L	ScreenPtr2(PC),A0
	LEA	$41A0,A1		;offset to bitplane 3??
	LEA	-2(A0,A1.L),A0
	MOVE.L	A0,$48(A6)		;BLTCPTx
	MOVE.L	A0,$54(A6)		;BLTDPTx
	MOVE.W	#$3215,$58(A6)		;BLTSIZE
	BSR.S	ClearAreaScreen3
	BRA	WaitBlitter

ClearAreaScreen3:
	MOVE.L	A6,-(SP)
	MOVE.L	SP,StoreSP
	MOVE.L	ScreenPtr3(PC),SP
	ADD.L	A1,SP			;add offset
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVE.L	D0,A0
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	MOVE.L	D0,A5
	MOVE.L	D0,A6
	MOVEQ	#5,D7
.clrloop:
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	MOVEM.L	D0-D6/A0-A6,-(SP)
	DBRA	D7,.clrloop
	MOVE.L	StoreSP,SP
	MOVE.L	(SP)+,A6
	RTS

StoreSP:
	dc.l	0

InitDemo:
;	BSR	WaitDisksOff
	LEA	$DFF000,A6
;	MOVE.W	#$4000,$9A(A6)
;	CLR.L	0

	BSR	WaitBlitter

	LEA	LogoPalette(PC),A0
	LEA	CopperLogoPalette(PC),A1
	MOVEQ	#7,D0
lbC0007A2:
	MOVE.W	(A0)+,(A1)
	ADDQ.W	#4,A1
	DBRA	D0,lbC0007A2

	LEA	FontPalette(PC),A0
	LEA	CopperFontColors(PC),A1
	MOVE.W	#$188,D1
	MOVEQ	#6,D0
lbC0007B8:
	MOVE.W	D1,(A1)+
	ADDQ.W	#2,D1
	MOVE.W	(A0),(A1)+
	MOVE.W	D1,(A1)+
	ADDQ.W	#2,D1
	MOVE.W	(A0),(A1)+
	MOVE.W	D1,(A1)+
	ADDQ.W	#2,D1
	MOVE.W	(A0),(A1)+
	MOVE.W	D1,(A1)+
	ADDQ.W	#2,D1
	MOVE.W	(A0),(A1)+
	ADDQ.W	#2,A0
	DBRA	D0,lbC0007B8

	LEA	CopperLogoBpl(PC),A0
	MOVE.L	#StormLogo,D0
	MOVEQ	#2,D1
lbC0007E2:
	MOVE.W	D0,4(A0)
	SWAP	D0
	MOVE.W	D0,(A0)
	SWAP	D0
	ADD.L	#32,D0			;32 bytes per row
	ADDQ.W	#8,A0
	DBRA	D1,lbC0007E2

	LEA	CopperScrollBpl(PC),A0
	MOVE.L	#ScrollBitplane,D0
	MOVEQ	#2,D1
lbC000804:
	MOVE.W	D0,4(A0)
	SWAP	D0
	MOVE.W	D0,(A0)
	SWAP	D0
	ADD.L	#32*42,D0		;32 rows of 42 bytes
	ADDQ.W	#8,A0
	DBRA	D1,lbC000804

	BSR	FlipScreens
	BSR.S	InitCopperLists
	MOVE.B	#$F4,lbB008A14		;restore first byte of table?
;	MOVE.W	#$81C0,$96(A6)		;DMACON, missing DMA enable
	RTS

InitCopperLists:
	LEA	CopperListSource(PC),A0
	MOVE.L	CopperPtr1(PC),A1
	MOVE.L	CopperPtr2(PC),A2
	MOVE.L	#CopperBaseSize,D0	;Length of copper list source
lbC00083C:
	SUBQ.L	#1,D0
	BMI.S	lbC000846
	MOVE.B	(A0),(A1)+
	MOVE.B	(A0)+,(A2)+
	BRA.S	lbC00083C

lbC000846:
	MOVE.L	#$FFFFFFFE,(A1)+
	MOVE.L	#$FFFFFFFE,(A2)+
	RTS

;Original code for restoring the Workbench. Now handled by startup.i

;RestoreSystem:
;	BSR.S	WaitBlitter
;	MOVE.W	#$C000,$9A(A6)	;INTENA
;	MOVE.L	4.W,A6
;	LEA	GraphicsName(PC),A1
;	JSR	_LVOOldOpenLibrary(A6)
;	MOVE.L	D0,A1
;	MOVE.L	gb_copinit(A1),$DFF080	;COP1LCx
;	JMP	_LVOCloseLibrary(A6)

;GraphicsName:
;	dc.b	'graphics.library',0
;	even

;Original code for waiting for disk drives to turn off.
;Not compatible with modern Kickstarts.

;WaitDisksOff:
;	MOVE.L	4.W,A6
;	MOVE.L	A6,A0
;	LEA	DeviceList(A0),A0
;	LEA	TrackdiskName(PC),A1
;	JSR	_LVOFindName(A6)
;	MOVE.L	D0,A6
;	LEA	$24(A6),A6
;	MOVEQ	#3,D7
;DriveLoop:
;	TST.L	(A6)+
;	BEQ.S	SkipDrive
;	MOVE.L	-4(A6),A0
;lbC0008AA:
;	BTST	#7,$41(A0)
;	BEQ.S	lbC0008AA
;SkipDrive:
;	DBRA	D7,DriveLoop
;	RTS

;TrackdiskName:
;	dc.b	'trackdisk.device',0
;	even

WaitBlitter:
	BTST	#6,2(A6)
	BNE.S	.isbusy
	RTS

.isbusy:
	MOVE.W	#$8400,$96(A6)		;DMACON, set Blitter Prio
.wait:
	BTST	#6,2(A6)
	BNE.S	.wait
	MOVE.W	#$400,$96(A6)		;DMACON
	RTS

RotateBoardMatrix:
	MOVE.L	A0,A5
	LEA	SineTable(PC),A0
	LEA	lbW00090C(PC),A1
	MOVE.W	(A5)+,D0		;rotation value
	AND.W	#$3FF,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVEM.W	0(A0,D0.W),D2/D3	;get sin/cos
	MOVE.W	D3,(A1)+
	NEG.W	D2
	MOVE.W	D2,(A1)+
	BRA.S	lbC00091A

lbW00090C:
	dc.w	0
	dc.w	0
	dc.w	160			;offset x
	dc.w	100			;offset y

BoardDistance:
	dc.l	$26000

RotateXYCoords:
	MOVE.L	A0,A5
lbC00091A:
	MOVE.W	(A5)+,D7
	LEA	lbW00090C(PC),A3
	MOVEM.W	(A3)+,D3-D6
	MOVE.L	(A3)+,A2
	LEA	CalcBuffer,A4
	BRA.S	lbC00094E

lbC00092E:
	MOVE.W	(A5)+,D0
	MOVE.W	(A5)+,D1
	MOVE.W	D1,D2
	EXT.L	D0
	LSL.L	#8,D0
	MULS	D3,D1
	MULS	D4,D2
	ADD.L	A2,D2
	SWAP	D2
	ROL.L	#7,D2
	DIVS	D2,D0
	DIVS	D2,D1
	ADD.W	D5,D0
	ADD.W	D6,D1
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
lbC00094E:
	DBRA	D7,lbC00092E
	RTS

CalcYRotPos:
	MOVE.L	A0,A5
	MOVE.W	(A5)+,D7
	LEA	lbW00090C(PC),A3
	MOVEM.W	(A3)+,D3-D6
	MOVE.L	(A3)+,A2
	LEA	CalcBuffer,A4
	BRA.S	lbC00097E

lbC00096A:
	MOVE.W	(A5)+,D1
	MOVE.W	D1,D2
	MULS	D3,D1
	MULS	D4,D2
	ADD.L	A2,D2
	SWAP	D2
	ROL.L	#7,D2
	DIVS	D2,D1
	ADD.W	D6,D1
	MOVE.W	D1,(A4)+
lbC00097E:
	DBRA	D7,lbC00096A
	RTS

DrawLinesPlane1:
	MOVE.L	ScreenPtr2(PC),A0
	LEA	CalcBuffer,A4
	MOVE.W	(A5)+,D7
	BRA.S	lbC0009B0

lbC000992:
	MOVE.W	(A5)+,D0
	MOVE.W	(A5)+,D2
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D2,D2
	ADD.W	D2,D2
	MOVEM.W	0(A4,D0.W),D0/D1
	MOVEM.W	0(A4,D2.W),D2/D3
	MOVE.W	D7,A2
	BSR.S	DrawLine
	MOVE.W	A2,D7
lbC0009B0:
	DBRA	D7,lbC000992
	RTS

DrawLinesPlane2:
	MOVE.L	ScreenPtr2(PC),A0
	LEA	BitplaneSize(A0),A0
	LEA	CalcBuffer,A4
	MOVE.W	(A5)+,D7
	BRA.S	lbC0009E6

lbC0009C8:
	MOVE.W	(A5)+,D0
	MOVE.W	(A5)+,D2
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D2,D2
	ADD.W	D2,D2
	MOVEM.W	0(A4,D0.W),D0/D1
	MOVEM.W	0(A4,D2.W),D2/D3
	MOVE.W	D7,A2
	BSR.S	DrawLine
	MOVE.W	A2,D7
lbC0009E6:
	DBRA	D7,lbC0009C8
	RTS

PrepBlitterForLines:
	BSR	WaitBlitter
	MOVE.W	#$8000,$74(A6)		;BLTADAT
	MOVEQ	#-1,D0
	MOVE.W	D0,$44(A6)		;BLTAFWM
	MOVE.W	D0,$72(A6)		;BLTBDAT
	MOVEQ	#42,D0
	MOVE.W	D0,$60(A6)		;BLTCMOD
	MOVE.W	D0,$66(A6)		;BLTDMOD
	RTS

DrawLine:
	CLR.W	lbB000BD4
	CMP.W	D1,D3
	BGT.S	lbC000A1A
	EXG	D1,D3
	EXG	D0,D2
lbC000A1A:
	MOVEM.W	(MaxScreenXY,PC),D4/D5
	CMP.W	D0,D4
	BCS	lbC000BD6
	CMP.W	D2,D4
	BCS	lbC000BD6
	CMP.W	D1,D5
	BCS	lbC000BD6
	CMP.W	D3,D5
	BCS	lbC000BD6
lbC000A38:
	TST.W	lbB000BD4
	BEQ.S	lbC000A6C
	CMP.W	lbW000CC2(PC),D1
	BLE.S	lbC000A56
	LEA	lbW000E18(PC),A1
	ADDQ.W	#4,(A1)
	ADD.W	(A1),A1
	MOVE.W	D1,(A1)
	SUBQ.W	#1,(A1)+
	MOVE.W	lbW000CC2(PC),(A1)+
lbC000A56:
	CMP.W	lbW000CC4(PC),D3
	BGE.S	lbC000A6C
	LEA	lbW000E18(PC),A1
	ADDQ.W	#4,(A1)
	ADD.W	(A1),A1
	MOVE.W	D3,(A1)
	ADDQ.W	#1,(A1)+
	MOVE.W	lbW000CC4(PC),(A1)+
lbC000A6C:
	MOVE.L	A0,A1
	MOVE.W	D1,D4
	MULU	#42,D4
	MOVEQ	#-$10,D5
	AND.W	D0,D5
	LSR.W	#3,D5
	ADD.W	D5,D4
	ADD.W	D4,A1
	MOVEQ	#15,D5
	AND.W	D0,D5
	SUB.W	D1,D3
	SUB.W	D0,D2
	ROXL.B	#1,D5
	TST.W	D2
	BGE.S	lbC000A8E
	NEG.W	D2
lbC000A8E:
	MOVE.W	D3,D1
	SUB.W	D2,D1
	BGE.S	lbC000A96
	EXG	D2,D3
lbC000A96:
	ROXL.B	#1,D5
	ADD.W	D5,D5
	ADD.W	D5,D5
	MOVE.L	BltConTable(PC,D5.W),D5
	ADD.W	D2,D2
	BSR	WaitBlitter
	MOVE.W	D2,$62(A6)		;BLTBMOD
	SUB.W	D3,D2
	BGE.S	lbC000AB2
	OR.B	#$40,D5			;+SIGN bit
lbC000AB2:
	MOVE.W	D2,$52(A6)		;BLTAPTL
	SUB.W	D3,D2
	MOVE.W	D2,$64(A6)		;BLTAMOD
	MOVE.L	D5,$40(A6)		;BLTCON0
	MOVE.L	A1,$48(A6)		;BLTCPTH
	MOVE.L	A1,$54(A6)		;BLTDPTH
	LSL.W	#6,D3
	ADD.W	#$42,D3			;+1 height, width=2
	MOVE.W	D3,$58(A6)		;BLTSIZE
lbC000AD2:
	RTS

BltConTable:
	dc.l	$0BCA0003
	dc.l	$0BCA0013
	dc.l	$0BCA000B
	dc.l	$0BCA0017
	dc.l	$1BCA0003
	dc.l	$1BCA0013
	dc.l	$1BCA000B
	dc.l	$1BCA0017
	dc.l	$2BCA0003
	dc.l	$2BCA0013
	dc.l	$2BCA000B
	dc.l	$2BCA0017
	dc.l	$3BCA0003
	dc.l	$3BCA0013
	dc.l	$3BCA000B
	dc.l	$3BCA0017
	dc.l	$4BCA0003
	dc.l	$4BCA0013
	dc.l	$4BCA000B
	dc.l	$4BCA0017
	dc.l	$5BCA0003
	dc.l	$5BCA0013
	dc.l	$5BCA000B
	dc.l	$5BCA0017
	dc.l	$6BCA0003
	dc.l	$6BCA0013
	dc.l	$6BCA000B
	dc.l	$6BCA0017
	dc.l	$7BCA0003
	dc.l	$7BCA0013
	dc.l	$7BCA000B
	dc.l	$7BCA0017
	dc.l	$8BCA0003
	dc.l	$8BCA0013
	dc.l	$8BCA000B
	dc.l	$8BCA0017
	dc.l	$9BCA0003
	dc.l	$9BCA0013
	dc.l	$9BCA000B
	dc.l	$9BCA0017
	dc.l	$ABCA0003
	dc.l	$ABCA0013
	dc.l	$ABCA000B
	dc.l	$ABCA0017
	dc.l	$BBCA0003
	dc.l	$BBCA0013
	dc.l	$BBCA000B
	dc.l	$BBCA0017
	dc.l	$CBCA0003
	dc.l	$CBCA0013
	dc.l	$CBCA000B
	dc.l	$CBCA0017
	dc.l	$DBCA0003
	dc.l	$DBCA0013
	dc.l	$DBCA000B
	dc.l	$DBCA0017
	dc.l	$EBCA0003
	dc.l	$EBCA0013
	dc.l	$EBCA000B
	dc.l	$EBCA0017
	dc.l	$FBCA0003
	dc.l	$FBCA0013
	dc.l	$FBCA000B
	dc.l	$FBCA0017

lbB000BD4:
	dc.b	0

lbB000BD5:
	dc.b	0

lbC000BD6:
	MOVE.W	D1,lbW000CC2
	MOVE.W	D3,lbW000CC4
	BSR	lbC000C8E
	BNE	lbC000AD2
	TST.W	D1
	BPL.S	lbC000BFE
	BSR	lbC000CC6
	MOVEQ	#0,D1
	MOVE.W	D3,D0
	NEG.W	D0
	MULS	D6,D0
	LSR.L	#8,D0
	ADD.W	D2,D0
lbC000BFE:
	CMP.W	D5,D3
	BLE.S	lbC000C12
	BSR	lbC000CC6
	MOVE.W	D5,D3
	MOVE.W	D3,D2
	SUB.W	D1,D2
	MULS	D6,D2
	LSR.L	#8,D2
	ADD.W	D0,D2
lbC000C12:
	MOVE.W	D1,lbW000CC2
	MOVE.W	D3,lbW000CC4
	TST.W	D2
	BPL.S	lbC000C34
	BSR	lbC000CD8
	MOVE.W	D0,D3
	NEG.W	D3
	MULS	D6,D3
	LSR.L	#8,D3
	ADD.W	D1,D3
	MOVEQ	#0,D2
	BRA.S	lbC000C4E

lbC000C34:
	CMP.W	D4,D2
	BLE.S	lbC000C4E
	BSR	lbC000CD8
	MOVE.W	D4,D2
	MOVE.W	D2,D3
	SUB.W	D0,D3
	MULS	D6,D3
	LSR.L	#8,D3
	ADD.W	D1,D3
	ST	lbB000BD5
lbC000C4E:
	TST.W	D0
	BPL.S	lbC000C64
	BSR	lbC000CD8
	MOVE.W	D2,D1
	NEG.W	D1
	MULS	D6,D1
	LSR.L	#8,D1
	ADD.W	D3,D1
	MOVEQ	#0,D0
	BRA.S	lbC000C7C

lbC000C64:
	CMP.W	D4,D0
	BLE.S	lbC000C7C
	BSR.S	lbC000CD8
	MOVE.W	D4,D0
	MOVE.W	D0,D1
	SUB.W	D2,D1
	MULS	D6,D1
	LSR.L	#8,D1
	ADD.W	D3,D1
	ST	lbB000BD4
lbC000C7C:
	BSR.S	lbC000C8E
	BNE	lbC000AD2
	CMP.W	D1,D3
	BGT.S	lbC000C8A
	EXG	D1,D3
	EXG	D0,D2
lbC000C8A:
	BRA	lbC000A38

lbC000C8E:
	CMP.W	D4,D0
	BLT.S	lbC000C96
	CMP.W	D4,D2
	BGE.S	lbC000CAE
lbC000C96:
	TST.W	D0
	BGE.S	lbC000C9E
	TST.W	D2
	BLT.S	lbC000CAA
lbC000C9E:
	CMP.W	D5,D1
	BGE.S	lbC000CAA
	TST.W	D3
	BLT.S	lbC000CAA
	MOVEQ	#0,D6
	RTS

lbC000CAA:
	MOVEQ	#-1,D6
	RTS

lbC000CAE:
	LEA	lbW000E18(PC),A1
	ADDQ.W	#4,(A1)
	ADD.W	(A1),A1
	MOVE.W	lbW000CC2(PC),(A1)+
	MOVE.W	lbW000CC4(PC),(A1)
	MOVEQ	#-1,D6
	RTS

lbW000CC2:
	dc.w	0

lbW000CC4:
	dc.w	0

lbC000CC6:
	MOVE.W	D2,D6
	SUB.W	D0,D6
	EXT.L	D6
	LSL.L	#8,D6
	MOVE.W	D3,D7
	SUB.W	D1,D7
	BEQ.S	.nodivzero
	DIVS	D7,D6
.nodivzero:
	RTS

lbC000CD8:
	MOVE.W	D3,D6
	SUB.W	D1,D6
	EXT.L	D6
	LSL.L	#8,D6
	MOVE.W	D2,D7
	SUB.W	D0,D7
	BEQ.S	.nodivzero
	DIVS	D7,D6
.nodivzero:
	RTS

MaxScreenXY:
	dc.w	319
	dc.w	199

ScrollBoardX:
	LEA	lbW000E70(PC),A0
	MOVE.L	A0,A1
	MOVE.W	#1000,D1
	MOVEQ	#0,D3
	MOVEQ	#9,D7
	MOVE.W	lbW000616,D2
	BMI.S	lbC000D22
	MOVE.W	#500,D0
lbC000D08:
	ADD.W	D2,(A0)
	CMP.W	(A0),D0
	BLE.S	lbC000D16
	ADDQ.W	#4,A0
	DBRA	D7,lbC000D08
	BRA.S	lbC000D3E

lbC000D16:
	SUB.W	D1,(A0)
	ADDQ.B	#1,D3
	ADDQ.W	#4,A0
	DBRA	D7,lbC000D08
	BRA.S	lbC000D3E

lbC000D22:
	MOVE.W	#-500,D0
lbC000D26:
	ADD.W	D2,(A0)
	CMP.W	(A0),D0
	BGE.S	lbC000D34
	ADDQ.W	#4,A0
	DBRA	D7,lbC000D26
	BRA.S	lbC000D3E

lbC000D34:
	ADD.W	D1,(A0)
	ADDQ.B	#1,D3
	ADDQ.W	#4,A0
	DBRA	D7,lbC000D26
lbC000D3E:
	MOVE.W	(A1),(A0)
	MOVE.W	4(A1),4(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	12(A1),12(A0)
	MOVE.W	$10(A1),$10(A0)
	MOVE.W	$14(A1),$14(A0)
	MOVE.W	$18(A1),$18(A0)
	MOVE.W	$1C(A1),$1C(A0)
	MOVE.W	$20(A1),$20(A0)
	MOVE.W	$24(A1),$24(A0)
	TST.B	D3
	BEQ.S	lbC000D82
	EOR.B	#4,lbB000D84
lbC000D82:
	RTS

lbB000D84:
	dc.b	0
	even

FillBoardPlane1:
	MOVE.L	ScreenPtr2(PC),A3
	BRA.S	lbC000D94

FillBoardPlane2:
	MOVE.L	ScreenPtr2(PC),A3
	LEA	BitplaneSize(A3),A3
lbC000D94:
	LEA	lbW000E18(PC),A0
	MOVE.W	(A0),D7			;get number of entries
	BEQ.S	lbC000E0E
	ADDQ.W	#4,A0
	LEA	40(A3),A3
	BSR	WaitBlitter
	MOVE.L	#$B500000,$40(A6)	;BLTCON0+1
	MOVEQ	#-1,D0
	MOVE.L	D0,$44(A6)		;BLTAFWM+LWM
	MOVEQ	#40,D0
	MOVE.W	D0,$60(A6)		;BLTCMOD
	MOVE.W	#$FFFE,$64(A6)		;BLTAMOD = -2
	MOVE.W	D0,$66(A6)		;BLTDMOD
	MOVE.L	#lbW000E16,$50(A6)	;BLTAPTx
	MOVE.W	#199,D2
	LSR.W	#2,D7			;div 4
	SUBQ.W	#1,D7			;-1 for DBRA
.loop:
	MOVE.W	(A0)+,D0		;get Y1
	MOVE.W	(A0)+,D1		;get Y2
	CMP.W	D0,D1
	BGT.S	.YOrderOk
	EXG	D0,D1
.YOrderOk:
	TST.W	D0
	BPL.S	.MinYOk
	MOVEQ	#0,D0
.MinYOk:
	CMP.W	D2,D1
	BLT.S	.MaxYOk
	MOVE.W	D2,D1
.MaxYOk:
	SUB.W	D0,D1			;calc height
	ADDQ.W	#1,D1			;+1 to height
	BLE.S	lbC000E0E
	LSL.W	#6,D1			;shift height for BLTSIZE
	ADDQ.W	#1,D1			;Width 1
	MULU	#42,D0			;Y*42 bytes per line
	ADD.L	A3,D0
	BSR	WaitBlitter
	MOVE.L	D0,$48(A6)		;BLTCPTx
	MOVE.L	D0,$54(A6)		;BLTDPTx
	MOVE.W	D1,$58(A6)		;BLTSIZE
	DBRA	D7,.loop
lbC000E0E:
	CLR.L	lbW000E18		;Reset number of entries
	RTS

lbW000E16:
	dc.w	$8000
lbW000E18:
	ds.w	42

BoardRotation:
	dc.w	248			;Board rotation value

	dc.w	20			;20 2-word coordinates
lbW000E70:
	dc.w	-500,-500
	dc.w	-400,-500
	dc.w	-300,-500
	dc.w	-200,-500
	dc.w	-100,-500
	dc.w	0,-500
	dc.w	100,-500
	dc.w	200,-500
	dc.w	300,-500
	dc.w	400,-500
	dc.w	-500,500
	dc.w	-400,500
	dc.w	-300,500
	dc.w	-200,500
	dc.w	-100,500
	dc.w	0,500
	dc.w	100,500
	dc.w	200,500
	dc.w	300,500
	dc.w	400,500

	dc.w	10
	dc.W	0,10
	dc.w	1,11
	dc.w	2,12
	dc.w	3,13
	dc.w	4,14
	dc.w	5,15
	dc.w	6,16
	dc.w	7,17
	dc.w	8,18
	dc.w	9,19

BoardCoordTable:
	dc.w	4			;4 2-word coordinates
	dc.w	-500,-500
	dc.w	500,-500
	dc.w	-500,500
	dc.w	500,500

	dc.w	2
	dc.w	0,2
	dc.w	1,3

BoardYTable:
	dc.w	10			;10 entries, y values
lbW000F08:
	dc.w	-500
	dc.w	-400
	dc.w	-300
	dc.w	-200
	dc.w	-100
	dc.w	0
	dc.w	100
	dc.w	200
	dc.w	300
	dc.w	400

WriteCopperList:
	SF	PALWaitWrittenFlag
	SF	Line76Flag
	SF	Line44Flag
	LEA	CalcBuffer,A0
	MOVE.L	CopperPtr1(PC),A1
	LEA	CopperBoardOffset(A1),A1	;$15C
	MOVE.W	#199,D5
	MOVE.W	#$555,D0		;grey
	MOVE.W	#$FFF,D1		;white
	TST.W	WhiteOrGrayFlag
	BEQ.S	.dontswitch
	EXG	D0,D1
.dontswitch:
	MOVE.W	D0,6(A1)
	MOVE.W	D1,10(A1)
	EXG	D0,D1
	MOVEQ	#0,D3
	MOVEQ	#2,D6			;Delta for y-pos table
	MOVE.W	(A0),D2
	CMP.W	18(A0),D2
	BLT.S	lbC000F6E
	LEA	18(A0),A0
	NEG.W	D6
lbC000F6E:
	MOVEQ	#9,D7
CopperYLoop:
	MOVE.W	(A0),D4
	BPL.S	lbC000F78
	MOVEQ	#0,D4
	BRA.S	lbC000F7E

lbC000F78:
	CMP.W	D5,D4
	BLE.S	lbC000F7E
	MOVE.W	D5,D4
lbC000F7E:
	CMP.W	D3,D4
	BEQ	lbC001026
	CMP.W	#44,D4
	BLT.S	lbC000FAC
	TST.B	Line44Flag
	BNE.S	lbC000FAC
	ST	Line44Flag
	MOVE.L	#$90DFFFFE,12(A1)
	MOVE.L	#$1005200,$10(A1)	;BPLCON0, 5 bitplanes
	LEA	8(A1),A1
lbC000FAC:
	CMP.W	#76,D4
	BLT.S	lbC000FD4
	TST.B	Line76Flag
	BNE.S	lbC000FD4
	ST	Line76Flag
	MOVE.L	#$B0DFFFFE,12(A1)
	MOVE.L	#$1002200,$10(A1)	;BPLCON0, 2 bitplanes
	LEA	8(A1),A1
lbC000FD4:
	CMP.W	#155,D4
	BLT.S	SkipPALWait
	BEQ.S	OverPALPos
	TST.B	PALWaitWrittenFlag
	BNE.S	SkipPALWait
	LEA	12(A1),A1
	MOVE.L	#$FFDFFFFE,(A1)+	;Wait for line 255 => PAL
	ST	PALWaitWrittenFlag
	MOVE.W	D4,D3
	ADD.W	#100,D4
	BRA.S	lbC00100C

OverPALPos:
	ST	PALWaitWrittenFlag
SkipPALWait:
	MOVE.W	D4,D3
	ADD.W	#100,D4
	LEA	12(A1),A1
lbC00100C:
	MOVE.B	D4,(A1)
	MOVE.B	#$DF,1(A1)
	MOVE.W	#$FFFE,2(A1)
	MOVE.W	#$184,4(A1)		;COLOR02
	MOVE.W	#$186,8(A1)		;COLOR03
lbC001026:
	MOVE.W	D0,6(A1)		;write colors
	MOVE.W	D1,10(A1)
	EXG	D0,D1			;switch colors
	ADD.W	D6,A0
	DBRA	D7,CopperYLoop
	LEA	12(A1),A1
	TST.B	Line44Flag
	BNE.S	lbC00104E
	MOVE.L	#$90DFFFFE,(A1)+
	MOVE.L	#$1005200,(A1)+
lbC00104E:
	TST.B	Line76Flag
	BNE.S	lbC001062
	MOVE.L	#$B0DFFFFE,(A1)+
	MOVE.L	#$1002200,(A1)+
lbC001062:
	TST.B	PALWaitWrittenFlag
	BNE.S	lbC001070
	MOVE.L	#$FFDFFFFE,(A1)+
lbC001070:
	MOVE.L	#$2C07FFFE,(A1)+
	MOVE.L	#$1000200,(A1)+
	MOVEQ	#-2,D0			;$FFFFFFFE, end copper list
	MOVE.L	D0,(A1)+
	RTS

PALWaitWrittenFlag:
	dc.b	0
Line44Flag:
	dc.b	0
Line76Flag:
	dc.b	0
	even

ScrollBoardY:
	LEA	lbW000F08(PC),A0
	MOVE.W	#1000,D1
	MOVEQ	#0,D3
	MOVEQ	#9,D7
	MOVE.W	lbW00111C(PC),D2
	BMI.S	lbC0010DA
	MOVE.W	#500,D0
lbC00109C:
	ADD.W	D2,(A0)
	CMP.W	(A0)+,D0
	BLE.S	lbC0010A8
	DBRA	D7,lbC00109C
	BRA.S	lbC0010B2

lbC0010A8:
	SUB.W	D1,-2(A0)
	ADDQ.B	#1,D3
	DBRA	D7,lbC00109C
lbC0010B2:
	BRA.S	lbC0010D4

lbC0010B4:
	LEA	lbW000F08(PC),A0
	LEA	$14(A0),A1
	LEA	$12(A0),A2
	MOVE.W	(A2),D0
	MOVE.L	-(A2),-(A1)
	MOVE.L	-(A2),-(A1)
	MOVE.L	-(A2),-(A1)
	MOVE.L	-(A2),-(A1)
	MOVE.W	-(A2),-(A1)
	MOVE.W	D0,(A0)
	NOT.W	WhiteOrGrayFlag
lbC0010D4:
	DBRA	D3,lbC0010B4
	RTS

lbC0010DA:
	MOVE.W	#-500,D0
lbC0010DE:
	ADD.W	D2,(A0)
	CMP.W	(A0)+,D0
	BGE.S	lbC0010EA
	DBRA	D7,lbC0010DE
	BRA.S	lbC0010F4

lbC0010EA:
	ADD.W	D1,-2(A0)
	ADDQ.B	#1,D3
	DBRA	D7,lbC0010DE
lbC0010F4:
	BRA.S	lbC001116

lbC0010F6:
	LEA	lbW000F08(PC),A0
	MOVE.L	A0,A1
	LEA	2(A0),A2
	MOVE.W	(A0),D0
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.W	(A2)+,(A1)+
	MOVE.W	D0,$12(A0)
	NOT.W	WhiteOrGrayFlag
lbC001116:
	DBRA	D3,lbC0010F6
	RTS

lbW00111C:
	dc.w	0
WhiteOrGrayFlag:
	dc.w	0

DoScrollText:
	SUBQ.W	#4,ScrollPixels
	BEQ.S	FirstHalf
	CMP.W	#$10,ScrollPixels
	BEQ.S	SecondHalf
	RTS

SecondHalf:
	BSR.S	GetScrollCharPtr
	BRA.S	BlitChar

FirstHalf:
	BSR.S	GetScrollCharPtr
	MOVE.W	#$20,ScrollPixels
	ADDQ.W	#2,A0
	ADDQ.W	#1,ScrollTextIndex
BlitChar:
	BSR	WaitBlitter
	MOVE.L	#$9F00000,$40(A6)		;BLTCON0+1
	MOVEQ	#-1,D0
	MOVE.L	D0,$44(A6)			;BLTAFWM+LWM
	MOVE.W	#$76,$64(A6)			;BLTAMOD
	MOVE.W	#$28,$66(A6)			;BLTDMOD
	MOVE.L	A0,$50(A6)			;BLTAPTx
	MOVE.L	#ScrollBitplane+40,$54(A6)	;BLTDPTx
	MOVE.W	#$801,$58(A6)			;BLTSIZE
	LEA	$28(A0),A0			;offset to next bitplane in source
	BSR	WaitBlitter
	MOVE.L	A0,$50(A6)			;BLTAPTx
	MOVE.W	#$801,$58(A6)			;BLTSIZE

	LEA	$28(A0),A0			;offset to next bitplane in source
	BSR	WaitBlitter
	MOVE.L	A0,$50(A6)			;BLTAPTx
	MOVE.W	#$801,$58(A6)			;BLTSIZE
	RTS

GetScrollCharPtr:
	LEA	ScrollText(PC),A1
	ADD.W	ScrollTextIndex(PC),A1
	MOVEQ	#0,D0
	MOVE.B	(A1),D0
	BNE.S	ScrollNotEnded
	CLR.W	ScrollTextIndex
	BRA.S	GetScrollCharPtr

ScrollNotEnded:
	LEA	ScrollFont(PC),A0
	LEA	CharList(PC),A1
ScrollFindChar:
	MOVE.B	(A1)+,D1
	BMI.S	SkipRow
	BEQ.S	EndOfText
	CMP.B	D0,D1
	BEQ.S	CharFound
	ADDQ.W	#4,A0
	BRA.S	ScrollFindChar

CharFound:
	RTS

EndOfText:
	MOVEQ	#$20,D0
	BRA.S	ScrollNotEnded

SkipRow:
	LEA	95*40(A0),A0		;skip one row of the charset
	BRA.S	ScrollFindChar

ScrollPixels:
	dc.w	20
ScrollTextIndex:
	dc.w	0
CharList:
	dc.b	'abcdefghij',-1
	dc.b	'klmnopqrst',-1
	dc.b	'uvwxyz0123',-1
	dc.b	'456789!:"''',-1
	dc.b	',.-STORMI ',0
	even

;Advance scroll text 4 pixels to the left
BlitScrolltext:
	BSR	WaitBlitter
	MOVE.L	#$49F00002,$40(A6)	;BLTCON0+1
	MOVEQ	#-1,D0
	MOVE.L	D0,$44(A6)		;BLTAFWM+LWM
	CLR.L	$64(A6)			;BLTAMOD+BLTDMOD
	LEA	ScrollBitplane+95*42-2,A0
	MOVE.L	A0,$50(A6)		;BLTAPTx
	MOVE.L	A0,$54(A6)		;BLTDPTx
	MOVE.W	#$1815,$58(A6)		;BLTSIZE
	RTS

;Set the scrolling of the checkerboard
ScrollBoard:
	MOVE.W	$DFF00A,D0		;JOY0DAT (mouse position)
	CLR.W	$DFF036			;JOYTEST
	MOVE.W	D0,D1
	SUB.W	lbW000566(PC),D0
	AND.W	#$303,D1		;Only use lower 3 bits for mouse x/y
	MOVE.W	D1,lbW000566
	MOVE.W	D0,D1
	LSR.W	#8,D1
	EXT.W	D0
	EXT.W	D1
	MOVE.W	D0,lbW000616
	MOVE.W	D1,lbW00111C
	LEA	lbW0012A8(PC),A1
	LEA	lbB008A14(PC),A0
	MOVE.W	(A1),D0			;get offsets
	MOVE.W	2(A1),D1
	MOVE.B	0(A0,D0.W),D0		;get deltas
	MOVE.B	0(A0,D1.W),D1
	EXT.W	D0
	EXT.W	D1
	ADD.W	D0,lbW000616		;add deltas
	ADD.W	D1,lbW00111C
	ADDQ.W	#1,(A1)			;increase offsets
	ADDQ.W	#1,2(A1)
	AND.W	#$1FF,(A1)
	AND.W	#$1FF,2(A1)
	RTS

lbW0012A8:
	dc.w	0
	dc.w	$80

**********************************************************
* Classic ProTracker replay routine
* Raster line wait added to accommodate faster processors
**********************************************************

mt_init:
	LEA	mt_module,A0
	ADD.L	#$3B8,A0
	MOVEQ	#$7F,D0
	MOVEQ	#0,D1
lbC0012BC:
	MOVE.L	D1,D2
	SUBQ.W	#1,D0
lbC0012C0:
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	lbC0012BC
	DBRA	D0,lbC0012C0
	ADDQ.B	#1,D2
	LEA	mt_module,A0
	LEA	lbL0017BC(PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#$438,D2
	ADD.L	A0,D2
	MOVEQ	#$1E,D0
lbC0012E4:
	MOVE.L	D2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	$2A(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,D2
	ADD.L	D1,D3
	ADD.L	#$1E,A0
	DBRA	D0,lbC0012E4
	LEA	lbL0017BC(PC),A0
	MOVEQ	#0,D0
lbC001302:
	MOVE.L	0(A0,D0.W),A1
	CLR.L	(A1)
	ADDQ.W	#4,D0
	CMP.W	#$7C,D0
	BNE.S	lbC001302
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	CLR.L	lbL0017AE
	CLR.L	lbL0017AA
	CLR.L	lbL0017B4
	MOVE.B	mt_module+$3B6,lbB001839
	RTS

mt_stop:
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	MOVE.W	#15,$DFF096
	RTS

mt_music:
	ADDQ.W	#1,lbW0017B2
	CMP.W	#6,lbW0017B2
mt_speed:	EQU	*-5
	BNE.S	lbC001382
	CLR.W	lbW0017B2
	BRA	lbC0014CE

lbC001382:
	LEA	lbL001742(PC),A6
	TST.B	3(A6)
	BEQ.S	lbC001394
	LEA	$DFF0A0,A5
	BSR.S	lbC0013CC
lbC001394:
	LEA	lbL00175C(PC),A6
	TST.B	3(A6)
	BEQ.S	lbC0013A6
	LEA	$DFF0B0,A5
	BSR.S	lbC0013CC
lbC0013A6:
	LEA	lbL001776(PC),A6
	TST.B	3(A6)
	BEQ.S	lbC0013B8
	LEA	$DFF0C0,A5
	BSR.S	lbC0013CC
lbC0013B8:
	LEA	lbL001790(PC),A6
	TST.B	3(A6)
	BEQ.S	lbC0013CA
	LEA	$DFF0D0,A5
	BRA.S	lbC0013CC

lbC0013CA:
	RTS

lbC0013CC:
	MOVE.B	2(A6),D0
	AND.B	#15,D0
	TST.B	D0
	BEQ	lbC001470
	CMP.B	#1,D0
	BEQ.S	lbC0013EE
	CMP.B	#2,D0
	BEQ.S	lbC00140E
	CMP.B	#10,D0
	BEQ.S	lbC00142E
	RTS

lbC0013EE:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	SUB.W	D0,$16(A6)
	CMP.W	#$71,$16(A6)
	BPL.S	lbC001406
	MOVE.W	#$71,$16(A6)
lbC001406:
	MOVE.W	$16(A6),6(A5)
	RTS

lbC00140E:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ADD.W	D0,$16(A6)
	CMP.W	#$538,$16(A6)
	BMI.S	lbC001426
	MOVE.W	#$538,$16(A6)
lbC001426:
	MOVE.W	$16(A6),6(A5)
	RTS

lbC00142E:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	lbC001454
	ADD.W	D0,$12(A6)
	CMP.W	#$40,$12(A6)
	BMI.S	lbC00144C
	MOVE.W	#$40,$12(A6)
lbC00144C:
	MOVE.W	$12(A6),8(A5)
	RTS

lbC001454:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	#15,D0
	SUB.W	D0,$12(A6)
	BPL.S	lbC001468
	CLR.W	$12(A6)
lbC001468:
	MOVE.W	$12(A6),8(A5)
	RTS

lbC001470:
	MOVE.W	lbW0017B2(PC),D0
	CMP.W	#1,D0
	BEQ.S	lbC001494
	CMP.W	#2,D0
	BEQ.S	lbC00149E
	CMP.W	#3,D0
	BEQ.S	lbC0014AA
	CMP.W	#4,D0
	BEQ.S	lbC001494
	CMP.W	#5,D0
	BEQ.S	lbC00149E
	RTS

lbC001494:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.S	lbC0014B0

lbC00149E:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	#15,D0
	BRA.S	lbC0014B0

lbC0014AA:
	MOVE.W	$10(A6),D2
	BRA.S	lbC0014C8

lbC0014B0:
	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.W	$10(A6),D1
	LEA	mt_period(PC),A0
lbC0014BC:
	MOVE.W	0(A0,D0.W),D2
	CMP.W	(A0),D1
	BEQ.S	lbC0014C8
	ADDQ.L	#2,A0
	BRA.S	lbC0014BC

lbC0014C8:
	MOVE.W	D2,6(A5)
	RTS

lbC0014CE:
	LEA	mt_module,A0
	MOVE.L	A0,A3
	ADD.L	#12,A3
	MOVE.L	A0,A2
	ADD.L	#$3B8,A2
	ADD.L	#$43C,A0
	MOVE.L	lbL0017AE(PC),D0
	MOVEQ	#0,D1
	MOVE.B	0(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.L	lbL0017AA(PC),D1
	MOVE.L	D1,lbL0017B4
	CLR.W	lbW00183A
	LEA	$DFF0A0,A5
	LEA	lbL001742(PC),A6
	BSR	lbC001612
	LEA	$DFF0B0,A5
	LEA	lbL00175C(PC),A6
	BSR	lbC001612
	LEA	$DFF0C0,A5
	LEA	lbL001776(PC),A6
	BSR	lbC001612
	LEA	$DFF0D0,A5
	LEA	lbL001790(PC),A6
	BSR	lbC001612

;	MOVE.W	#$1F4,D0
;lbC001544:
;	DBRA	D0,lbC001544

;Use raster line wait for faster processors
	MOVEQ	#5,D0
mt_waitlines:
	MOVE.B	$DFF006,D1
mt_sameline:
	CMP.B	$DFF006,D1
	BEQ.S	mt_sameline
	DBRA	D0,mt_waitlines

	MOVE.W	#$8000,D0
	OR.W	lbW00183A,D0
	MOVE.W	D0,$DFF096
	LEA	lbL001790(PC),A6
	CMP.W	#1,14(A6)
	BNE.S	lbC001574
	MOVE.L	10(A6),$DFF0D0
	MOVE.W	#1,$DFF0D4
lbC001574:
	LEA	lbL001776(PC),A6
	CMP.W	#1,14(A6)
	BNE.S	lbC001590
	MOVE.L	10(A6),$DFF0C0
	MOVE.W	#1,$DFF0C4
lbC001590:
	LEA	lbL00175C(PC),A6
	CMP.W	#1,14(A6)
	BNE.S	lbC0015AC
	MOVE.L	10(A6),$DFF0B0
	MOVE.W	#1,$DFF0B4
lbC0015AC:
	LEA	lbL001742(PC),A6
	CMP.W	#1,14(A6)
	BNE.S	lbC0015C8
	MOVE.L	10(A6),$DFF0A0
	MOVE.W	#1,$DFF0A4
lbC0015C8:
	MOVE.L	lbL0017AA(PC),D0
	ADD.L	#$10,D0
	MOVE.L	D0,lbL0017AA
	CMP.L	#$400,D0
	BNE.S	lbC001600
lbC0015E0:
	CLR.L	lbL0017AA
	ADDQ.L	#1,lbL0017AE
	MOVEQ	#0,D0
	MOVE.W	lbB001838(PC),D0
	MOVE.L	lbL0017AE(PC),D1
	CMP.L	D0,D1
	BNE.S	lbC001600
	CLR.L	lbL0017AE
lbC001600:
	TST.W	lbW00183C
	BEQ.S	lbC001610
	CLR.W	lbW00183C
	BRA.S	lbC0015E0

lbC001610:
	RTS

lbC001612:
	MOVE.L	0(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	2(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.S	lbC001690
	MOVEQ	#0,D3
	LEA	lbL0017B8(PC),A1
	MOVE.L	D2,D4
	ASL.L	#2,D2
	MULU	#$1E,D4
	MOVE.L	0(A1,D2.W),4(A6)
	MOVE.W	0(A3,D4.L),8(A6)
	MOVE.W	2(A3,D4.L),$12(A6)
	MOVE.W	4(A3,D4.L),D3
	TST.W	D3
	BEQ.S	lbC00167A
	MOVE.L	4(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,4(A6)
	MOVE.L	D2,10(A6)
	MOVE.W	6(A3,D4.L),8(A6)
	MOVE.W	6(A3,D4.L),14(A6)
	MOVE.W	$12(A6),8(A5)
	BRA.S	lbC001690

lbC00167A:
	MOVE.L	4(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,10(A6)
	MOVE.W	6(A3,D4.L),14(A6)
	MOVE.W	$12(A6),8(A5)
lbC001690:
	TST.W	(A6)
	BEQ.S	lbC0016B8
	MOVE.W	(A6),$10(A6)
	MOVE.W	$14(A6),$DFF096
	MOVE.L	4(A6),(A5)
	MOVE.W	8(A6),4(A5)
	MOVE.W	(A6),6(A5)
	MOVE.W	$14(A6),D0
	OR.W	D0,lbW00183A
lbC0016B8:
	TST.W	(A6)
	BEQ.S	lbC0016C0
	MOVE.W	(A6),$16(A6)
lbC0016C0:
	MOVE.B	2(A6),D0
	AND.B	#15,D0
	CMP.B	#11,D0
	BEQ.S	lbC0016E8
	CMP.B	#12,D0
	BEQ.S	lbC0016FE
	CMP.B	#13,D0
	BEQ.S	lbC001706
	CMP.B	#14,D0
	BEQ.S	lbC00170E
	CMP.B	#15,D0
	BEQ.S	lbC00172A
	RTS

lbC0016E8:
	NOT.W	lbW00183C
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	SUBQ.B	#1,D0
	MOVE.L	D0,lbL0017AE
	RTS

lbC0016FE:
	MOVE.B	3(A6),8(A5)
	RTS

lbC001706:
	NOT.W	lbW00183C
	RTS

lbC00170E:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	#1,D0
	ROL.B	#1,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS

lbC00172A:
	MOVE.B	3(A6),D0
	AND.B	#15,D0
	BEQ.S	lbC001740
	CLR.W	lbW0017B2
	MOVE.B	D0,mt_speed
lbC001740:
	RTS

lbL001742:
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$10000
	dc.w	0
lbL00175C:
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$20000
	dc.w	0
lbL001776:
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$40000
	dc.w	0
lbL001790:
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$80000
	dc.w	0
lbL0017AA:
	dc.l	0
lbL0017AE:
	dc.l	0
lbW0017B2:
	dc.w	0
lbL0017B4:
	dc.l	0
lbL0017B8:
	dc.l	0
lbL0017BC:
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbB001838:
	dc.b	0
lbB001839:
	dc.b	0
lbW00183A:
	dc.w	0
lbW00183C:
	dc.w	0
mt_period:
	dc.w	$358,$328,$2FA,$2D0,$2A6
	dc.w	$280,$25C,$23A,$21A,$1FC
	dc.w	$1E0,$1C5,$1AC,$194,$17D
	dc.w	$168,$153,$140,$12E,$11D
	dc.w	$10D,$FE,$F0,$E2,$D6
	dc.w	$CA,$BE,$B4,$AA,$A0
	dc.w	$97,$8F,$87,$7F,$78
	dc.w	$71,0,0,0

CopperListSource:
	dc.w	$120
	dc.w	0
	dc.w	$122
	dc.w	0
	dc.w	$124
	dc.w	0
	dc.w	$126
	dc.w	0
	dc.w	$128
	dc.w	0
	dc.w	$12A
	dc.w	0
	dc.w	$12C
	dc.w	0
	dc.w	$12E
	dc.w	0
	dc.w	$130
	dc.w	0
	dc.w	$132
	dc.w	0
	dc.w	$134
	dc.w	0
	dc.w	$136
	dc.w	0
	dc.w	$138
	dc.w	0
	dc.w	$13A
	dc.w	0
	dc.w	$13C
	dc.w	0
	dc.w	$13E
	dc.w	0
	dc.w	$8E
	dc.w	$581
	dc.w	$90
	dc.w	$40C1
	dc.w	$92
	dc.w	$48
	dc.w	$94
	dc.w	$C0
	dc.w	$102
	dc.w	0
	dc.w	$104
	dc.w	0
	dc.w	$108
	dc.w	$40
	dc.w	$10A
	dc.w	$40
	dc.w	$180
CopperLogoPalette:
	dc.w	0
	dc.w	$182
	dc.w	0
	dc.w	$184
	dc.w	0
	dc.w	$186
	dc.w	0
	dc.w	$188
	dc.w	0
	dc.w	$18A
	dc.w	0
	dc.w	$18C
	dc.w	0
	dc.w	$18E
	dc.w	0
	dc.w	$E0
CopperLogoBpl:
	dc.w	0
	dc.w	$E2
	dc.w	0
	dc.w	$E4
	dc.w	0
	dc.w	$E6
	dc.w	0
	dc.w	$E8
	dc.w	0
	dc.w	$EA
	dc.w	0
	dc.w	$2B07
	dc.w	$FFFE
	dc.w	$100		;BPLCON0
	dc.w	$3200		;3 bitplanes
	dc.w	$6307
	dc.w	$FFFE
	dc.w	$100
	dc.w	0
CopperFontColors:
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$E8
CopperScrollBpl:
	dc.w	0
	dc.w	$EA
	dc.w	0
	dc.w	$EC
	dc.w	0
	dc.w	$EE
	dc.w	0
	dc.w	$F0
	dc.w	0
	dc.w	$F2
	dc.w	0
	dc.w	$102		;BPLCON1
	dc.w	0
	dc.w	$92
	dc.w	$38
	dc.w	$94
	dc.w	$D0
	dc.w	$182
	dc.w	0
	dc.w	$E0
CopperBplOffset	equ *-CopperListSource
	dc.w	0
	dc.w	$E2
	dc.w	0
	dc.w	$E4
	dc.w	0
	dc.w	$E6
	dc.w	0
	dc.w	$108
	dc.w	2
	dc.w	$10A
	dc.w	2
	dc.w	$6407
	dc.w	$FFFE
CopperBoardOffset equ *-CopperListSource
	dc.w	$100		;BPLCON0
	dc.w	$2200
	dc.w	$184
	dc.w	0
	dc.w	$186
	dc.w	0
CopperBaseSize equ *-CopperListSource
; End of Copper List

;Sine/Cosine table
SineTable:
	dc.w	0
	dc.w	$FF
	dc.w	1
	dc.w	$FE
	dc.w	3
	dc.w	$FE
	dc.w	4
	dc.w	$FE
	dc.w	6
	dc.w	$FE
	dc.w	7
	dc.w	$FE
	dc.w	9
	dc.w	$FE
	dc.w	10
	dc.w	$FE
	dc.w	12
	dc.w	$FE
	dc.w	14
	dc.w	$FE
	dc.w	15
	dc.w	$FE
	dc.w	$11
	dc.w	$FE
	dc.w	$12
	dc.w	$FE
	dc.w	$14
	dc.w	$FE
	dc.w	$15
	dc.w	$FE
	dc.w	$17
	dc.w	$FD
	dc.w	$18
	dc.w	$FD
	dc.w	$1A
	dc.w	$FD
	dc.w	$1C
	dc.w	$FD
	dc.w	$1D
	dc.w	$FD
	dc.w	$1F
	dc.w	$FD
	dc.w	$20
	dc.w	$FC
	dc.w	$22
	dc.w	$FC
	dc.w	$23
	dc.w	$FC
	dc.w	$25
	dc.w	$FC
	dc.w	$26
	dc.w	$FC
	dc.w	$28
	dc.w	$FB
	dc.w	$2A
	dc.w	$FB
	dc.w	$2B
	dc.w	$FB
	dc.w	$2D
	dc.w	$FA
	dc.w	$2E
	dc.w	$FA
	dc.w	$30
	dc.w	$FA
	dc.w	$31
	dc.w	$FA
	dc.w	$33
	dc.w	$F9
	dc.w	$34
	dc.w	$F9
	dc.w	$36
	dc.w	$F9
	dc.w	$37
	dc.w	$F8
	dc.w	$39
	dc.w	$F8
	dc.w	$3A
	dc.w	$F8
	dc.w	$3C
	dc.w	$F7
	dc.w	$3D
	dc.w	$F7
	dc.w	$3F
	dc.w	$F6
	dc.w	$40
	dc.w	$F6
	dc.w	$42
	dc.w	$F6
	dc.w	$44
	dc.w	$F5
	dc.w	$45
	dc.w	$F5
	dc.w	$47
	dc.w	$F4
	dc.w	$48
	dc.w	$F4
	dc.w	$4A
	dc.w	$F4
	dc.w	$4B
	dc.w	$F3
	dc.w	$4D
	dc.w	$F3
	dc.w	$4E
	dc.w	$F2
	dc.w	$4F
	dc.w	$F2
	dc.w	$51
	dc.w	$F1
	dc.w	$52
	dc.w	$F1
	dc.w	$54
	dc.w	$F0
	dc.w	$55
	dc.w	$F0
	dc.w	$57
	dc.w	$EF
	dc.w	$58
	dc.w	$EF
	dc.w	$5A
	dc.w	$EE
	dc.w	$5B
	dc.w	$ED
	dc.w	$5D
	dc.w	$ED
	dc.w	$5E
	dc.w	$EC
	dc.w	$60
	dc.w	$EC
	dc.w	$61
	dc.w	$EB
	dc.w	$63
	dc.w	$EA
	dc.w	$64
	dc.w	$EA
	dc.w	$65
	dc.w	$E9
	dc.w	$67
	dc.w	$E9
	dc.w	$68
	dc.w	$E8
	dc.w	$6A
	dc.w	$E7
	dc.w	$6B
	dc.w	$E7
	dc.w	$6D
	dc.w	$E6
	dc.w	$6E
	dc.w	$E5
	dc.w	$6F
	dc.w	$E5
	dc.w	$71
	dc.w	$E4
	dc.w	$72
	dc.w	$E3
	dc.w	$74
	dc.w	$E3
	dc.w	$75
	dc.w	$E2
	dc.w	$76
	dc.w	$E1
	dc.w	$78
	dc.w	$E0
	dc.w	$79
	dc.w	$E0
	dc.w	$7A
	dc.w	$DF
	dc.w	$7C
	dc.w	$DE
	dc.w	$7D
	dc.w	$DD
	dc.w	$7F
	dc.w	$DD
	dc.w	$80
	dc.w	$DC
	dc.w	$81
	dc.w	$DB
	dc.w	$83
	dc.w	$DA
	dc.w	$84
	dc.w	$D9
	dc.w	$85
	dc.w	$D9
	dc.w	$87
	dc.w	$D8
	dc.w	$88
	dc.w	$D7
	dc.w	$89
	dc.w	$D6
	dc.w	$8B
	dc.w	$D5
	dc.w	$8C
	dc.w	$D4
	dc.w	$8D
	dc.w	$D4
	dc.w	$8E
	dc.w	$D3
	dc.w	$90
	dc.w	$D2
	dc.w	$91
	dc.w	$D1
	dc.w	$92
	dc.w	$D0
	dc.w	$94
	dc.w	$CF
	dc.w	$95
	dc.w	$CE
	dc.w	$96
	dc.w	$CD
	dc.w	$97
	dc.w	$CC
	dc.w	$99
	dc.w	$CB
	dc.w	$9A
	dc.w	$CA
	dc.w	$9B
	dc.w	$C9
	dc.w	$9C
	dc.w	$C9
	dc.w	$9E
	dc.w	$C8
	dc.w	$9F
	dc.w	$C7
	dc.w	$A0
	dc.w	$C6
	dc.w	$A1
	dc.w	$C5
	dc.w	$A2
	dc.w	$C4
	dc.w	$A4
	dc.w	$C3
	dc.w	$A5
	dc.w	$C2
	dc.w	$A6
	dc.w	$C1
	dc.w	$A7
	dc.w	$C0
	dc.w	$A8
	dc.w	$BF
	dc.w	$AA
	dc.w	$BD
	dc.w	$AB
	dc.w	$BC
	dc.w	$AC
	dc.w	$BB
	dc.w	$AD
	dc.w	$BA
	dc.w	$AE
	dc.w	$B9
	dc.w	$AF
	dc.w	$B8
	dc.w	$B0
	dc.w	$B7
	dc.w	$B2
	dc.w	$B6
	dc.w	$B3
	dc.w	$B5
	dc.w	$B4
	dc.w	$B4
	dc.w	$B5
	dc.w	$B3
	dc.w	$B6
	dc.w	$B2
	dc.w	$B7
	dc.w	$B0
	dc.w	$B8
	dc.w	$AF
	dc.w	$B9
	dc.w	$AE
	dc.w	$BA
	dc.w	$AD
	dc.w	$BB
	dc.w	$AC
	dc.w	$BC
	dc.w	$AB
	dc.w	$BD
	dc.w	$AA
	dc.w	$BF
	dc.w	$A8
	dc.w	$C0
	dc.w	$A7
	dc.w	$C1
	dc.w	$A6
	dc.w	$C2
	dc.w	$A5
	dc.w	$C3
	dc.w	$A4
	dc.w	$C4
	dc.w	$A2
	dc.w	$C5
	dc.w	$A1
	dc.w	$C6
	dc.w	$A0
	dc.w	$C7
	dc.w	$9F
	dc.w	$C8
	dc.w	$9E
	dc.w	$C9
	dc.w	$9C
	dc.w	$C9
	dc.w	$9B
	dc.w	$CA
	dc.w	$9A
	dc.w	$CB
	dc.w	$99
	dc.w	$CC
	dc.w	$97
	dc.w	$CD
	dc.w	$96
	dc.w	$CE
	dc.w	$95
	dc.w	$CF
	dc.w	$94
	dc.w	$D0
	dc.w	$92
	dc.w	$D1
	dc.w	$91
	dc.w	$D2
	dc.w	$90
	dc.w	$D3
	dc.w	$8E
	dc.w	$D4
	dc.w	$8D
	dc.w	$D4
	dc.w	$8C
	dc.w	$D5
	dc.w	$8B
	dc.w	$D6
	dc.w	$89
	dc.w	$D7
	dc.w	$88
	dc.w	$D8
	dc.w	$87
	dc.w	$D9
	dc.w	$85
	dc.w	$D9
	dc.w	$84
	dc.w	$DA
	dc.w	$83
	dc.w	$DB
	dc.w	$81
	dc.w	$DC
	dc.w	$80
	dc.w	$DD
	dc.w	$7F
	dc.w	$DD
	dc.w	$7D
	dc.w	$DE
	dc.w	$7C
	dc.w	$DF
	dc.w	$7A
	dc.w	$E0
	dc.w	$79
	dc.w	$E0
	dc.w	$78
	dc.w	$E1
	dc.w	$76
	dc.w	$E2
	dc.w	$75
	dc.w	$E3
	dc.w	$74
	dc.w	$E3
	dc.w	$72
	dc.w	$E4
	dc.w	$71
	dc.w	$E5
	dc.w	$6F
	dc.w	$E5
	dc.w	$6E
	dc.w	$E6
	dc.w	$6D
	dc.w	$E7
	dc.w	$6B
	dc.w	$E7
	dc.w	$6A
	dc.w	$E8
	dc.w	$68
	dc.w	$E9
	dc.w	$67
	dc.w	$E9
	dc.w	$65
	dc.w	$EA
	dc.w	$64
	dc.w	$EA
	dc.w	$63
	dc.w	$EB
	dc.w	$61
	dc.w	$EC
	dc.w	$60
	dc.w	$EC
	dc.w	$5E
	dc.w	$ED
	dc.w	$5D
	dc.w	$ED
	dc.w	$5B
	dc.w	$EE
	dc.w	$5A
	dc.w	$EF
	dc.w	$58
	dc.w	$EF
	dc.w	$57
	dc.w	$F0
	dc.w	$55
	dc.w	$F0
	dc.w	$54
	dc.w	$F1
	dc.w	$52
	dc.w	$F1
	dc.w	$51
	dc.w	$F2
	dc.w	$4F
	dc.w	$F2
	dc.w	$4E
	dc.w	$F3
	dc.w	$4D
	dc.w	$F3
	dc.w	$4B
	dc.w	$F4
	dc.w	$4A
	dc.w	$F4
	dc.w	$48
	dc.w	$F4
	dc.w	$47
	dc.w	$F5
	dc.w	$45
	dc.w	$F5
	dc.w	$44
	dc.w	$F6
	dc.w	$42
	dc.w	$F6
	dc.w	$40
	dc.w	$F6
	dc.w	$3F
	dc.w	$F7
	dc.w	$3D
	dc.w	$F7
	dc.w	$3C
	dc.w	$F8
	dc.w	$3A
	dc.w	$F8
	dc.w	$39
	dc.w	$F8
	dc.w	$37
	dc.w	$F9
	dc.w	$36
	dc.w	$F9
	dc.w	$34
	dc.w	$F9
	dc.w	$33
	dc.w	$FA
	dc.w	$31
	dc.w	$FA
	dc.w	$30
	dc.w	$FA
	dc.w	$2E
	dc.w	$FA
	dc.w	$2D
	dc.w	$FB
	dc.w	$2B
	dc.w	$FB
	dc.w	$2A
	dc.w	$FB
	dc.w	$28
	dc.w	$FC
	dc.w	$26
	dc.w	$FC
	dc.w	$25
	dc.w	$FC
	dc.w	$23
	dc.w	$FC
	dc.w	$22
	dc.w	$FC
	dc.w	$20
	dc.w	$FD
	dc.w	$1F
	dc.w	$FD
	dc.w	$1D
	dc.w	$FD
	dc.w	$1C
	dc.w	$FD
	dc.w	$1A
	dc.w	$FD
	dc.w	$18
	dc.w	$FD
	dc.w	$17
	dc.w	$FE
	dc.w	$15
	dc.w	$FE
	dc.w	$14
	dc.w	$FE
	dc.w	$12
	dc.w	$FE
	dc.w	$11
	dc.w	$FE
	dc.w	15
	dc.w	$FE
	dc.w	14
	dc.w	$FE
	dc.w	12
	dc.w	$FE
	dc.w	10
	dc.w	$FE
	dc.w	9
	dc.w	$FE
	dc.w	7
	dc.w	$FE
	dc.w	6
	dc.w	$FE
	dc.w	4
	dc.w	$FE
	dc.w	3
	dc.w	$FE
	dc.w	1
	dc.w	$FF
	dc.w	$FFFF
	dc.w	$FE
	dc.w	$FFFE
	dc.w	$FE
	dc.w	$FFFC
	dc.w	$FE
	dc.w	$FFFB
	dc.w	$FE
	dc.w	$FFF9
	dc.w	$FE
	dc.w	$FFF8
	dc.w	$FE
	dc.w	$FFF6
	dc.w	$FE
	dc.w	$FFF5
	dc.w	$FE
	dc.w	$FFF3
	dc.w	$FE
	dc.w	$FFF1
	dc.w	$FE
	dc.w	$FFF0
	dc.w	$FE
	dc.w	$FFEE
	dc.w	$FE
	dc.w	$FFED
	dc.w	$FE
	dc.w	$FFEB
	dc.w	$FE
	dc.w	$FFEA
	dc.w	$FD
	dc.w	$FFE8
	dc.w	$FD
	dc.w	$FFE7
	dc.w	$FD
	dc.w	$FFE5
	dc.w	$FD
	dc.w	$FFE3
	dc.w	$FD
	dc.w	$FFE2
	dc.w	$FD
	dc.w	$FFE0
	dc.w	$FC
	dc.w	$FFDF
	dc.w	$FC
	dc.w	$FFDD
	dc.w	$FC
	dc.w	$FFDC
	dc.w	$FC
	dc.w	$FFDA
	dc.w	$FC
	dc.w	$FFD9
	dc.w	$FB
	dc.w	$FFD7
	dc.w	$FB
	dc.w	$FFD5
	dc.w	$FB
	dc.w	$FFD4
	dc.w	$FA
	dc.w	$FFD2
	dc.w	$FA
	dc.w	$FFD1
	dc.w	$FA
	dc.w	$FFCF
	dc.w	$FA
	dc.w	$FFCE
	dc.w	$F9
	dc.w	$FFCC
	dc.w	$F9
	dc.w	$FFCB
	dc.w	$F9
	dc.w	$FFC9
	dc.w	$F8
	dc.w	$FFC8
	dc.w	$F8
	dc.w	$FFC6
	dc.w	$F8
	dc.w	$FFC5
	dc.w	$F7
	dc.w	$FFC3
	dc.w	$F7
	dc.w	$FFC2
	dc.w	$F6
	dc.w	$FFC0
	dc.w	$F6
	dc.w	$FFBF
	dc.w	$F6
	dc.w	$FFBD
	dc.w	$F5
	dc.w	$FFBB
	dc.w	$F5
	dc.w	$FFBA
	dc.w	$F4
	dc.w	$FFB8
	dc.w	$F4
	dc.w	$FFB7
	dc.w	$F4
	dc.w	$FFB5
	dc.w	$F3
	dc.w	$FFB4
	dc.w	$F3
	dc.w	$FFB2
	dc.w	$F2
	dc.w	$FFB1
	dc.w	$F2
	dc.w	$FFB0
	dc.w	$F1
	dc.w	$FFAE
	dc.w	$F1
	dc.w	$FFAD
	dc.w	$F0
	dc.w	$FFAB
	dc.w	$F0
	dc.w	$FFAA
	dc.w	$EF
	dc.w	$FFA8
	dc.w	$EF
	dc.w	$FFA7
	dc.w	$EE
	dc.w	$FFA5
	dc.w	$ED
	dc.w	$FFA4
	dc.w	$ED
	dc.w	$FFA2
	dc.w	$EC
	dc.w	$FFA1
	dc.w	$EC
	dc.w	$FF9F
	dc.w	$EB
	dc.w	$FF9E
	dc.w	$EA
	dc.w	$FF9C
	dc.w	$EA
	dc.w	$FF9B
	dc.w	$E9
	dc.w	$FF9A
	dc.w	$E9
	dc.w	$FF98
	dc.w	$E8
	dc.w	$FF97
	dc.w	$E7
	dc.w	$FF95
	dc.w	$E7
	dc.w	$FF94
	dc.w	$E6
	dc.w	$FF92
	dc.w	$E5
	dc.w	$FF91
	dc.w	$E5
	dc.w	$FF90
	dc.w	$E4
	dc.w	$FF8E
	dc.w	$E3
	dc.w	$FF8D
	dc.w	$E3
	dc.w	$FF8B
	dc.w	$E2
	dc.w	$FF8A
	dc.w	$E1
	dc.w	$FF89
	dc.w	$E0
	dc.w	$FF87
	dc.w	$E0
	dc.w	$FF86
	dc.w	$DF
	dc.w	$FF85
	dc.w	$DE
	dc.w	$FF83
	dc.w	$DD
	dc.w	$FF82
	dc.w	$DD
	dc.w	$FF80
	dc.w	$DC
	dc.w	$FF7F
	dc.w	$DB
	dc.w	$FF7E
	dc.w	$DA
	dc.w	$FF7C
	dc.w	$D9
	dc.w	$FF7B
	dc.w	$D9
	dc.w	$FF7A
	dc.w	$D8
	dc.w	$FF78
	dc.w	$D7
	dc.w	$FF77
	dc.w	$D6
	dc.w	$FF76
	dc.w	$D5
	dc.w	$FF74
	dc.w	$D4
	dc.w	$FF73
	dc.w	$D4
	dc.w	$FF72
	dc.w	$D3
	dc.w	$FF71
	dc.w	$D2
	dc.w	$FF6F
	dc.w	$D1
	dc.w	$FF6E
	dc.w	$D0
	dc.w	$FF6D
	dc.w	$CF
	dc.w	$FF6B
	dc.w	$CE
	dc.w	$FF6A
	dc.w	$CD
	dc.w	$FF69
	dc.w	$CC
	dc.w	$FF68
	dc.w	$CB
	dc.w	$FF66
	dc.w	$CA
	dc.w	$FF65
	dc.w	$C9
	dc.w	$FF64
	dc.w	$C9
	dc.w	$FF63
	dc.w	$C8
	dc.w	$FF61
	dc.w	$C7
	dc.w	$FF60
	dc.w	$C6
	dc.w	$FF5F
	dc.w	$C5
	dc.w	$FF5E
	dc.w	$C4
	dc.w	$FF5D
	dc.w	$C3
	dc.w	$FF5B
	dc.w	$C2
	dc.w	$FF5A
	dc.w	$C1
	dc.w	$FF59
	dc.w	$C0
	dc.w	$FF58
	dc.w	$BF
	dc.w	$FF57
	dc.w	$BD
	dc.w	$FF55
	dc.w	$BC
	dc.w	$FF54
	dc.w	$BB
	dc.w	$FF53
	dc.w	$BA
	dc.w	$FF52
	dc.w	$B9
	dc.w	$FF51
	dc.w	$B8
	dc.w	$FF50
	dc.w	$B7
	dc.w	$FF4F
	dc.w	$B6
	dc.w	$FF4D
	dc.w	$B5
	dc.w	$FF4C
	dc.w	$B4
	dc.w	$FF4B
	dc.w	$B3
	dc.w	$FF4A
	dc.w	$B2
	dc.w	$FF49
	dc.w	$B0
	dc.w	$FF48
	dc.w	$AF
	dc.w	$FF47
	dc.w	$AE
	dc.w	$FF46
	dc.w	$AD
	dc.w	$FF45
	dc.w	$AC
	dc.w	$FF44
	dc.w	$AB
	dc.w	$FF43
	dc.w	$AA
	dc.w	$FF42
	dc.w	$A8
	dc.w	$FF40
	dc.w	$A7
	dc.w	$FF3F
	dc.w	$A6
	dc.w	$FF3E
	dc.w	$A5
	dc.w	$FF3D
	dc.w	$A4
	dc.w	$FF3C
	dc.w	$A2
	dc.w	$FF3B
	dc.w	$A1
	dc.w	$FF3A
	dc.w	$A0
	dc.w	$FF39
	dc.w	$9F
	dc.w	$FF38
	dc.w	$9E
	dc.w	$FF37
	dc.w	$9C
	dc.w	$FF36
	dc.w	$9B
	dc.w	$FF36
	dc.w	$9A
	dc.w	$FF35
	dc.w	$99
	dc.w	$FF34
	dc.w	$97
	dc.w	$FF33
	dc.w	$96
	dc.w	$FF32
	dc.w	$95
	dc.w	$FF31
	dc.w	$94
	dc.w	$FF30
	dc.w	$92
	dc.w	$FF2F
	dc.w	$91
	dc.w	$FF2E
	dc.w	$90
	dc.w	$FF2D
	dc.w	$8E
	dc.w	$FF2C
	dc.w	$8D
	dc.w	$FF2B
	dc.w	$8C
	dc.w	$FF2B
	dc.w	$8B
	dc.w	$FF2A
	dc.w	$89
	dc.w	$FF29
	dc.w	$88
	dc.w	$FF28
	dc.w	$87
	dc.w	$FF27
	dc.w	$85
	dc.w	$FF26
	dc.w	$84
	dc.w	$FF26
	dc.w	$83
	dc.w	$FF25
	dc.w	$81
	dc.w	$FF24
	dc.w	$80
	dc.w	$FF23
	dc.w	$7F
	dc.w	$FF22
	dc.w	$7D
	dc.w	$FF22
	dc.w	$7C
	dc.w	$FF21
	dc.w	$7A
	dc.w	$FF20
	dc.w	$79
	dc.w	$FF1F
	dc.w	$78
	dc.w	$FF1F
	dc.w	$76
	dc.w	$FF1E
	dc.w	$75
	dc.w	$FF1D
	dc.w	$74
	dc.w	$FF1C
	dc.w	$72
	dc.w	$FF1C
	dc.w	$71
	dc.w	$FF1B
	dc.w	$6F
	dc.w	$FF1A
	dc.w	$6E
	dc.w	$FF1A
	dc.w	$6D
	dc.w	$FF19
	dc.w	$6B
	dc.w	$FF18
	dc.w	$6A
	dc.w	$FF18
	dc.w	$68
	dc.w	$FF17
	dc.w	$67
	dc.w	$FF16
	dc.w	$65
	dc.w	$FF16
	dc.w	$64
	dc.w	$FF15
	dc.w	$63
	dc.w	$FF15
	dc.w	$61
	dc.w	$FF14
	dc.w	$60
	dc.w	$FF13
	dc.w	$5E
	dc.w	$FF13
	dc.w	$5D
	dc.w	$FF12
	dc.w	$5B
	dc.w	$FF12
	dc.w	$5A
	dc.w	$FF11
	dc.w	$58
	dc.w	$FF10
	dc.w	$57
	dc.w	$FF10
	dc.w	$55
	dc.w	$FF0F
	dc.w	$54
	dc.w	$FF0F
	dc.w	$52
	dc.w	$FF0E
	dc.w	$51
	dc.w	$FF0E
	dc.w	$4F
	dc.w	$FF0D
	dc.w	$4E
	dc.w	$FF0D
	dc.w	$4D
	dc.w	$FF0C
	dc.w	$4B
	dc.w	$FF0C
	dc.w	$4A
	dc.w	$FF0B
	dc.w	$48
	dc.w	$FF0B
	dc.w	$47
	dc.w	$FF0B
	dc.w	$45
	dc.w	$FF0A
	dc.w	$44
	dc.w	$FF0A
	dc.w	$42
	dc.w	$FF09
	dc.w	$40
	dc.w	$FF09
	dc.w	$3F
	dc.w	$FF09
	dc.w	$3D
	dc.w	$FF08
	dc.w	$3C
	dc.w	$FF08
	dc.w	$3A
	dc.w	$FF07
	dc.w	$39
	dc.w	$FF07
	dc.w	$37
	dc.w	$FF07
	dc.w	$36
	dc.w	$FF06
	dc.w	$34
	dc.w	$FF06
	dc.w	$33
	dc.w	$FF06
	dc.w	$31
	dc.w	$FF05
	dc.w	$30
	dc.w	$FF05
	dc.w	$2E
	dc.w	$FF05
	dc.w	$2D
	dc.w	$FF05
	dc.w	$2B
	dc.w	$FF04
	dc.w	$2A
	dc.w	$FF04
	dc.w	$28
	dc.w	$FF04
	dc.w	$26
	dc.w	$FF03
	dc.w	$25
	dc.w	$FF03
	dc.w	$23
	dc.w	$FF03
	dc.w	$22
	dc.w	$FF03
	dc.w	$20
	dc.w	$FF03
	dc.w	$1F
	dc.w	$FF02
	dc.w	$1D
	dc.w	$FF02
	dc.w	$1C
	dc.w	$FF02
	dc.w	$1A
	dc.w	$FF02
	dc.w	$18
	dc.w	$FF02
	dc.w	$17
	dc.w	$FF02
	dc.w	$15
	dc.w	$FF01
	dc.w	$14
	dc.w	$FF01
	dc.w	$12
	dc.w	$FF01
	dc.w	$11
	dc.w	$FF01
	dc.w	15
	dc.w	$FF01
	dc.w	14
	dc.w	$FF01
	dc.w	12
	dc.w	$FF01
	dc.w	10
	dc.w	$FF01
	dc.w	9
	dc.w	$FF01
	dc.w	7
	dc.w	$FF01
	dc.w	6
	dc.w	$FF01
	dc.w	4
	dc.w	$FF01
	dc.w	3
	dc.w	$FF01
	dc.w	1
	dc.w	$FF01
	dc.w	$FFFF
	dc.w	$FF01
	dc.w	$FFFE
	dc.w	$FF01
	dc.w	$FFFC
	dc.w	$FF01
	dc.w	$FFFB
	dc.w	$FF01
	dc.w	$FFF9
	dc.w	$FF01
	dc.w	$FFF8
	dc.w	$FF01
	dc.w	$FFF6
	dc.w	$FF01
	dc.w	$FFF5
	dc.w	$FF01
	dc.w	$FFF3
	dc.w	$FF01
	dc.w	$FFF1
	dc.w	$FF01
	dc.w	$FFF0
	dc.w	$FF01
	dc.w	$FFEE
	dc.w	$FF01
	dc.w	$FFED
	dc.w	$FF01
	dc.w	$FFEB
	dc.w	$FF01
	dc.w	$FFEA
	dc.w	$FF01
	dc.w	$FFE8
	dc.w	$FF02
	dc.w	$FFE7
	dc.w	$FF02
	dc.w	$FFE5
	dc.w	$FF02
	dc.w	$FFE3
	dc.w	$FF02
	dc.w	$FFE2
	dc.w	$FF02
	dc.w	$FFE0
	dc.w	$FF02
	dc.w	$FFDF
	dc.w	$FF03
	dc.w	$FFDD
	dc.w	$FF03
	dc.w	$FFDC
	dc.w	$FF03
	dc.w	$FFDA
	dc.w	$FF03
	dc.w	$FFD9
	dc.w	$FF03
	dc.w	$FFD7
	dc.w	$FF04
	dc.w	$FFD5
	dc.w	$FF04
	dc.w	$FFD4
	dc.w	$FF04
	dc.w	$FFD2
	dc.w	$FF05
	dc.w	$FFD1
	dc.w	$FF05
	dc.w	$FFCF
	dc.w	$FF05
	dc.w	$FFCE
	dc.w	$FF05
	dc.w	$FFCC
	dc.w	$FF06
	dc.w	$FFCB
	dc.w	$FF06
	dc.w	$FFC9
	dc.w	$FF06
	dc.w	$FFC8
	dc.w	$FF07
	dc.w	$FFC6
	dc.w	$FF07
	dc.w	$FFC5
	dc.w	$FF07
	dc.w	$FFC3
	dc.w	$FF08
	dc.w	$FFC2
	dc.w	$FF08
	dc.w	$FFC0
	dc.w	$FF09
	dc.w	$FFBF
	dc.w	$FF09
	dc.w	$FFBD
	dc.w	$FF09
	dc.w	$FFBB
	dc.w	$FF0A
	dc.w	$FFBA
	dc.w	$FF0A
	dc.w	$FFB8
	dc.w	$FF0B
	dc.w	$FFB7
	dc.w	$FF0B
	dc.w	$FFB5
	dc.w	$FF0B
	dc.w	$FFB4
	dc.w	$FF0C
	dc.w	$FFB2
	dc.w	$FF0C
	dc.w	$FFB1
	dc.w	$FF0D
	dc.w	$FFB0
	dc.w	$FF0D
	dc.w	$FFAE
	dc.w	$FF0E
	dc.w	$FFAD
	dc.w	$FF0E
	dc.w	$FFAB
	dc.w	$FF0F
	dc.w	$FFAA
	dc.w	$FF0F
	dc.w	$FFA8
	dc.w	$FF10
	dc.w	$FFA7
	dc.w	$FF10
	dc.w	$FFA5
	dc.w	$FF11
	dc.w	$FFA4
	dc.w	$FF12
	dc.w	$FFA2
	dc.w	$FF12
	dc.w	$FFA1
	dc.w	$FF13
	dc.w	$FF9F
	dc.w	$FF13
	dc.w	$FF9E
	dc.w	$FF14
	dc.w	$FF9C
	dc.w	$FF15
	dc.w	$FF9B
	dc.w	$FF15
	dc.w	$FF9A
	dc.w	$FF16
	dc.w	$FF98
	dc.w	$FF16
	dc.w	$FF97
	dc.w	$FF17
	dc.w	$FF95
	dc.w	$FF18
	dc.w	$FF94
	dc.w	$FF18
	dc.w	$FF92
	dc.w	$FF19
	dc.w	$FF91
	dc.w	$FF1A
	dc.w	$FF90
	dc.w	$FF1A
	dc.w	$FF8E
	dc.w	$FF1B
	dc.w	$FF8D
	dc.w	$FF1C
	dc.w	$FF8B
	dc.w	$FF1C
	dc.w	$FF8A
	dc.w	$FF1D
	dc.w	$FF89
	dc.w	$FF1E
	dc.w	$FF87
	dc.w	$FF1F
	dc.w	$FF86
	dc.w	$FF1F
	dc.w	$FF85
	dc.w	$FF20
	dc.w	$FF83
	dc.w	$FF21
	dc.w	$FF82
	dc.w	$FF22
	dc.w	$FF80
	dc.w	$FF22
	dc.w	$FF7F
	dc.w	$FF23
	dc.w	$FF7E
	dc.w	$FF24
	dc.w	$FF7C
	dc.w	$FF25
	dc.w	$FF7B
	dc.w	$FF26
	dc.w	$FF7A
	dc.w	$FF26
	dc.w	$FF78
	dc.w	$FF27
	dc.w	$FF77
	dc.w	$FF28
	dc.w	$FF76
	dc.w	$FF29
	dc.w	$FF74
	dc.w	$FF2A
	dc.w	$FF73
	dc.w	$FF2B
	dc.w	$FF72
	dc.w	$FF2B
	dc.w	$FF71
	dc.w	$FF2C
	dc.w	$FF6F
	dc.w	$FF2D
	dc.w	$FF6E
	dc.w	$FF2E
	dc.w	$FF6D
	dc.w	$FF2F
	dc.w	$FF6B
	dc.w	$FF30
	dc.w	$FF6A
	dc.w	$FF31
	dc.w	$FF69
	dc.w	$FF32
	dc.w	$FF68
	dc.w	$FF33
	dc.w	$FF66
	dc.w	$FF34
	dc.w	$FF65
	dc.w	$FF35
	dc.w	$FF64
	dc.w	$FF36
	dc.w	$FF63
	dc.w	$FF36
	dc.w	$FF61
	dc.w	$FF37
	dc.w	$FF60
	dc.w	$FF38
	dc.w	$FF5F
	dc.w	$FF39
	dc.w	$FF5E
	dc.w	$FF3A
	dc.w	$FF5D
	dc.w	$FF3B
	dc.w	$FF5B
	dc.w	$FF3C
	dc.w	$FF5A
	dc.w	$FF3D
	dc.w	$FF59
	dc.w	$FF3E
	dc.w	$FF58
	dc.w	$FF3F
	dc.w	$FF57
	dc.w	$FF40
	dc.w	$FF55
	dc.w	$FF42
	dc.w	$FF54
	dc.w	$FF43
	dc.w	$FF53
	dc.w	$FF44
	dc.w	$FF52
	dc.w	$FF45
	dc.w	$FF51
	dc.w	$FF46
	dc.w	$FF50
	dc.w	$FF47
	dc.w	$FF4F
	dc.w	$FF48
	dc.w	$FF4D
	dc.w	$FF49
	dc.w	$FF4C
	dc.w	$FF4A
	dc.w	$FF4B
	dc.w	$FF4B
	dc.w	$FF4A
	dc.w	$FF4C
	dc.w	$FF49
	dc.w	$FF4D
	dc.w	$FF48
	dc.w	$FF4F
	dc.w	$FF47
	dc.w	$FF50
	dc.w	$FF46
	dc.w	$FF51
	dc.w	$FF45
	dc.w	$FF52
	dc.w	$FF44
	dc.w	$FF53
	dc.w	$FF43
	dc.w	$FF54
	dc.w	$FF42
	dc.w	$FF55
	dc.w	$FF40
	dc.w	$FF57
	dc.w	$FF3F
	dc.w	$FF58
	dc.w	$FF3E
	dc.w	$FF59
	dc.w	$FF3D
	dc.w	$FF5A
	dc.w	$FF3C
	dc.w	$FF5B
	dc.w	$FF3B
	dc.w	$FF5D
	dc.w	$FF3A
	dc.w	$FF5E
	dc.w	$FF39
	dc.w	$FF5F
	dc.w	$FF38
	dc.w	$FF60
	dc.w	$FF37
	dc.w	$FF61
	dc.w	$FF36
	dc.w	$FF63
	dc.w	$FF36
	dc.w	$FF64
	dc.w	$FF35
	dc.w	$FF65
	dc.w	$FF34
	dc.w	$FF66
	dc.w	$FF33
	dc.w	$FF68
	dc.w	$FF32
	dc.w	$FF69
	dc.w	$FF31
	dc.w	$FF6A
	dc.w	$FF30
	dc.w	$FF6B
	dc.w	$FF2F
	dc.w	$FF6D
	dc.w	$FF2E
	dc.w	$FF6E
	dc.w	$FF2D
	dc.w	$FF6F
	dc.w	$FF2C
	dc.w	$FF71
	dc.w	$FF2B
	dc.w	$FF72
	dc.w	$FF2B
	dc.w	$FF73
	dc.w	$FF2A
	dc.w	$FF74
	dc.w	$FF29
	dc.w	$FF76
	dc.w	$FF28
	dc.w	$FF77
	dc.w	$FF27
	dc.w	$FF78
	dc.w	$FF26
	dc.w	$FF7A
	dc.w	$FF26
	dc.w	$FF7B
	dc.w	$FF25
	dc.w	$FF7C
	dc.w	$FF24
	dc.w	$FF7E
	dc.w	$FF23
	dc.w	$FF7F
	dc.w	$FF22
	dc.w	$FF80
	dc.w	$FF22
	dc.w	$FF82
	dc.w	$FF21
	dc.w	$FF83
	dc.w	$FF20
	dc.w	$FF85
	dc.w	$FF1F
	dc.w	$FF86
	dc.w	$FF1F
	dc.w	$FF87
	dc.w	$FF1E
	dc.w	$FF89
	dc.w	$FF1D
	dc.w	$FF8A
	dc.w	$FF1C
	dc.w	$FF8B
	dc.w	$FF1C
	dc.w	$FF8D
	dc.w	$FF1B
	dc.w	$FF8E
	dc.w	$FF1A
	dc.w	$FF90
	dc.w	$FF1A
	dc.w	$FF91
	dc.w	$FF19
	dc.w	$FF92
	dc.w	$FF18
	dc.w	$FF94
	dc.w	$FF18
	dc.w	$FF95
	dc.w	$FF17
	dc.w	$FF97
	dc.w	$FF16
	dc.w	$FF98
	dc.w	$FF16
	dc.w	$FF9A
	dc.w	$FF15
	dc.w	$FF9B
	dc.w	$FF15
	dc.w	$FF9C
	dc.w	$FF14
	dc.w	$FF9E
	dc.w	$FF13
	dc.w	$FF9F
	dc.w	$FF13
	dc.w	$FFA1
	dc.w	$FF12
	dc.w	$FFA2
	dc.w	$FF12
	dc.w	$FFA4
	dc.w	$FF11
	dc.w	$FFA5
	dc.w	$FF10
	dc.w	$FFA7
	dc.w	$FF10
	dc.w	$FFA8
	dc.w	$FF0F
	dc.w	$FFAA
	dc.w	$FF0F
	dc.w	$FFAB
	dc.w	$FF0E
	dc.w	$FFAD
	dc.w	$FF0E
	dc.w	$FFAE
	dc.w	$FF0D
	dc.w	$FFB0
	dc.w	$FF0D
	dc.w	$FFB1
	dc.w	$FF0C
	dc.w	$FFB2
	dc.w	$FF0C
	dc.w	$FFB4
	dc.w	$FF0B
	dc.w	$FFB5
	dc.w	$FF0B
	dc.w	$FFB7
	dc.w	$FF0B
	dc.w	$FFB8
	dc.w	$FF0A
	dc.w	$FFBA
	dc.w	$FF0A
	dc.w	$FFBB
	dc.w	$FF09
	dc.w	$FFBD
	dc.w	$FF09
	dc.w	$FFBF
	dc.w	$FF09
	dc.w	$FFC0
	dc.w	$FF08
	dc.w	$FFC2
	dc.w	$FF08
	dc.w	$FFC3
	dc.w	$FF07
	dc.w	$FFC5
	dc.w	$FF07
	dc.w	$FFC6
	dc.w	$FF07
	dc.w	$FFC8
	dc.w	$FF06
	dc.w	$FFC9
	dc.w	$FF06
	dc.w	$FFCB
	dc.w	$FF06
	dc.w	$FFCC
	dc.w	$FF05
	dc.w	$FFCE
	dc.w	$FF05
	dc.w	$FFCF
	dc.w	$FF05
	dc.w	$FFD1
	dc.w	$FF05
	dc.w	$FFD2
	dc.w	$FF04
	dc.w	$FFD4
	dc.w	$FF04
	dc.w	$FFD5
	dc.w	$FF04
	dc.w	$FFD7
	dc.w	$FF03
	dc.w	$FFD9
	dc.w	$FF03
	dc.w	$FFDA
	dc.w	$FF03
	dc.w	$FFDC
	dc.w	$FF03
	dc.w	$FFDD
	dc.w	$FF03
	dc.w	$FFDF
	dc.w	$FF02
	dc.w	$FFE0
	dc.w	$FF02
	dc.w	$FFE2
	dc.w	$FF02
	dc.w	$FFE3
	dc.w	$FF02
	dc.w	$FFE5
	dc.w	$FF02
	dc.w	$FFE7
	dc.w	$FF02
	dc.w	$FFE8
	dc.w	$FF01
	dc.w	$FFEA
	dc.w	$FF01
	dc.w	$FFEB
	dc.w	$FF01
	dc.w	$FFED
	dc.w	$FF01
	dc.w	$FFEE
	dc.w	$FF01
	dc.w	$FFF0
	dc.w	$FF01
	dc.w	$FFF1
	dc.w	$FF01
	dc.w	$FFF3
	dc.w	$FF01
	dc.w	$FFF5
	dc.w	$FF01
	dc.w	$FFF6
	dc.w	$FF01
	dc.w	$FFF8
	dc.w	$FF01
	dc.w	$FFF9
	dc.w	$FF01
	dc.w	$FFFB
	dc.w	$FF01
	dc.w	$FFFC
	dc.w	$FF01
	dc.w	$FFFE
	dc.w	$FF01
	dc.w	0
	dc.w	$FF01
	dc.w	1
	dc.w	$FF01
	dc.w	3
	dc.w	$FF01
	dc.w	4
	dc.w	$FF01
	dc.w	6
	dc.w	$FF01
	dc.w	7
	dc.w	$FF01
	dc.w	9
	dc.w	$FF01
	dc.w	10
	dc.w	$FF01
	dc.w	12
	dc.w	$FF01
	dc.w	14
	dc.w	$FF01
	dc.w	15
	dc.w	$FF01
	dc.w	$11
	dc.w	$FF01
	dc.w	$12
	dc.w	$FF01
	dc.w	$14
	dc.w	$FF01
	dc.w	$15
	dc.w	$FF02
	dc.w	$17
	dc.w	$FF02
	dc.w	$18
	dc.w	$FF02
	dc.w	$1A
	dc.w	$FF02
	dc.w	$1C
	dc.w	$FF02
	dc.w	$1D
	dc.w	$FF02
	dc.w	$1F
	dc.w	$FF03
	dc.w	$20
	dc.w	$FF03
	dc.w	$22
	dc.w	$FF03
	dc.w	$23
	dc.w	$FF03
	dc.w	$25
	dc.w	$FF03
	dc.w	$26
	dc.w	$FF04
	dc.w	$28
	dc.w	$FF04
	dc.w	$2A
	dc.w	$FF04
	dc.w	$2B
	dc.w	$FF05
	dc.w	$2D
	dc.w	$FF05
	dc.w	$2E
	dc.w	$FF05
	dc.w	$30
	dc.w	$FF05
	dc.w	$31
	dc.w	$FF06
	dc.w	$33
	dc.w	$FF06
	dc.w	$34
	dc.w	$FF06
	dc.w	$36
	dc.w	$FF07
	dc.w	$37
	dc.w	$FF07
	dc.w	$39
	dc.w	$FF07
	dc.w	$3A
	dc.w	$FF08
	dc.w	$3C
	dc.w	$FF08
	dc.w	$3D
	dc.w	$FF09
	dc.w	$3F
	dc.w	$FF09
	dc.w	$40
	dc.w	$FF09
	dc.w	$42
	dc.w	$FF0A
	dc.w	$44
	dc.w	$FF0A
	dc.w	$45
	dc.w	$FF0B
	dc.w	$47
	dc.w	$FF0B
	dc.w	$48
	dc.w	$FF0B
	dc.w	$4A
	dc.w	$FF0C
	dc.w	$4B
	dc.w	$FF0C
	dc.w	$4D
	dc.w	$FF0D
	dc.w	$4E
	dc.w	$FF0D
	dc.w	$4F
	dc.w	$FF0E
	dc.w	$51
	dc.w	$FF0E
	dc.w	$52
	dc.w	$FF0F
	dc.w	$54
	dc.w	$FF0F
	dc.w	$55
	dc.w	$FF10
	dc.w	$57
	dc.w	$FF10
	dc.w	$58
	dc.w	$FF11
	dc.w	$5A
	dc.w	$FF12
	dc.w	$5B
	dc.w	$FF12
	dc.w	$5D
	dc.w	$FF13
	dc.w	$5E
	dc.w	$FF13
	dc.w	$60
	dc.w	$FF14
	dc.w	$61
	dc.w	$FF15
	dc.w	$63
	dc.w	$FF15
	dc.w	$64
	dc.w	$FF16
	dc.w	$65
	dc.w	$FF16
	dc.w	$67
	dc.w	$FF17
	dc.w	$68
	dc.w	$FF18
	dc.w	$6A
	dc.w	$FF18
	dc.w	$6B
	dc.w	$FF19
	dc.w	$6D
	dc.w	$FF1A
	dc.w	$6E
	dc.w	$FF1A
	dc.w	$6F
	dc.w	$FF1B
	dc.w	$71
	dc.w	$FF1C
	dc.w	$72
	dc.w	$FF1C
	dc.w	$74
	dc.w	$FF1D
	dc.w	$75
	dc.w	$FF1E
	dc.w	$76
	dc.w	$FF1F
	dc.w	$78
	dc.w	$FF1F
	dc.w	$79
	dc.w	$FF20
	dc.w	$7A
	dc.w	$FF21
	dc.w	$7C
	dc.w	$FF22
	dc.w	$7D
	dc.w	$FF22
	dc.w	$7F
	dc.w	$FF23
	dc.w	$80
	dc.w	$FF24
	dc.w	$81
	dc.w	$FF25
	dc.w	$83
	dc.w	$FF26
	dc.w	$84
	dc.w	$FF26
	dc.w	$85
	dc.w	$FF27
	dc.w	$87
	dc.w	$FF28
	dc.w	$88
	dc.w	$FF29
	dc.w	$89
	dc.w	$FF2A
	dc.w	$8B
	dc.w	$FF2B
	dc.w	$8C
	dc.w	$FF2B
	dc.w	$8D
	dc.w	$FF2C
	dc.w	$8E
	dc.w	$FF2D
	dc.w	$90
	dc.w	$FF2E
	dc.w	$91
	dc.w	$FF2F
	dc.w	$92
	dc.w	$FF30
	dc.w	$94
	dc.w	$FF31
	dc.w	$95
	dc.w	$FF32
	dc.w	$96
	dc.w	$FF33
	dc.w	$97
	dc.w	$FF34
	dc.w	$99
	dc.w	$FF35
	dc.w	$9A
	dc.w	$FF36
	dc.w	$9B
	dc.w	$FF36
	dc.w	$9C
	dc.w	$FF37
	dc.w	$9E
	dc.w	$FF38
	dc.w	$9F
	dc.w	$FF39
	dc.w	$A0
	dc.w	$FF3A
	dc.w	$A1
	dc.w	$FF3B
	dc.w	$A2
	dc.w	$FF3C
	dc.w	$A4
	dc.w	$FF3D
	dc.w	$A5
	dc.w	$FF3E
	dc.w	$A6
	dc.w	$FF3F
	dc.w	$A7
	dc.w	$FF40
	dc.w	$A8
	dc.w	$FF42
	dc.w	$AA
	dc.w	$FF43
	dc.w	$AB
	dc.w	$FF44
	dc.w	$AC
	dc.w	$FF45
	dc.w	$AD
	dc.w	$FF46
	dc.w	$AE
	dc.w	$FF47
	dc.w	$AF
	dc.w	$FF48
	dc.w	$B0
	dc.w	$FF49
	dc.w	$B2
	dc.w	$FF4A
	dc.w	$B3
	dc.w	$FF4B
	dc.w	$B4
	dc.w	$FF4C
	dc.w	$B5
	dc.w	$FF4D
	dc.w	$B6
	dc.w	$FF4F
	dc.w	$B7
	dc.w	$FF50
	dc.w	$B8
	dc.w	$FF51
	dc.w	$B9
	dc.w	$FF52
	dc.w	$BA
	dc.w	$FF53
	dc.w	$BB
	dc.w	$FF54
	dc.w	$BC
	dc.w	$FF55
	dc.w	$BD
	dc.w	$FF57
	dc.w	$BF
	dc.w	$FF58
	dc.w	$C0
	dc.w	$FF59
	dc.w	$C1
	dc.w	$FF5A
	dc.w	$C2
	dc.w	$FF5B
	dc.w	$C3
	dc.w	$FF5D
	dc.w	$C4
	dc.w	$FF5E
	dc.w	$C5
	dc.w	$FF5F
	dc.w	$C6
	dc.w	$FF60
	dc.w	$C7
	dc.w	$FF61
	dc.w	$C8
	dc.w	$FF63
	dc.w	$C9
	dc.w	$FF64
	dc.w	$C9
	dc.w	$FF65
	dc.w	$CA
	dc.w	$FF66
	dc.w	$CB
	dc.w	$FF68
	dc.w	$CC
	dc.w	$FF69
	dc.w	$CD
	dc.w	$FF6A
	dc.w	$CE
	dc.w	$FF6B
	dc.w	$CF
	dc.w	$FF6D
	dc.w	$D0
	dc.w	$FF6E
	dc.w	$D1
	dc.w	$FF6F
	dc.w	$D2
	dc.w	$FF71
	dc.w	$D3
	dc.w	$FF72
	dc.w	$D4
	dc.w	$FF73
	dc.w	$D4
	dc.w	$FF74
	dc.w	$D5
	dc.w	$FF76
	dc.w	$D6
	dc.w	$FF77
	dc.w	$D7
	dc.w	$FF78
	dc.w	$D8
	dc.w	$FF7A
	dc.w	$D9
	dc.w	$FF7B
	dc.w	$D9
	dc.w	$FF7C
	dc.w	$DA
	dc.w	$FF7E
	dc.w	$DB
	dc.w	$FF7F
	dc.w	$DC
	dc.w	$FF80
	dc.w	$DD
	dc.w	$FF82
	dc.w	$DD
	dc.w	$FF83
	dc.w	$DE
	dc.w	$FF85
	dc.w	$DF
	dc.w	$FF86
	dc.w	$E0
	dc.w	$FF87
	dc.w	$E0
	dc.w	$FF89
	dc.w	$E1
	dc.w	$FF8A
	dc.w	$E2
	dc.w	$FF8B
	dc.w	$E3
	dc.w	$FF8D
	dc.w	$E3
	dc.w	$FF8E
	dc.w	$E4
	dc.w	$FF90
	dc.w	$E5
	dc.w	$FF91
	dc.w	$E5
	dc.w	$FF92
	dc.w	$E6
	dc.w	$FF94
	dc.w	$E7
	dc.w	$FF95
	dc.w	$E7
	dc.w	$FF97
	dc.w	$E8
	dc.w	$FF98
	dc.w	$E9
	dc.w	$FF9A
	dc.w	$E9
	dc.w	$FF9B
	dc.w	$EA
	dc.w	$FF9C
	dc.w	$EA
	dc.w	$FF9E
	dc.w	$EB
	dc.w	$FF9F
	dc.w	$EC
	dc.w	$FFA1
	dc.w	$EC
	dc.w	$FFA2
	dc.w	$ED
	dc.w	$FFA4
	dc.w	$ED
	dc.w	$FFA5
	dc.w	$EE
	dc.w	$FFA7
	dc.w	$EF
	dc.w	$FFA8
	dc.w	$EF
	dc.w	$FFAA
	dc.w	$F0
	dc.w	$FFAB
	dc.w	$F0
	dc.w	$FFAD
	dc.w	$F1
	dc.w	$FFAE
	dc.w	$F1
	dc.w	$FFB0
	dc.w	$F2
	dc.w	$FFB1
	dc.w	$F2
	dc.w	$FFB2
	dc.w	$F3
	dc.w	$FFB4
	dc.w	$F3
	dc.w	$FFB5
	dc.w	$F4
	dc.w	$FFB7
	dc.w	$F4
	dc.w	$FFB8
	dc.w	$F4
	dc.w	$FFBA
	dc.w	$F5
	dc.w	$FFBB
	dc.w	$F5
	dc.w	$FFBD
	dc.w	$F6
	dc.w	$FFBF
	dc.w	$F6
	dc.w	$FFC0
	dc.w	$F6
	dc.w	$FFC2
	dc.w	$F7
	dc.w	$FFC3
	dc.w	$F7
	dc.w	$FFC5
	dc.w	$F8
	dc.w	$FFC6
	dc.w	$F8
	dc.w	$FFC8
	dc.w	$F8
	dc.w	$FFC9
	dc.w	$F9
	dc.w	$FFCB
	dc.w	$F9
	dc.w	$FFCC
	dc.w	$F9
	dc.w	$FFCE
	dc.w	$FA
	dc.w	$FFCF
	dc.w	$FA
	dc.w	$FFD1
	dc.w	$FA
	dc.w	$FFD2
	dc.w	$FA
	dc.w	$FFD4
	dc.w	$FB
	dc.w	$FFD5
	dc.w	$FB
	dc.w	$FFD7
	dc.w	$FB
	dc.w	$FFD9
	dc.w	$FC
	dc.w	$FFDA
	dc.w	$FC
	dc.w	$FFDC
	dc.w	$FC
	dc.w	$FFDD
	dc.w	$FC
	dc.w	$FFDF
	dc.w	$FC
	dc.w	$FFE0
	dc.w	$FD
	dc.w	$FFE2
	dc.w	$FD
	dc.w	$FFE3
	dc.w	$FD
	dc.w	$FFE5
	dc.w	$FD
	dc.w	$FFE7
	dc.w	$FD
	dc.w	$FFE8
	dc.w	$FD
	dc.w	$FFEA
	dc.w	$FE
	dc.w	$FFEB
	dc.w	$FE
	dc.w	$FFED
	dc.w	$FE
	dc.w	$FFEE
	dc.w	$FE
	dc.w	$FFF0
	dc.w	$FE
	dc.w	$FFF1
	dc.w	$FE
	dc.w	$FFF3
	dc.w	$FE
	dc.w	$FFF5
	dc.w	$FE
	dc.w	$FFF6
	dc.w	$FE
	dc.w	$FFF8
	dc.w	$FE
	dc.w	$FFF9
	dc.w	$FE
	dc.w	$FFFB
	dc.w	$FE
	dc.w	$FFFC
	dc.w	$FE
	dc.w	$FFFE
	dc.w	$FE

LogoPalette:
	dc.w	0
	dc.w	$FFF
	dc.w	$FE0
	dc.w	$DB0
	dc.w	$B90
	dc.w	$870
	dc.w	$650
	dc.w	$430

StormLogo:
	incbin	"stormlogo.raw"

FontPalette:
	dc.w	$950
	dc.w	$A60
	dc.w	$B70
	dc.w	$C80
	dc.w	$D90
	dc.w	$EA0
	dc.w	0

ScrollFont:
	incbin	"stormfont.raw"

lbB008A14:
	dc.b	0
	dc.b	$F3
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F6
	dc.b	$F5
	dc.b	$F6
	dc.b	$F5
	dc.b	$F6
	dc.b	$F6
	dc.b	$F6
	dc.b	$F5
	dc.b	$F7
	dc.b	$F6
	dc.b	$F6
	dc.b	$F6
	dc.b	$F7
	dc.b	$F6
	dc.b	$F7
	dc.b	$F7
	dc.b	$F6
	dc.b	$F7
	dc.b	$F7
	dc.b	$F8
	dc.b	$F7
	dc.b	$F7
	dc.b	$F8
	dc.b	$F7
	dc.b	$F8
	dc.b	$F8
	dc.b	$F8
	dc.b	$F8
	dc.b	$F8
	dc.b	$F9
	dc.b	$F8
	dc.b	$F9
	dc.b	$F8
	dc.b	$F9
	dc.b	$F9
	dc.b	$F9
	dc.b	$F9
	dc.b	$FA
	dc.b	$F9
	dc.b	$FA
	dc.b	$FA
	dc.b	$F9
	dc.b	$FA
	dc.b	$FB
	dc.b	$FA
	dc.b	$FA
	dc.b	$FB
	dc.b	$FB
	dc.b	$FA
	dc.b	$FB
	dc.b	$FB
	dc.b	$FC
	dc.b	$FB
	dc.b	$FC
	dc.b	$FB
	dc.b	$FC
	dc.b	$FC
	dc.b	$FC
	dc.b	$FD
	dc.b	$FC
	dc.b	$FD
	dc.b	$FC
	dc.b	$FD
	dc.b	$FD
	dc.b	$FD
	dc.b	$FE
	dc.b	$FD
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FF
	dc.b	$FE
	dc.b	$FF
	dc.b	$FF
	dc.b	$FF
	dc.b	0
	dc.b	$FF
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	0
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	2
	dc.b	1
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	3
	dc.b	2
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	4
	dc.b	3
	dc.b	4
	dc.b	3
	dc.b	4
	dc.b	4
	dc.b	4
	dc.b	5
	dc.b	4
	dc.b	5
	dc.b	4
	dc.b	5
	dc.b	5
	dc.b	6
	dc.b	5
	dc.b	5
	dc.b	6
	dc.b	6
	dc.b	5
	dc.b	6
	dc.b	7
	dc.b	6
	dc.b	6
	dc.b	7
	dc.b	6
	dc.b	7
	dc.b	7
	dc.b	7
	dc.b	7
	dc.b	8
	dc.b	7
	dc.b	8
	dc.b	7
	dc.b	8
	dc.b	8
	dc.b	8
	dc.b	8
	dc.b	8
	dc.b	9
	dc.b	8
	dc.b	9
	dc.b	9
	dc.b	8
	dc.b	9
	dc.b	9
	dc.b	10
	dc.b	9
	dc.b	9
	dc.b	10
	dc.b	9
	dc.b	10
	dc.b	10
	dc.b	10
	dc.b	9
	dc.b	11
	dc.b	10
	dc.b	10
	dc.b	10
	dc.b	11
	dc.b	10
	dc.b	11
	dc.b	10
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	13
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	12
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	11
	dc.b	12
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	11
	dc.b	10
	dc.b	11
	dc.b	10
	dc.b	11
	dc.b	10
	dc.b	10
	dc.b	11
	dc.b	10
	dc.b	10
	dc.b	9
	dc.b	10
	dc.b	10
	dc.b	9
	dc.b	10
	dc.b	9
	dc.b	9
	dc.b	10
	dc.b	9
	dc.b	9
	dc.b	8
	dc.b	9
	dc.b	9
	dc.b	8
	dc.b	9
	dc.b	8
	dc.b	8
	dc.b	8
	dc.b	8
	dc.b	8
	dc.b	7
	dc.b	8
	dc.b	7
	dc.b	8
	dc.b	7
	dc.b	7
	dc.b	7
	dc.b	7
	dc.b	6
	dc.b	7
	dc.b	6
	dc.b	6
	dc.b	7
	dc.b	6
	dc.b	5
	dc.b	6
	dc.b	6
	dc.b	5
	dc.b	5
	dc.b	6
	dc.b	5
	dc.b	5
	dc.b	4
	dc.b	5
	dc.b	4
	dc.b	5
	dc.b	4
	dc.b	4
	dc.b	4
	dc.b	3
	dc.b	4
	dc.b	3
	dc.b	4
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	2
	dc.b	3
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	1
	dc.b	2
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	0
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	$FF
	dc.b	0
	dc.b	0
	dc.b	$FF
	dc.b	0
	dc.b	$FF
	dc.b	$FF
	dc.b	$FF
	dc.b	$FE
	dc.b	$FF
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FE
	dc.b	$FD
	dc.b	$FE
	dc.b	$FD
	dc.b	$FD
	dc.b	$FD
	dc.b	$FC
	dc.b	$FD
	dc.b	$FC
	dc.b	$FD
	dc.b	$FC
	dc.b	$FC
	dc.b	$FC
	dc.b	$FB
	dc.b	$FC
	dc.b	$FB
	dc.b	$FC
	dc.b	$FB
	dc.b	$FB
	dc.b	$FA
	dc.b	$FB
	dc.b	$FB
	dc.b	$FA
	dc.b	$FA
	dc.b	$FB
	dc.b	$FA
	dc.b	$F9
	dc.b	$FA
	dc.b	$FA
	dc.b	$F9
	dc.b	$FA
	dc.b	$F9
	dc.b	$F9
	dc.b	$F9
	dc.b	$F9
	dc.b	$F8
	dc.b	$F9
	dc.b	$F8
	dc.b	$F9
	dc.b	$F8
	dc.b	$F8
	dc.b	$F8
	dc.b	$F8
	dc.b	$F8
	dc.b	$F7
	dc.b	$F8
	dc.b	$F7
	dc.b	$F7
	dc.b	$F8
	dc.b	$F7
	dc.b	$F7
	dc.b	$F6
	dc.b	$F7
	dc.b	$F7
	dc.b	$F6
	dc.b	$F7
	dc.b	$F6
	dc.b	$F6
	dc.b	$F6
	dc.b	$F7
	dc.b	$F5
	dc.b	$F6
	dc.b	$F6
	dc.b	$F6
	dc.b	$F5
	dc.b	$F6
	dc.b	$F5
	dc.b	$F6
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F5
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F5
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3
	dc.b	$F4
	dc.b	$F3

	even

mt_module:
	incbin	"kawai-k1.mod"

	SECTION	ChipBSS,BSS,CHIP
ScreenBuffer1:
	ds.l	2*BitplaneSize
ScreenBuffer2:
	ds.l	2*BitplaneSize
ScreenBuffer3:
	ds.l	2*BitplaneSize
CopperList1:
	ds.l	250
CopperList2:
	ds.l	250
CalcBuffer:
	ds.w	100
ScrollBitplane:
	ds.b	96*42

	end
