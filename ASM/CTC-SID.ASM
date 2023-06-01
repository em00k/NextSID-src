
; --------------------------------------------------------------------------
;
;
;    ********************************************************************
;    *                                                                  *
;    * File:        CTC-SID.ASM                                         *
;    * Format:      SjASMPlus Z80                                       *
;    * Tabs:        28,36,44,52,60,68,76,84                             *
;    *                                                                  *
;    * Project:     NextSID                                             *
;    * Platform:    ZX Spectrum Next                                    *
;    * Programmer:  KevB aka 9bitcolor                                  *
;    *                                                                  *
;    * Modified:    27th June 2021                                      *
;    *                                                                  *
;    * Description: NextSID CTC routines.                               *
;    *                                                                  *
;    ********************************************************************
;
;
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; F7 PAGE: Waveform A, static data and CTC0 hijack code **27 BYTES FREE**


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


	align	256	; **MUST BE 256 BYTE ALIGNED**

nextsid_waveform_A	ds	32,0	; SID channel A local wave buffer


; --------------------------------------------------------------------------


nextsid_mode	db	0		; Control (see SID_OFF)
	db	0		; **RESERVED**

nextsid_waveptr_A	dw	0		; Waveform vars
nextsid_waveptr_B	dw	0
nextsid_waveptr_C	dw	0
nextsid_wavelen_A	db	0
nextsid_wavelen_B	db	0
nextsid_wavelen_C	db	0

nextsid_shift_A	db	0		; Octave shift
nextsid_shift_B	db	0
nextsid_shift_C	db	0

nextsid_detune_A	dw	0		; Detune 16-bit value
nextsid_detune_B	dw	0
nextsid_detune_C	dw	0

nextsid_psg_clock_msb_A	dw	0		; PSG 32-bit master clock
nextsid_psg_clock_lsb_A	dw	0
nextsid_psg_clock_msb_B	dw	0
nextsid_psg_clock_lsb_B	dw	0
nextsid_psg_clock_msb_C	dw	0
nextsid_psg_clock_lsb_C	dw	0


; --------------------------------------------------------------------------


; **IM2 CTC0 INTERRUPT**


; Interrupt mode 2 CTC0 'hijack' routine to output PSG registers.


nextsid_ctc0_rout:	call	0	; Call current SID CTC0 stub which
	di		; enables interrupts on exit.
	push	af	; We disable interrupts while we
	push	bc	; patch the CTC0 timer Z80 code.
	push	de	; We have penty of time until the
	push	hl	; next CTC0 interrupt is due...

	ld	(ctc0_stack+1),sp ; Safe to borrow SP

	ld	de,0xBFFF	; PSG (E = 0xFF for AND E)
	ld	bc,0xFFFD
	ld	hl,ayregs	; Registers 0..13

	xor	a
	out	(c),a		; 0 Fine A
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 1 Coarse A
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 2 Fine B
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 3 Coarse B
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 4 Fine C
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 5 Coarse C
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 6 Noise
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 7 Tone enable
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 8 Amplitude
	ld	b,d
ctc0_reg8:	outi			; OUTI / INC HL+AND E
	ld	b,e

	inc	a
	out	(c),a		; 9 Amplitude
	ld	b,d
ctc0_reg9:	outi			; OUTI / INC HL+AND E
	ld	b,e

	inc	a
	out	(c),a		; 10 Amplitude
	ld	b,d
ctc0_reg10:	outi			; OUTI / INC HL+AND E
	ld	b,e

	inc	a
	out	(c),a		; 11 Envelope fine
	ld	b,d
	outi
	ld	b,e

	inc	a
	out	(c),a		; 12 Envelope coarse
	ld	b,d
	outi
	ld	b,e

	bit	7,(hl)
	jr	nz,.no_reg13	; Don't write if negative

	inc	a
	out	(c),a		; 13 Envelope shape
	ld	b,d
	outi
.no_reg13:
;	------------

ctc0_cba:	ld	sp,nextsid_channel_tab ; Select channel(s)
	pop	hl
	ld	(nextsid_A_jr_C),hl ; Patch CTC0 JR code
	pop	hl		    ; to jump over unused
	ld	(nextsid_A_jr_B),hl ; SID channel routines
	pop	hl		    ; saving 1000s of CPU
	ld	(nextsid_C_jr_B),hl ; cycles per frame!

	pop	hl		; Update SID CTC0 stub
	db	34		; LD (NN),HL
ctc0_vector2	dw	0		; Address in vector table

;	------------

ctc0_stack:	ld	sp,0		; Restore stack

	pop	hl
	pop	de
	pop	bc
	pop	af
	ei
	reti


; --------------------------------------------------------------------------


ayregs	ds	14,0		; AY register/spare buffer


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; F8 PAGE: Waveform buffer B, LINE and CTC1 interrupt code **98 BYTES FREE**


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


	align	256	; **MUST BE 256 BYTE ALIGNED**

nextsid_waveform_B	ds	32,0	; SID channel B local wave buffer


; --------------------------------------------------------------------------


; **IM2 LINE INTERRUPT**


; Interrupt mode 2 LINE routine.


nextsid_line:	ei
	push	af

	db	62		; LD A,N
nextsid_frame	db	0
	inc	a
	ld	(nextsid_frame),a

	pop	af
	reti


; --------------------------------------------------------------------------


; **IM2 CTC1 INTERRUPT**


; Calls the PT3 music player at 50Hz.


nextsid_ctc1:	ei			; Allow CTC0 interrupt
	push	af

	db	62		; LD A,N
nextsid_50hz_count	db	10001100b	; 4.4 fixed point counter
	sub	16		; Subtract 1.0
	ld	(nextsid_50hz_count),a
	jr	z,.play
	jr	nc,nextsid_ctc1_out ; Still counting...

;	------------

.play:	db	198		; ADD A,N
nextsid_50hz_reset	db	10001100b	; Reset 50hz counter
	ld	(nextsid_50hz_count),a

;;;	nextreg	FALLBACK,128	; Raster timing RED

	ex	af,af'		; **VT1-MFX REGISTERS**
	push	af
	push	bc
	push	de
	push	hl
	push	ix

	ld	bc,SELECT	; Backup port 0x243B
	in	a,(c)
	ld	(nextsid_243B+1),a

	ld	a,MM4		; Backup/set MMU4
	out	(c),a
	inc	b
	in	a,(c)
	ld	(nextsid_mm4),a
	db	62		; LD A,N
nextsid_bank8k_c	db	0
	out	(c),a		; Bank in NextSID core

	ld	a,(nextsid_mode); NextSID control variable
	and	a
	jp	m,nextsid_playing ; PLAY / STOP ?

	call	nextsid_rout
	jr	nextsid_paused

;	------------

nextsid_playing:	dec	b		; Backup/set MMU5/MMU6

	db	33		; LD HL,NN
nextsid_bank8k_a	db	0		; L = bank8k a
nextsid_bank8k_b	db	0		; H = bank8k b
	ld	a,MM5
	out	(c),a
	inc	b
	in	e,(c)
	out	(c),l
	dec	b
	inc	a
	out	(c),a
	inc	b
	in	d,(c)
	out	(c),h

	push	de		; Stack MMU a+b
	call	play		; Call PT3 player
	pop	de
	
	ld	a,e		; Restore MMU5/MMU6
	nextreg	MM5,a
	ld	a,d
	nextreg	MM6,a

;	------------

nextsid_paused:	db	0xED,0x91,MM4	; NEXTREG MM4,N
nextsid_mm4:	db	0

	ld	bc,SELECT	; Restore port 0x243B
nextsid_243B:	ld	a,0
	out	(c),a

	pop	ix		; **VT1-MFX REGISTERS**
	pop	hl
	pop	de
	pop	bc
	pop	af
	ex	af,af'

;;;	nextreg	FALLBACK,0	; Raster timing BLACK

nextsid_ctc1_out:	pop	af
	reti


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; F9 PAGE: Waveform buffer C and user functions **16 BYTES FREE**


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


	align	256	; **MUST BE 256 BYTE ALIGNED**

nextsid_waveform_C	ds	32,0	; SID channel C local wave buffer


; --------------------------------------------------------------------------


; Reset NextSID and start CTC timers.


; **CHANGES PORT 243B**


; > DE = Pointer to LINE interrupt routine (-1 = use NextSID)
; > BC = Line number
; >  A = NextSID core bank8k

; <  A = Timer mode (0 VGA / 7 HDMI)


nextsid_reset:	push	bc		; Backup MMU4
	ld	bc,SELECT
	ld	h,MM4
	out	(c),h
	inc	b
	in	c,(c)
	ld	hl,.mm4+3
	ld	(hl),c
	pop	bc
	nextreg	MM4,a		; Bank NextSID core at MM4

	call	nextsid_init

.mm4:	nextreg	MM4,0		; Restore MMU4
	ret


; --------------------------------------------------------------------------


; LINE interrupt vsync.


nextsid_vsync:	ld	hl,nextsid_frame
	ld	a,(hl)

.vsync:	cp	(hl)	; Wait for LINE to change variable
	jr	z,.vsync
	ret


; --------------------------------------------------------------------------


; Start / stop NextSID VT1-MFX playback. **TIMERS STAY RUNNING**


nextsid_pause:	ld	a,(nextsid_mode); Toggles PLAY / STOP
	bit	7,a
	jr	nz,nextsid_stop

nextsid_play:	ld	hl,nextsid_mode	; Runs VT1-MFX player
	set	7,(hl)
	ret

nextsid_stop:	ld	hl,nextsid_mode	; Halts VT1-MFX player
	res	7,(hl)
	ret


; --------------------------------------------------------------------------


; **CHANGES PORT 243B**


; Stop playback and do full PT3 init from any SRAM source bank8k.


; > DE = PT3 offset into 16K
; >  L = PT3 source bank8k a in SRAM (can be out of order)
; >  H = PT3 source bank8k b in SRAM (can be out of order)


nextsid_set_pt3:	di
	ld	(nextsid_bank8k_a),hl	; Patch bank8k a/b

	ld	bc,SELECT	; Backup MMU4/MMU5/MMU6
	ld	a,MM4
	out	(c),a
	inc	b
	in	a,(c)
	push	af
	ld	a,(nextsid_bank8k_c)
	out	(c),a		; Bank in NextSID core
	dec	b
	
	ld	a,MM5
	out	(c),a
	inc	b
	in	a,(c)
	push	af
	out	(c),l		; Bank in PT3 a (low)
	dec	b
	
	ld	a,MM6
	out	(c),a
	inc	b
	in	a,(c)
	push	af
	out	(c),h		; Bank in PT3 b (high)

	ld	hl,nextsid_mode	; Stop playback
	res	7,(hl)	

	ex	de,hl
	add	hl,40960		; MM5 + offset

	ld	(nextsid_period_A),hl	; Invalidate
	ld	(nextsid_period_B),hl	; period cache with
	ld	(nextsid_period_C),hl	; value > 4095
	ei

	call	init		; VT1-MFX init as normal

	pop	af
	nextreg	MM4,a		; Restore MMU4/MMU5/MMU6
	pop	af
	nextreg	MM5,a
	pop	af
	nextreg	MM6,a
	ret


; --------------------------------------------------------------------------


; Use these **ATOMIC** functions to set the timer waveform variables.


; > HL = Waveform pointer
; >  A = Waveform length (valid options are 2,4,8,16,32)

; < HL = As entry
; <  A = As entry


nextsid_set_waveform_A:	di
	ld	(nextsid_wavelen_A),a
	ld	(nextsid_waveptr_A),hl
	ei
	ret

nextsid_set_waveform_B:	di
	ld	(nextsid_wavelen_B),a
	ld	(nextsid_waveptr_B),hl
	ei
	ret

nextsid_set_waveform_C:	di
	ld	(nextsid_wavelen_C),a
	ld	(nextsid_waveptr_C),hl
	ei
	ret


; --------------------------------------------------------------------------


; Use these **ATOMIC** functions to set the PSG master clock variables.


; > DE = PSG master clock msb
; > BC = PSG master clock lsb

; < DE = As entry
; < BC = As entry


nextsid_set_psg_clock_A:	di
	ld	(nextsid_psg_clock_msb_A),de
	ld	(nextsid_psg_clock_lsb_A),bc
	ei
	ret

nextsid_set_psg_clock_B:	di
	ld	(nextsid_psg_clock_msb_B),de
	ld	(nextsid_psg_clock_lsb_B),bc
	ei
	ret

nextsid_set_psg_clock_C:	di
	ld	(nextsid_psg_clock_msb_C),de
	ld	(nextsid_psg_clock_lsb_C),bc
	ei
	ret


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; FA PAGE: Main CTC0 interrupt code **142 BYTES FREE**


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; CTC timer code SID channel config table.


	align	256	; **MUST BE 256 BYTE ALIGNED**

nextsid_channel_tab	dw 0x1428, 0x4228, 0x0B28, nextsid_ctc0_OFF ; ---
	dw 0x0C18, 0x4228, 0x0B28, nextsid_ctc0_A   ; --A
	dw 0x1428, 0x4228, 0x0B28, nextsid_ctc0_B   ; -B-
	dw 0x0318, 0x4228, 0x0B28, nextsid_ctc0_AB  ; -BA
	dw 0x1428, 0x4228, 0x0318, nextsid_ctc0_C   ; C--
	dw 0x1428, 0x0318, 0x0318, nextsid_ctc0_AC  ; C-A
	dw 0x1428, 0x4228, 0x0B28, nextsid_ctc0_CB  ; CB-
	dw 0x1428, 0x4228, 0x0B28, nextsid_ctc0_ACB ; CBA

; The above table is used to patch JR DIS (0x18) and JR Z,DIS (0x28) opcodes
; to configure the channel allocation. Changing the timer code may requre the
; DIS entry to be modified. The three following addresses relate to the first
; three byte swapped WORDS for each of the eight channel combinations above;

;	pop	hl
;	ld	(nextsid_A_jr_C),hl ; Patch CTC0 JR code
;	pop	hl		    ; to jump over unused
;	ld	(nextsid_A_jr_B),hl ; SID channel routines
;	pop	hl		    ; saving 1000s of CPU
;	ld	(nextsid_C_jr_B),hl ; cycles per frame!


; --------------------------------------------------------------------------


; 15Khz IM2 timer stubs for 3-bit A,B,C channel combinations.


nextsid_ctc0_A:	push	af
	ld	a,(nextsid_tick_h_A+1)
	dec	a
	jr	z,nextsid_A_push
	ld	(nextsid_tick_h_A+1),a
	pop	af
	ei
	reti

;	------------

nextsid_ctc0_AB:	push	af
	ld	a,(nextsid_tick_h_A+1)
	dec	a
	jr	z,nextsid_A_push
	ld	(nextsid_tick_h_A+1),a

	ld	a,(nextsid_tick_h_B+1)
	dec	a
	jp	z,nextsid_B_push
	ld	(nextsid_tick_h_B+1),a
	pop	af
	ei
	reti

;	------------

nextsid_ctc0_AC:	push	af
	ld	a,(nextsid_tick_h_A+1)
	dec	a
	jr	z,nextsid_A_push
	ld	(nextsid_tick_h_A+1),a

	ld	a,(nextsid_tick_h_C+1)
	dec	a
	jr	z,nextsid_C_push
	ld	(nextsid_tick_h_C+1),a
	pop	af
	ei
	reti

;	------------

nextsid_ctc0_ACB:	push	af
nextsid_tick_h_A:	ld	a,1
	dec	a
	jr	z,nextsid_A_push
	ld	(nextsid_tick_h_A+1),a

nextsid_tick_h_C:	ld	a,1
	dec	a
	jr	z,nextsid_C_push
	ld	(nextsid_tick_h_C+1),a

nextsid_tick_h_B:	ld	a,1
	dec	a
	jr	z,nextsid_B_push
	ld	(nextsid_tick_h_B+1),a
	pop	af

nextsid_ctc0_OFF:	ei
	reti


; --------------------------------------------------------------------------


; Order is always A,C,B so less workload when only using channel B.


nextsid_A_push:	push	bc
	push	hl
nextsid_A_no_push:	db	33		; LD HL,NN
nextsid_reset_A:	dw	0		; **ATOMIC**
nextsid_tick_l_A:	ld	a,0
	add	a,l
	ld	(nextsid_tick_l_A+1),a
	ld	a,0
	adc	a,h
	ld	(nextsid_tick_h_A+1),a

nextsid_pos_A:	ld	hl,nextsid_waveform_A
	ld	bc,0xFFFD
	ld	a,8
	out	(c),a		; OUT (C),A / LD C,DAC
	ld	b,0xBF
	outinb
	ld	a,l
nextsid_compare_A:	cp	0
	jr	c,nextsid_no_wrap_A
	xor	a
nextsid_no_wrap_A:	ld	(nextsid_pos_A+1),a

;	------------

	ld	a,(nextsid_tick_h_C+1)
	dec	a
nextsid_A_jr_C:	jr	z,nextsid_C_no_push	; JR Z / JR
	ld	(nextsid_tick_h_C+1),a

	ld	a,(nextsid_tick_h_B+1)
	dec	a
nextsid_A_jr_B:	jr	z,nextsid_B_no_push	; JR Z / JR
	ld	(nextsid_tick_h_B+1),a

	pop	hl
	pop	bc
	pop	af
	ei
	reti

;	------------
;	------------
;	------------

nextsid_C_push:	push	bc
	push	hl
nextsid_C_no_push:	db	33		; LD HL,NN
nextsid_reset_C:	dw	0		; **ATOMIC**
nextsid_tick_l_C:	ld	a,0
	add	a,l
	ld	(nextsid_tick_l_C+1),a
	ld	a,0
	adc	a,h
	ld	(nextsid_tick_h_C+1),a

nextsid_pos_C:	ld	hl,nextsid_waveform_C
	ld	bc,0xFFFD
	ld	a,10
	out	(c),a		; OUT (C),A / LD C,DAC
	ld	b,0xBF
	outinb
	ld	a,l
nextsid_compare_C:	cp	0
	jr	c,nextsid_no_wrap_C
	xor	a
nextsid_no_wrap_C:	ld	(nextsid_pos_C+1),a

;	------------

	ld	a,(nextsid_tick_h_B+1)
	dec	a
nextsid_C_jr_B:	jr	z,nextsid_B_no_push	; JR Z / JR
	ld	(nextsid_tick_h_B+1),a

	pop	hl
	pop	bc
	pop	af
	ei
	reti

;	------------
;	------------
;	------------

nextsid_B_push:	push	bc
	push	hl
nextsid_B_no_push:	db	33		; LD HL,NN
nextsid_reset_B:	dw	0		; **ATOMIC**
nextsid_tick_l_B:	ld	a,0
	add	a,l
	ld	(nextsid_tick_l_B+1),a
	ld	a,0
	adc	a,h
	ld	(nextsid_tick_h_B+1),a

nextsid_pos_B:	ld	hl,nextsid_waveform_B

	ld	a,(hl)
	nextreg	FALLBACK,a	; **RASTER TIMING**

	ld	bc,0xFFFD
	ld	a,9
	out	(c),a
	ld	b,0xBF
	outinb
	ld	a,l
nextsid_compare_B:	cp	0
	jr	c,nextsid_no_wrap_B
	xor	a
nextsid_no_wrap_B:	ld	(nextsid_pos_B+1),a

	pop	hl
	pop	bc
	pop	af
	ei
	reti


; --------------------------------------------------------------------------


; 15Khz IM2 timer stubs for 3-bit B,C channel combinations.


nextsid_ctc0_C:	push	af
	ld	a,(nextsid_tick_h_C+1)
	dec	a
	jr	z,nextsid_C_push
	ld	(nextsid_tick_h_C+1),a
	pop	af
	ei
	reti

;	------------

nextsid_ctc0_CB:	push	af
	ld	a,(nextsid_tick_h_C+1)
	dec	a
	jr	z,nextsid_C_push
	ld	(nextsid_tick_h_C+1),a

	ld	a,(nextsid_tick_h_B+1)
	dec	a
	jr	z,nextsid_B_push
	ld	(nextsid_tick_h_B+1),a
	pop	af
	ei
	reti

;	------------

nextsid_ctc0_B:	push	af
	ld	a,(nextsid_tick_h_B+1)
	dec	a
	jr	z,nextsid_B_push
	ld	(nextsid_tick_h_B+1),a
	pop	af
	ei
	reti


; --------------------------------------------------------------------------

