
; --------------------------------------------------------------------------
;
;
;    ********************************************************************
;    *                                                                  *
;    * File:        MAIN.ASM                                            *
;    * Format:      SjASMPlus Z80                                       *
;    * Tabs:        28,36,44,52,60,68,76,84                             *
;    *                                                                  *
;    * Project:     NextSID                                             *
;    * Platform:    ZX Spectrum Next                                    *
;    * Programmer:  KevB aka 9bitcolor                                  *
;    *                                                                  *
;    * Modified:    27th June 2021                                      *
;    *                                                                  *
;    * Description: Main file.                                          *
;    *                                                                  *
;    ********************************************************************
;
;
; --------------------------------------------------------------------------


	device zxspectrum48


; --------------------------------------------------------------------------


	include "INC/EQUATES.INC"	; Program equates
	include "INC/HARDWARE.INC"	; ZX Spectrum Next


; --------------------------------------------------------------------------


	org	32768			; MM4 bank8k

	include "INC/VOL-SID.INC"	; 4096 BYTES
	include "ASM/NEXTSID.ASM"
	include "ASM/VT1-SID.ASM"

	org	40955

	db	"v0.5b"


; --------------------------------------------------------------------------


	org	40960			; MM5 bank8k


; --------------------------------------------------------------------------


monty_pt3	incbin	 "BIN/AUF_SID.PT3"
hybrid_pt3	incbin	 "BIN/HYBRID.PT3"
;;;robocop_pt3	incbin	 "BIN/RobocopSID.PT3"
;;;odyssey_pt3	incbin	 "BIN/OdysseySID.PT3"


; --------------------------------------------------------------------------




; --------------------------------------------------------------------------


end_of_code		; Should be below 57343 (current ?????)


; --------------------------------------------------------------------------


	org	57344			; MM6 bank8k


; --------------------------------------------------------------------------


	include "ASM/TEST.ASM"		; Player test


; --------------------------------------------------------------------------


; Functions and variables.


	dw	nextsid_waveform_A
	dw	nextsid_waveform_B
	dw	nextsid_waveform_C
	dw	ayregs

	dw	nextsid_mode
	dw	nextsid_waveptr_A
	dw	nextsid_waveptr_B
	dw	nextsid_waveptr_C
	dw	nextsid_wavelen_A
	dw	nextsid_wavelen_B
	dw	nextsid_wavelen_C
	dw	nextsid_shift_A
	dw	nextsid_shift_B
	dw	nextsid_shift_C
	dw	nextsid_detune_A
	dw	nextsid_detune_B
	dw	nextsid_detune_C
	dw	nextsid_psg_clock_msb_A
	dw	nextsid_psg_clock_lsb_A
	dw	nextsid_psg_clock_msb_B
	dw	nextsid_psg_clock_lsb_B
	dw	nextsid_psg_clock_msb_C
	dw	nextsid_psg_clock_lsb_C
	dw	nextsid_reset_A
	dw	nextsid_reset_B
	dw	nextsid_reset_C

	dw	nextsid_reset
	dw	nextsid_vsync
	dw	nextsid_pause
	dw	nextsid_play
	dw	nextsid_stop
	dw	nextsid_set_pt3
	dw	nextsid_set_waveform_A
	dw	nextsid_set_waveform_B
	dw	nextsid_set_waveform_C
	dw	nextsid_set_psg_clock_A
	dw	nextsid_set_psg_clock_B
	dw	nextsid_set_psg_clock_C


; --------------------------------------------------------------------------


	org	63232


; --------------------------------------------------------------------------


	include "ASM/CTC-SID.ASM"	; 1152 BYTES

	org	64379

nextsid_version	db	"v0.5b"			; Version string


; --------------------------------------------------------------------------


	savesna	"NEXTSID.SNX",startup


; --------------------------------------------------------------------------

