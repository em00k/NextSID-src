
; --------------------------------------------------------------------------
;
;
;    ********************************************************************
;    *                                                                  *
;    * File:        NEXTSID.INC                                         *
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
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; Equates.


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; ABC channel enable masks for BYTE nextsid_mode variable.


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
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; Buffers.


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


nextsid_waveform_A	equ	0xF700	; 32 BYTES SID A local waveform
nextsid_waveform_B	equ	0xF800	; 32 BYTES SID B local waveform
nextsid_waveform_C	equ	0xF900	; 32 BYTES SID C local waveform

ayregs	equ	0xF7D7	; 14 BYTES VT1-MFX AY registers


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; Variables.


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


nextsid_mode	equ	0xF720	; BYTE     Control (see SID_OFF)

nextsid_waveptr_A	equ	0xF722	; WORD     Waveform pointers
nextsid_waveptr_B	equ	0xF724	; WORD  
nextsid_waveptr_C	equ	0xF726	; WORD  

nextsid_wavelen_A	equ	0xF728	; BYTE     Waveform length
nextsid_wavelen_B	equ	0xF729	; BYTE  
nextsid_wavelen_C	equ	0xF72A	; BYTE  

nextsid_shift_A	equ	0xF72B	; BYTE     Octave shift
nextsid_shift_B	equ	0xF72C	; BYTE  
nextsid_shift_C	equ	0xF72D	; BYTE  

nextsid_detune_A	equ	0xF72E	; WORD     Detune 16-bit value
nextsid_detune_B	equ	0xF730	; WORD  
nextsid_detune_C	equ	0xF732	; WORD  

nextsid_psg_clock_msb_A	equ	0xF734	; WORD     PSG 32-bit master clock
nextsid_psg_clock_lsb_A	equ	0xF736	; WORD  
nextsid_psg_clock_msb_B	equ	0xF738	; WORD  
nextsid_psg_clock_lsb_B	equ	0xF73A	; WORD  
nextsid_psg_clock_msb_C	equ	0xF73C	; WORD  
nextsid_psg_clock_lsb_C	equ	0xF73E	; WORD

nextsid_reset_A	equ	0xFA9D	; WORD     Timer count **ATOMIC**
nextsid_reset_B	equ	0xFB14	; WORD  
nextsid_reset_C	equ	0xFADD	; WORD  


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; Functions.


; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------


; Reset NextSID and start CTC timers.


; **CHANGES PORT 243B**


; > DE = Pointer to LINE interrupt routine (-1 = use NextSID)
; > BC = Line number
; >  A = NextSID core bank8k

; <  A = Timer mode (0 VGA / 7 HDMI)


nextsid_reset	equ	0xF920


; --------------------------------------------------------------------------


; LINE interrupt vsync.


nextsid_vsync	equ	0xF93B


; --------------------------------------------------------------------------


; Start / stop NextSID VT1-MFX playback. **TIMERS STAY RUNNING**


nextsid_pause	equ	0xF943
nextsid_play	equ	0xF94A
nextsid_stop	equ	0xF950


; --------------------------------------------------------------------------


; **CHANGES PORT 243B**


; Stop playback and do full PT3 init from any SRAM source bank8k.


; > DE = PT3 offset into 16K
; >  L = PT3 source bank8k a in SRAM (can be out of order)
; >  H = PT3 source bank8k b in SRAM (can be out of order)


nextsid_set_pt3	equ	0xF956


; --------------------------------------------------------------------------


; Use these **ATOMIC** functions to set the timer waveform variables.


; > HL = Waveform pointer
; >  A = Waveform length (valid options are 2,4,8,16,32)

; < HL = As entry
; <  A = As entry


nextsid_set_waveform_A	equ	0xF9A4
nextsid_set_waveform_B	equ	0xF9AD
nextsid_set_waveform_C	equ	0xF9B6


; --------------------------------------------------------------------------


; Use these **ATOMIC** functions to set the PSG master clock variables.


; > DE = PSG master clock msb
; > BC = PSG master clock lsb

; < DE = As entry
; < BC = As entry


nextsid_set_psg_clock_A	equ	0xF9BF
nextsid_set_psg_clock_B	equ	0xF9CA
nextsid_set_psg_clock_C	equ	0xF9D5


; --------------------------------------------------------------------------

