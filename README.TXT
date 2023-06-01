
*************************************************
**THE FOLLOWING CODE AND APPS ARE PUBLIC DOMAIN**
*************************************************

June 27th 2021, NextSID version v0.5b



The sourcecode builds NEXTSID.SNX, the original test shell with a raster
change applied to SID B channel.

**KEYS 0 1 2 3 4 5 6 M H Z X SPACE ENTER** see MAIN/TEST.ASM



NEXTSID.INC is the include file for the following v0.5b bins;

VOL-SID.BIN - 4096 BYTES ORG 32768 $8000 **KEEP IN THIS ORDER**
NEXTSID.BIN - 4096 BYTES ORG 36864 $9000 **KEEP IN THIS ORDER**

CTC-SID.BIN - 1152 BYTES ORG 63232 $F700 **DO NOT BANK OUT**


The waveform pattern data is now in the range of 1-128 using a 4K table
(VOL-SID.BIN) to scale the volume. A duty cycle value of 0 will cause the
engine to calculate undefined results and > 128 will clip.

Changing the table will change the tone of NextSID's signature sound!

NextSID uses around 9-15% CPU @ 28Mhz depending on PT3/channel allocation.



All of the API functions are within CTC-SID.BIN so you don't need to bank
in the main core as the API handles the banking and restores the MMU on exit.

CTC-SID.BIN can sit in any MM7 bank8k as long as it is never banked out while
interrupts are enabled. The default would be bank8k 1.

Set the 8K core bank when you call nextsid_reset. The core can be any bank8k
within the SRAM other than bank8k 1, as it would over-write the API lol.
Note, the original init routine has been renamed to nextsid_reset and DE
now accepts -1 to use the internal vsync.

	ld	de,-1		; LINE (-1 = use NextSID)
	ld	bc,192		; Vsync line
	ld	a,4		; NextSID bank8k core
	call	nextsid_reset	; Init sound engine


16K is allocated for the PT3 file. The bank8ks can be anywhere in the SRAM
and also out of order. The interrupt uses MMU5 and MMU6 to bank in the PT3
during init and play, but you don't need to worry as it is all done for you
by the API.

DE should be set to the offset within the 16K, NOT an absolute ORG!

	ld	de,0		; PT3 offset within the 16K
	ld	l,5		; Bank8k a 1st 8K
	ld	h,0		; Bank8k b 2nd 8K
	call	nextsid_set_pt3	; Stops playback to init new song
	call	nextsid_play	; Start playback


The player API will handle waveform patterns of 1-32. 0 is illegal and > 32
will cause a buffer overflow and wipe code/data.

The waveform size is now the actual size of the pattern and NOT -1 as before.

A note about the waveform buffers. They may be banked out depending on your
a and b banking configuration for the PT3 song data. It is okay to store the
waveform patterns in the same bank8ks you defined for your PT3 song data
(if there is enough room). Ask me if you need help!

	ld	hl,test_waveform
	ld	a,8
	call	nextsid_set_waveform_A
	call	nextsid_set_waveform_B
	call	nextsid_set_waveform_C

The shift BYTE is same as previous, 3 is default.

	ld	a,3
	ld	(nextsid_shift_B),a

The Detune WORD is a signed 16-bit value per channal as before.

	ld	hl,0
	ld	(nextsid_detune_B),hl

nextsid_mode control BYTE has changed...

bit    7 is PLAY/STOP (stop acts as pause)
bits 6-4 are for PSG C,B,A enable (0 will mute the channel)
bits 2-0 are for SID C,B,A enable BUT you must also set the master PSG bit

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

	ld	a,PSG_ABC+SID_B	; Enable PSG ABC + SID for channel B
	ld	(nextsid_mode),a


The following API functions are provided to set the PSG clock and waveform
pointer/size;

nextsid_set_psg_clock_A
nextsid_set_psg_clock_B
nextsid_set_psg_clock_C

nextsid_set_waveform_A
nextsid_set_waveform_B
nextsid_set_waveform_C


This is because direct write access to the variables could result in out of
order reads by the timer code.

You could wrap your own code with DI/EI if you prefer to write directly to
the follow sets of variables. Reading the variables does not require DI/EI.

nextsid_set_waveform_A:

	di
	ld	(nextsid_wavelen_A),a
	ld	(nextsid_waveptr_A),hl
	ei
	ret

nextsid_set_psg_clock_A:

	di
	ld	(nextsid_psg_clock_msb_A),de
	ld	(nextsid_psg_clock_lsb_A),bc
	ei
	ret


The RAW AY registers from VT1-MFX are at the following address;

ayregs	equ	0xF7D7	; 14 BYTES VT1-MFX AY registers


See ASM\TEST.ASM for example code.


Two last notes... the timer code uses a table to patch instructions, so
changes may be a headache to apply. Some code and data is 256 BYTE aligned.



I have provided an updated demo app using the reference v0.5b player code;

NextSIDi (v0.5b).NEX

Various improvements to scopes, duty cycle edit, detune middle mouse button
reset 0 and other fixes. Use left/right mouse buttons/cursor keys to operate.
Ships with 19 built-in PT3 files. Will gain a file browser at some point ;)

Allows waveform patterns of 2,3,4,5,6,7,8,12,16,32. Odd pattern sizes will
produce some funky harmonics!

Compatible with 1MB ZX Spectrum Nexts.



Finally, a massive thank you to em00k for inspiring me to create this fun
project and respect to the developers of the VT1-MFX player and the composers
of the PT3 tracks :)
I would also like to thank Allen for adding CTC timers to Spectrum Next core.


9bitcolor, June 2021

