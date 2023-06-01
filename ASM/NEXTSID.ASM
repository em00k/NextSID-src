
; --------------------------------------------------------------------------
;
;
;    ********************************************************************
;    *                                                                  *
;    * File:        NEXTSID.ASM                                         *
;    * Format:      SjASMPlus Z80                                       *
;    * Tabs:        28,36,44,52,60,68,76,84                             *
;    *                                                                  *
;    * Project:     NextSID                                             *
;    * Platform:    ZX Spectrum Next                                    *
;    * Programmer:  KevB aka 9bitcolor                                  *
;    *                                                                  *
;    * Modified:    27th June 2021                                      *
;    *                                                                  *
;    * Description: NextSID v0.5b.                                      *
;    *                                                                  *
;    ********************************************************************
;
;
; --------------------------------------------------------------------------


; NextSID memory map:

; MM0     0 0x0000 - 0x1FFF 8K    N/A
; MM1  8192 0x2000 - 0x3FFF 8K    N/A
; MM2 16384 0x4000 - 0x5FFF 8K    N/A
; MM3 24576 0x6000 - 0x7FFF 8K    N/A
; MM4 32768 0x8000 - 0x9FFF 4K  * Init, core, VT1-MFX player, tables
; MM5 40960 0xA000 - 0xBFFF 8K  * PT3 bank a
; MM6 49152 0xC000 - 0xDFFF 8K  * PT3 bank b
; MM7 63488 0xF800 - 0xFBFF 1K ** Library functions and timer code

;  * Internal banking hidden from user
; ** Static banking **DO NOT PAGE OUT**


; --------------------------------------------------------------------------


; ABC channel enable masks for nextsid_mode variable.


SID_OFF	equ	00h	; SID enable channel masks
SID_A	equ	01h
SID_B	equ	02h
SID_AB	equ	03h
SID_C	equ	04h
SID_AC	equ	05h
SID_BC	equ	06h
SID_ABC	equ	07h

PSG_OFF	equ	00h	; PSG/SID enable channel masks
PSG_A	equ	10h
PSG_B	equ	20h
PSG_AB	equ	30h
PSG_C	equ	40h
PSG_AC	equ	50h
PSG_BC	equ	60h
PSG_ABC	equ	70h

PT3_PLAY	equ	80h	; PT3 play/stop control
PT3_STOP	equ	00h


; --------------------------------------------------------------------------


; **INTERNAL**


; Read waveform data in reverse and scale volume into local buffer.


	align	256	; **MUST BE 256 BYTE ALIGNED**


; >  H = Amplitude table
; > DE = Destination
; > BC = Source waveform


nextsid_scale_waveform:	ld	a,(bc)		; 32
	ld	l,a
	ldd
	ld	a,(bc)		; 31
	ld	l,a
	ldd
	ld	a,(bc)		; 30
	ld	l,a
	ldd
	ld	a,(bc)		; 29
	ld	l,a
	ldd
	ld	a,(bc)		; 28
	ld	l,a
	ldd
	ld	a,(bc)		; 27
	ld	l,a
	ldd
	ld	a,(bc)		; 26
	ld	l,a
	ldd
	ld	a,(bc)		; 25
	ld	l,a
	ldd
	ld	a,(bc)		; 24
	ld	l,a
	ldd
	ld	a,(bc)		; 23
	ld	l,a
	ldd
	ld	a,(bc)		; 22
	ld	l,a
	ldd
	ld	a,(bc)		; 21
	ld	l,a
	ldd
	ld	a,(bc)		; 20
	ld	l,a
	ldd
	ld	a,(bc)		; 19
	ld	l,a
	ldd
	ld	a,(bc)		; 18
	ld	l,a
	ldd
	ld	a,(bc)		; 17
	ld	l,a
	ldd
	ld	a,(bc)		; 16
	ld	l,a
	ldd
	ld	a,(bc)		; 15
	ld	l,a
	ldd
	ld	a,(bc)		; 14
	ld	l,a
	ldd
	ld	a,(bc)		; 13
	ld	l,a
	ldd
	ld	a,(bc)		; 12
	ld	l,a
	ldd
	ld	a,(bc)		; 11
	ld	l,a
	ldd
	ld	a,(bc)		; 10
	ld	l,a
	ldd
	ld	a,(bc)		; 9
	ld	l,a
	ldd
	ld	a,(bc)		; 8
	ld	l,a
	ldd
	ld	a,(bc)		; 7
	ld	l,a
	ldd
	ld	a,(bc)		; 6
	ld	l,a
	ldd
	ld	a,(bc)		; 5
	ld	l,a
	ldd
	ld	a,(bc)		; 4
	ld	l,a
	ldd
	ld	a,(bc)		; 3
	ld	l,a
	ldd
	ld	a,(bc)		; 2
	ld	l,a
	ldd
	ld	a,(bc)		; 1
	ld	l,a
	ldd
	ret


; --------------------------------------------------------------------------


; **ONLY NEED TO DO THIS ONCE**


;  VGA 28Mhz / 16 (prescaler) = 1750000 PSG and CTC
; HDMI 27Mhz / 16 (prescaler) = 1687500 PSG and CTC

; The TIMER is set for once a scanline for VGA 0..6 50/60Hz and HDMI 50hz.
; HDMI 60Hz runs out of sync as the CTC cannot match the scanline rate.

; VGA 0..6 FPA clocks scale nicely, so no need to adjust the timer. We only
; need to adjust the rate for HDMI 27Mhz.

; Initialize timer for NextSID, configuring for VGA/HDMI.

; **NOTE TURNS DUTY CYCLE OFF**

; **NOTE YOU WILL NEED TO SET A PT3 AND CALL PLAY FUNCTION**


; > DE = Pointer to LINE interrupt routine (-1 = use NextSID)
; > BC = Line number
; >  A = NextSID core bank8k

; <  A = Timer mode (0 VGA / 7 HDMI)


nextsid_init:	di

	ld	hl,0x0504
	ld	(nextsid_bank8k_c),a
	ld	(nextsid_bank8k_a),hl

	ld	a,i		; Patch IM2 vector table
	ld	h,a
	ld	l,0

	inc	de		; Valid address?
	ld	a,e
	or	d
	dec	de
	jr	nz,.valid_line

	ld	de,nextsid_line	; Use internal LINE
	ld	(nextsid_frame),a

.valid_line:	ld	(hl),e		; Set LINE interrupt
	inc	l
	ld	(hl),d
	ld	l,6
	ld	(ctc0_vector0),hl
	ld	(ctc0_vector1),hl ; Set CTC0 interrupt
	ld	(ctc0_vector2),hl
	ld	de,nextsid_ctc0_OFF
	ld	(hl),e
	inc	l
	ld	(hl),d
	inc	l
	ld	de,nextsid_ctc1	; Set CTC1 interrupt
	ld	(hl),e
	inc	l
	ld	(hl),d

	ld	a,b
	and	00000001b
	or	00000110b	; ULA off / LINE interrupt ON
	nextreg	INTMSB,a
	ld	a,c
	nextreg	INTLSB,a	; IM2 on line BC

	ld	a,3
	ld	(nextsid_shift_A),a	; Default shift
	ld	(nextsid_shift_B),a
	ld	(nextsid_shift_C),a

	ld	hl,nextsid_default_waveform
	ld	a,2
	ld	(nextsid_waveptr_A),hl	; Default waveform
	ld	(nextsid_waveptr_B),hl
	ld	(nextsid_waveptr_C),hl
	ld	(nextsid_wavelen_A),a
	ld	(nextsid_wavelen_B),a
	ld	(nextsid_wavelen_C),a
	ld	(nextsid_compare_A+1),a
	ld	(nextsid_compare_B+1),a
	ld	(nextsid_compare_C+1),a

	ld	(nextsid_period_A),hl	; Invalidate
	ld	(nextsid_period_B),hl	; period cache with
	ld	(nextsid_period_C),hl	; value > 4095

	ld	a,1			; **FORCE RELOAD**
	ld	(nextsid_tick_h_A+1),a	; 8.8 counters
	ld	(nextsid_tick_h_B+1),a
	ld	(nextsid_tick_h_C+1),a
	xor	a
	ld	(nextsid_tick_l_A+1),a
	ld	(nextsid_tick_l_B+1),a
	ld	(nextsid_tick_l_C+1),a

	ld	(nextsid_pos_A+1),a	; Waveform position
	ld	(nextsid_pos_B+1),a
	ld	(nextsid_pos_C+1),a

	ld	h,a			; Default detune
	ld	l,a
	ld	(nextsid_detune_A),hl
	ld	(nextsid_detune_B),hl
	ld	(nextsid_detune_C),hl

	ld	(nextsid_mode),a ; STOP / PSG OFF / SID OFF

	nextreg INTCTL,00001001b ; Vector 0x00, stackless, IM2

	nextreg INTEN0,00000010b ; Interrupt enable LINE
	nextreg INTEN1,00000001b ; CTC channel 0 zc/to
	nextreg INTEN2,a	 ; Interrupters

	nextreg INTST0,11111111b ; 
	nextreg INTST1,11111111b ; Set status bits to clear
	nextreg INTST2,11111111b ; 

	nextreg INTDM0,a	 ;
	nextreg INTDM1,a	 ; No DMA
	nextreg INTDM2,a	 ;

	ld	bc,SELECT	; Read timing register
	ld	a,TIMING
	out	(c),a
	inc	b
	in	a,(c)
	and	7
	cp	7		; 0-6 VGA / 7 HDMI ?
	jr	z,.hdmi

;	------------

.vga:	ld	hl,0x001A	; PSG master clock 1750000
	ld	de,0xB3F0
	call	nextsid_set_clocks

	ld	hl,0x003B	; TIMER rate 15350*256
	ld	bc,0xF6E0

	ld	d,114 ; VGA0 50Hz scanline (15350.87719Hz)

	call	nextsid_set_timer_rates

	xor	a		; Return VGA mode
	ret

;	------------

.hdmi:	ld	hl,0x0019	; PSG master clock 1687500
	ld	de,0xBFCC
	call	nextsid_set_clocks

	ld	hl,0x003D	; TIMER rate 15625*256
	ld	bc,0x0900

	ld	d,108 ; HDMI 50Hz scanline (15625.0Hz)

	call	nextsid_set_timer_rates

	ld	a,7		; Return HDMI mode
	ret


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; The following routines are internal.


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; **INTERNAL**


; Set the master 32-bit PSG clocks to match the video VGA/HDMI timing;

;  VGA = 1750000 PSG (28Mhz / 16)
; HDMI = 1687500 PSG (27Mhz / 16)


; > HL = PSG master clock msb
; > DE = PSG master clock lsb

; < HL = As entry
; < DE = As entry


nextsid_set_clocks:	ld	(nextsid_psg_clock_msb_A),hl
	ld	(nextsid_psg_clock_lsb_A),de
	ld	(nextsid_psg_clock_msb_B),hl
	ld	(nextsid_psg_clock_lsb_B),de
	ld	(nextsid_psg_clock_msb_C),hl
	ld	(nextsid_psg_clock_lsb_C),de
	ret


; --------------------------------------------------------------------------


; **INTERNAL**


; Configure NextSID TIMER for CTC channels 0 and 1.


; > HL = TIMER rate msb
; > BC = TIMER rate lsb
; >  D = CTC0 duty cycle time constant
; >  A = Video timing mode (0..7)


nextsid_set_timer_rates:	di

	ld	(nextsid_timer_rate_msb),hl
	ld	(nextsid_timer_rate_lsb),bc

; Bit 7: I Interrupt (disabled / enabled)
; Bit 6: M Mode (timer / counter)
; Bit 5: P Prescaler (16 / 256)
; Bit 4: E Edge select (falling / rising)
; Bit 3: T Trigger (constant load / CLK pulse)
; Bit 2: C Time constant (no constant / follows)
; Bit 1: R Reset (continued / software reset)
; Bit 0: V Control (vector / control word)

	ld	hl,.timing_tab
	add	a,a
	add	hl,a

	ld	bc,CTC0		; Channel 0 port
;                                    IMPETCRV	; Bits 7-0
	ld	a,10000101b	; / 16
	out	(c),a		; Control word
	out	(c),d		; Time constant

	ld	bc,CTC1		; Channel 1 port
;                                    IMPETCRV	; Bits 7-0
	ld	a,10100101b	; / 256
	out	(c),a		; Control word
	ld	a,(hl)
	outinb			; Time constant
	ld	a,(hl)
	ld	(nextsid_50hz_count),a
	ld	(nextsid_50hz_reset),a

	ei
	ret


; PT3 50Hz playback, CTC1 table for all video timing modes.

;	   constant  4.4 binary  T FPGA CLK tempo   4.4

.timing_tab	db	250, 10001100b ; 0 28000000 50Hz =  8.75
	db	186, 11000000b ; 1 28571429 50Hz = 12.0  ?
	db	192, 11000000b ; 2 29464286 50Hz = 12.0  ?
	db	250, 10010110b ; 3 30000000 50Hz =  9.375
	db	250, 10011011b ; 4 31000000 50Hz =  9.6875
	db	250, 10100000b ; 5 32000000 50Hz = 10.0
	db	250, 10100101b ; 6 33000000 50Hz = 10.03125
	db	250, 10000111b ; 7 27000000 50Hz =  8.4375


; --------------------------------------------------------------------------


; **RUN EACH FRAME BY THE PT3 PLAYER**


; PSG channel clock period timer calculation. The default calculation is
; clock / ( period * 16 ). We use the shift count to divide down the value of
; 16 to transpose the channel;

; 15Khz, octave  0  CLK / 16 (shift 4) covers periods   8 to 1854: B8  to A#1
; 15Khz, octave +1  CLK /  8 (shift 3) covers periods  15 to 3708: A8  to C1
; 15Khz, octave +2  CLK /  4 (shift 2) covers periods  29 to 4095: A#7 to C1
; 15Khz, octave +3  CLK /  2 (shift 1) covers periods  58 to 4095: A#6 to C1 
; 15Khz, octave +4  CLK /  1 (shift 0) covers periods 115 to 4095: A#5 to C1 

; **DIVIDING THE CLOCK TOO FAR CAN CAUSE INVALID PERIODS**


; ( TIMER * 256 ) / ( ( CLOCK / ( PERIOD * N ) )


; > HL = PSG master clock msb
; > BC = PSG master clock lsb
; > DE = PSG period (0..4095)

; < DE = 8.8 fixed point TIMER counter


nextsid_clock_by_period:	call	nextsid_divide_32_16

	db	33		; LD HL,NN
nextsid_timer_rate_msb	dw	0		; TIMER rate * 256
	db	1		; LD BC,NN
nextsid_timer_rate_lsb	dw	0


; > HL = MSB 32-bit
; > BC = LSB 32-bit
; > DE = Divisor 16-bit

; < HL = Remainder
; < DE = Result


nextsid_divide_32_16:	ld	a,b
	ld	b,16

.loop:	sla	c
	rla
	adc	hl,hl
	sbc	hl,de
	jp	m,.next

	set	0,c
	djnz	.loop
	ld	d,a
	ld	e,c
	ret

.next:	add	hl,de
	djnz	.loop
	ld	d,a
	ld	e,c
	ret


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; **RUN EACH FRAME BY THE PT3 PLAYER**


; Main NextSID core and register out, replacing rout routine from VT1-MFX.

; Allocates PT3 channels A,B,C to PSG or SID.


nextsid_rout:

;;;	nextreg	FALLBACK,16	; GREEN

	ld	hl,ayregs+10	; Registers 10,9,8
	ld	c,0
	ld	a,(nextsid_mode)
	ld	b,a
	and	a
	jp	m,.play
	xor	a
.play:	and	01110000b	; Master ABC enable bits
	swapnib

	bit	2,a
	jr	nz,.C
	ld	(hl),c		; Mute PSG channel C
.C:	dec	hl

	bit	1,a
	jr	nz,.B
	ld	(hl),c		; Mute PSG channel B
.B:	dec	hl

	bit	0,a
	jr	nz,.A
	ld	(hl),c		; Mute PSG channel A
.A:
	and	b

	bit	4,(hl)		; Envelope ?
	jr	z,.amp8
	and	11111110b	; Disable SID A
.amp8:	inc	hl
	
	bit	4,(hl)
	jr	z,.amp9
;	and	11111101b	; Disable SID B
.amp9:	inc	hl
	
	bit	4,(hl)
	jr	z,.amp10
	and	11111011b	; Disable SID C
.amp10:
;	------------

	ld	de,0x23ED	; Opcode selection for
				; reg 8,9,10 write/skip
	ld	hl,ctc0_reg8
	ld	(hl),d		; 0x23A3 INC HL+AND E
	rrca
	jr	c,.sid8
	ld	(hl),e		; 0xEDA3 OUTI
.sid8:
	ld	hl,ctc0_reg9
	ld	(hl),d
	rrca
	jr	c,.sid9
	ld	(hl),e
.sid9:
	ld	hl,ctc0_reg10
	ld	(hl),d
	rrca
	jr	c,.sid10
	ld	(hl),e
.sid10:
	rrca
	rrca			; CBA00000 -> 00CBA000
	ld	(ctc0_cba+1),a	; Override nextsid_mode

;	------------

	ld	a,(ctc0_cba+1)
	and	00001000b
	jr	z,nextsid_no_A

	ld	a,(ayregs+8)	; AMPLITUDE A
	add	a,nextsid_prescale_tab/256
	ld	h,a

	ld	a,(nextsid_wavelen_A)
	ld	(nextsid_compare_A+1),a
	ld	bc,(nextsid_waveptr_A)
	dec	bc
	ld	de,nextsid_waveform_A-1
	add	bc,a
	add	de,a
	add	a,a		; Calc CALL
	add	a,a
	neg
	add	a,128
	ld	(.patch+1),a
.patch:	call	nextsid_scale_waveform

	ld	de,(ayregs+0)	; Read new period
	db	33		; LD HL,NN
nextsid_period_A	dw	0		; Previous period
	ld	(nextsid_period_A),de
	ld	a,h		; Only update rate if
	cp	d		; changed to save cycles
	jr	nz,nextsid_update_A
	ld	a,l
	cp	e
	jr	z,nextsid_no_A

nextsid_update_A:	ld	a,(nextsid_shift_A)
	ld	b,a		; Period * 16 / N
	bsla	de,b		; Divide PSG master clock
	ld	hl,(nextsid_psg_clock_msb_A)
	ld	bc,(nextsid_psg_clock_lsb_A)
	call	nextsid_clock_by_period

	ld	hl,(nextsid_detune_A)
	add	hl,de		; Add 16-bit signed value
	ld	(nextsid_reset_A),hl ; Reset INT (ATOMIC)
nextsid_no_A:
;	------------
;	------------
;	------------

	ld	a,(ctc0_cba+1)
	and	00010000b
	jr	z,nextsid_no_B

	ld	a,(ayregs+9)	; AMPLITUDE B
	add	a,nextsid_prescale_tab/256
	ld	h,a

	ld	a,(nextsid_wavelen_B)
	ld	(nextsid_compare_B+1),a
	ld	bc,(nextsid_waveptr_B)
	dec	bc
	ld	de,nextsid_waveform_B-1
	add	bc,a
	add	de,a
	add	a,a		; Calc CALL
	add	a,a
	neg
	add	a,128
	ld	(.patch+1),a
.patch:	call	nextsid_scale_waveform

	ld	de,(ayregs+2)	; Read new period
	db	33		; LD HL,NN
nextsid_period_B	dw	0		; Previous period
	ld	(nextsid_period_B),de
	ld	a,h		; Only update rate if
	cp	d		; changed to save cycles
	jr	nz,nextsid_update_B
	ld	a,l
	cp	e
	jr	z,nextsid_no_B

nextsid_update_B:	ld	a,(nextsid_shift_B)
	ld	b,a		; Period * 16 / N
	bsla	de,b		; Divide PSG master clock
	ld	hl,(nextsid_psg_clock_msb_B)
	ld	bc,(nextsid_psg_clock_lsb_B)
	call	nextsid_clock_by_period

	ld	hl,(nextsid_detune_B)
	add	hl,de		; Add 16-bit signed value
	ld	(nextsid_reset_B),hl ; Reset INT (ATOMIC)
nextsid_no_B:
;	------------
;	------------
;	------------

	ld	a,(ctc0_cba+1)
	and	00100000b
	jr	z,nextsid_no_C

	ld	a,(ayregs+10)	; AMPLITUDE C
	add	a,nextsid_prescale_tab/256
	ld	h,a

	ld	a,(nextsid_wavelen_C)
	ld	(nextsid_compare_C+1),a
	ld	bc,(nextsid_waveptr_C)
	dec	bc
	ld	de,nextsid_waveform_C-1
	add	bc,a
	add	de,a
	add	a,a		; Calc CALL
	add	a,a
	neg
	add	a,128
	ld	(.patch+1),a
.patch:	call	nextsid_scale_waveform

	ld	de,(ayregs+4)	; Read new period
	db	33		; LD HL,NN
nextsid_period_C	dw	0		; Previous period
	ld	(nextsid_period_C),de
	ld	a,h		; Only update rate if
	cp	d		; changed to save cycles
	jr	nz,nextsid_update_C
	ld	a,l
	cp	e
	jr	z,nextsid_no_C

nextsid_update_C:	ld	a,(nextsid_shift_C)
	ld	b,a		; Period * 16 / N
	bsla	de,b		; Divide PSG master clock
	ld	hl,(nextsid_psg_clock_msb_C)
	ld	bc,(nextsid_psg_clock_lsb_C)
	call	nextsid_clock_by_period

	ld	hl,(nextsid_detune_C)
	add	hl,de		; Add 16-bit signed value
	ld	(nextsid_reset_C),hl ; Reset INT (ATOMIC)
nextsid_no_C:
;	------------
;	------------
;	------------
;	------------
;	------------
;	------------
;	------------

	db	42		; LD HL,(NN)
ctc0_vector0	dw	0		; Address in vector table
	ld	(nextsid_ctc0_rout+1),hl

	ld	hl,nextsid_ctc0_rout ; 'Hijack' CTC0
	db	34		; LD (NN),HL
ctc0_vector1	dw	0		; Address in vector table
	ret


; --------------------------------------------------------------------------


nextsid_default_waveform		 	; Default 32 byte waveform

 db 128,001,128,001,128,001,128,001
 db 128,001,128,001,128,001,128,001
 db 128,001,128,001,128,001,128,001
 db 128,001,128,001,128,001,128,001


; --------------------------------------------------------------------------

