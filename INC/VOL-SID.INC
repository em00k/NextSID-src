
; --------------------------------------------------------------------------
;
;
;    ********************************************************************
;    *                                                                  *
;    * File:        VOL-SID.INC                                         *
;    * Format:      SjASMPlus Z80                                       *
;    * Tabs:        28,36,44,52,60,68,76,84                             *
;    *                                                                  *
;    * Project:     NextSID                                             *
;    * Platform:    ZX Spectrum Next                                    *
;    * Programmer:  KevB aka 9bitcolor                                  *
;    *                                                                  *
;    * Modified:    27th June 2021                                      *
;    *                                                                  *
;    * Description: NextSID volume prescale table.                      *
;    *                                                                  *
;    ********************************************************************
;
;
; --------------------------------------------------------------------------


; **MUST BE 256 BYTE ALIGNED**


nextsid_prescale_tab	db	0	; 0
	ds	128,0
	ds	127,0

	db	0	; 1
	ds	64,0
	ds	64,1
	ds	127,1

	db	0	; 2
	ds	43,0
	ds	42,1
	ds	43,2
	ds	127,2

	db	0	; 3
	ds	32,0
	ds	32,1
	ds	32,2
	ds	32,3
	ds	127,3

	db	0	; 4
	ds	26,0
	ds	25,1
	ds	26,2
	ds	25,3
	ds	26,4
	ds	127,4

	db	0	; 5
	ds	21,0
	ds	22,1
	ds	21,2
	ds	21,3
	ds	22,4
	ds	21,5
	ds	127,5

	db	0	; 6
	ds	18,0
	ds	19,1
	ds	18,2
	ds	18,3
	ds	18,4
	ds	19,5
	ds	18,6
	ds	127,6

	db	0	; 7
	ds	16,0
	ds	16,1
	ds	16,2
	ds	16,3
	ds	16,4
	ds	16,5
	ds	16,6
	ds	16,7
	ds	127,7

	db	0	; 8
	ds	14,0
	ds	14,1
	ds	15,2
	ds	14,3
	ds	14,4
	ds	14,5
	ds	15,6
	ds	14,7
	ds	14,8
	ds	127,8

	db	0	; 9
	ds	13,0
	ds	13,1
	ds	12,2
	ds	13,3
	ds	13,4
	ds	13,5
	ds	13,6
	ds	12,7
	ds	13,8
	ds	13,9
	ds	127,9

	db	0	; 10
	ds	12,0
	ds	11,1
	ds	12,2
	ds	12,3
	ds	11,4
	ds	12,5
	ds	11,6
	ds	12,7
	ds	12,8
	ds	11,9
	ds	12,10
	ds	127,10

	db	0	; 11
	ds	11,0
	ds	10,1
	ds	11,2
	ds	11,3
	ds	10,4
	ds	11,5
	ds	11,6
	ds	10,7
	ds	11,8
	ds	11,9
	ds	10,10
	ds	11,11
	ds	127,11

	db	0	; 12
	ds	10,0
	ds	10,1
	ds	10,2
	ds	 9,3
	ds	10,4
	ds	10,5
	ds	10,6
	ds	10,7
	ds	10,8
	ds	 9,9
	ds	10,10
	ds	10,11
	ds	10,12
	ds	127,12

	db	 0	; 13
	ds	 9,0
	ds	 9,1
	ds	 9,2
	ds	10,3
	ds	 9,4
	ds	 9,5
	ds	 9,6
	ds	 9,7
	ds	 9,8
	ds	 9,9
	ds	10,10
	ds	 9,11
	ds	 9,12
	ds	 9,13
	ds	127,13

	db	 0	; 14
	ds	 9,0
	ds	 8,1
	ds	 9,2
	ds	 8,3
	ds	 9,4
	ds	 8,5
	ds	 9,6
	ds	 8,7
	ds	 9,8
	ds	 8,9
	ds	 9,10
	ds	 8,11
	ds	 9,12
	ds	 8,13
	ds	 9,14
	ds	127,14

	db	 0	; 15
	ds	 8,0
	ds	 8,1
	ds	 8,2
	ds	 8,3
	ds	 8,4
	ds	 8,5
	ds	 8,6
	ds	 8,7
	ds	 8,8
	ds	 8,0
	ds	 8,10
	ds	 8,11
	ds	 8,12
	ds	 8,13
	ds	 8,14
	ds	 8,15
	ds	127,15


; --------------------------------------------------------------------------

