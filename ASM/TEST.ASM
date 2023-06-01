
; --------------------------------------------------------------------------
;
;
;    ********************************************************************
;    *                                                                  *
;    * File:        TEST.ASM                                            *
;    * Format:      SjASMPlus Z80                                       *
;    * Tabs:        28,36,44,52,60,68,76,84                             *
;    *                                                                  *
;    * Project:     NextSID                                             *
;    * Platform:    ZX Spectrum Next                                    *
;    * Programmer:  KevB aka 9bitcolor                                  *
;    *                                                                  *
;    * Modified:    27th June 2021                                      *
;    *                                                                  *
;    * Description: Music player test.                                  *
;    *                                                                  *
;    ********************************************************************
;
;
; --------------------------------------------------------------------------


; Memory Map.


irq_vector	equ	65022	;     2 BYTES Interrupt vector
stack	equ	65021	;   252 BYTES System stack
vector_table	equ	64512	;   257 BYTES Interrupt vector table


; --------------------------------------------------------------------------


; Entry point. Setup some Next registers and an IM2 vector.


; MM0 255 ROM 0
; MM1 255 ROM 8192
; MM2  10 ULA 16384
; MM3  11 ULA 24576
; MM4   4 RAM 32768
; MM5   5 RAM 40960
; MM6   0 RAM 49152
; MM7   1 RAM 57344


startup:	di			; Set stack and interrupts
	ld	sp,stack	; System STACK

	nextreg	TURBO,00000011b	; 28Mhz / 27Mhz

	ld	hl,vector_table	; 252 (FCh)
	ld	a,h
	ld	i,a
	im	2

	inc	a		; 253 (FDh)
	ld	b,l		; Build 257 BYTE INT table

.irq:	ld	(hl),a
	inc	hl
	djnz	.irq		; B = 0
	ld	(hl),a

	ld	a,0FBh		; EI
	ld	hl,04DEDh	; RETI
	ld	[irq_vector-1],a
	ld	[irq_vector],hl


	nextreg	INTMSB,00000100b; ULA off / LINE interrupt off
	nextreg	INTLSB,255	; IRQ on line 192 (not used)

	xor	a

	ld	hl,16384	; Clear ULA screen
	ld	de,16384+1
	ld	bc,6144-1
	ld	(hl),a
	ldir

	ld	sp,22528+768	; Set ULA attributes
	ld	hl,0707h	; PAPER 0:INK 7
	ld	b,192
.attr:	push	hl		; 4 BYTES
	push	hl
	djnz	.attr

	ld	bc,LAYER2
	out	(c),a		; LAYER 2 control OFF
	out	(254),a		; BLACK

	ld	bc,SELECT	; Setup hardware registers

	nextreg	TRANSP,a	; LAYER 2 transparent colour

	ld	a,CONFIG3
	out	(c),a
	inc	b
	in	a,(c)
	set	6,a		; Contention OFF
	set	3,a		; DAC ON
	set	1,a		; Turbosound ON
	out	(c),a

	ld	bc,0xFFFD	; Turbosound PSG #1
	ld	a,11111111b
	out	(c),a

	ld	sp,stack	; System STACK
	ei


; --------------------------------------------------------------------------


; Init the NextSID sound engine, setup the variables and the timers.


	ld	de,-1		; LINE (-1 = use NextSID)
	ld	bc,192		; Vsync line
	ld	a,4		; NextSID bank8k core
	call	nextsid_reset	; Init sound engine

	ld	hl,test_waveform
	ld	a,8
	call	nextsid_set_waveform_A
	call	nextsid_set_waveform_B
	call	nextsid_set_waveform_C

	ld	a,3
	ld	(nextsid_shift_B),a

	ld	hl,0
	ld	(nextsid_detune_B),hl

	ld	a,PSG_ABC+SID_B
	ld	(nextsid_mode),a

;;;	call	set_hybrid
	call	set_monty


; --------------------------------------------------------------------------


; **KEYS 0 1 2 3 4 5 6 M H Z X SPACE ENTER**


; Test loop.


mainloop:	call	nextsid_vsync

	ld	hl,nextsid_shift_B

	ld	a,239		; 0
	in	a,(254)
	and	1
	jr	nz,.no_0
	ld	(hl),0
.no_0:
	ld	a,247		; 1
	in	a,(254)
	and	1
	jr	nz,.no_1
	ld	(hl),1
.no_1:
	ld	a,247		; 2
	in	a,(254)
	and	2
	jr	nz,.no_2
	ld	(hl),2
.no_2:
	ld	a,247		; 3
	in	a,(254)
	and	4
	jr	nz,.no_3
	ld	(hl),3
.no_3:
	ld	a,247		; 4
	in	a,(254)
	and	8
	jr	nz,.no_4
	ld	(hl),4
.no_4:
	ld	a,247		; 5
	in	a,(254)
	and	16
	jr	nz,.no_5
	ld	(hl),5
.no_5:
	ld	a,239		; 6
	in	a,(254)
	and	16
	jr	nz,.no_6
	ld	(hl),6
.no_6:
;	------------

	ld	hl,h_debounce
	ld	b,(hl)

	ld	a,191		; H
	in	a,(254)
	and	16
	ld	(hl),a
	jr	nz,.no_h

	ld	a,b
	and	16
	call	nz,set_hybrid
.no_h:
;	------------

	ld	hl,m_debounce
	ld	b,(hl)

	ld	a,127		; M
	in	a,(254)
	and	4
	ld	(hl),a
	jr	nz,.no_m

	ld	a,b
	and	4
	call	nz,set_monty
.no_m:
;	------------

	ld	a,254		; Z
	in	a,(254)
	and	2
	jp	nz,.no_z
	ld	hl,(nextsid_detune_B)
	dec	hl
	ld	(nextsid_detune_B),hl
.no_z:
	ld	a,254		; X
	in	a,(254)
	and	4
	jp	nz,.no_x
	ld	hl,(nextsid_detune_B)
	inc	hl
	ld	(nextsid_detune_B),hl
.no_x:
	ld	a,127		; SPACE ?
	in	a,(254)
	and	1
	jr	nz,.no_space
	ld	hl,0
	ld	(nextsid_detune_B),hl
.no_space:
;	------------

	ld	hl,enter_debounce
	ld	b,(hl)

	ld	a,191		; ENTER
	in	a,(254)
	and	1
	ld	(hl),a
	jr	nz,.no_enter

	ld	a,b
	and	1
	call	nz,nextsid_pause
.no_enter:
;	------------

	jp	mainloop


; --------------------------------------------------------------------------


; Set song to Hybrid


set_hybrid:	ld	de,hybrid_pt3-40960 ; PT3 offset in 16K
	ld	l,5		; Bank8k a 1st 8K
	ld	h,0		; Bank8k b 2nd 8K
	call	nextsid_set_pt3
	jp	nextsid_play	; Start playback


; --------------------------------------------------------------------------


; Set song to Monty.


set_monty:	ld	de,monty_pt3-40960 ; PT3 offset in 16K
	ld	l,5		; Bank8k a 1st 8K
	ld	h,0		; Bank8k b 2nd 8K
	call	nextsid_set_pt3
	jp	nextsid_play	; Start playback


; --------------------------------------------------------------------------


; Test variables.


h_debounce	db	0
m_debounce	db	0
enter_debounce	db	0


; --------------------------------------------------------------------------


; Test 8 BYTE waveform:	  128 = 1.0
;	   64 = 0.5
;	    1 = 0.0
;	> 128 = CLIP!
;	    0 = ERROR!


test_waveform

 db 128,001,128,001,128,001,128,001


; --------------------------------------------------------------------------

