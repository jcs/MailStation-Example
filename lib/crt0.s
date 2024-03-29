; vim:syntax=z8a:ts=8
;
; MailStation example program
; Copyright (c) 2019-2021 joshua stein <jcs@jcs.org>
;
; Permission to use, copy, modify, and distribute this software for any
; purpose with or without fee is hereby granted, provided that the above
; copyright notice and this permission notice appear in all copies.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;

        .module crt0

	.include "mailstation.inc"
	.globl	_main
	.globl	l__INITIALIZER
	.globl	s__INITIALIZER
	.globl	s__INITIALIZED

	.area	_HEADER (ABS)

	.org 	RUN_ADDR
start:
	jp	boot

	.dw	(icons)
	.dw	(caption)
	.dw	(dunno)

dunno:
	.db	#0
xpos:
	.dw	#0
ypos:
	.dw	#0
caption:
	.dw	#0x0001			; ?
	.dw	(endcap - caption - 6)	; number of chars
	.dw	#0x0006			; offset to first char
	.ascii	"Example"		; the caption string
endcap:

icons:
	.dw	(icon2 - icon1)		; size of icon1
	.dw	(icon1 - icons)		; offset to icon1
	.dw	(iconend - icon2)	; size of icon2
	.dw	(icon2 - icons)		; offset to icon2

icon1:
	.dw	#0x0022			; icon width (34, 5 bytes per row)
	.db	#0x22			; icon height (34)

	.db	#0x00, #0x00, #0x00, #0x00, #0x00	; ..................................
	.db	#0x00, #0x00, #0x00, #0x00, #0x00	; ..................................
	.db	#0x00, #0xc0, #0x0f, #0x00, #0x00	; ..............######..............
	.db	#0x00, #0x30, #0x30, #0x00, #0x00	; ............##......##............
	.db	#0x00, #0x0c, #0xc0, #0x00, #0x00	; ..........##..........##..........
	.db	#0x00, #0x02, #0x00, #0x01, #0x00	; .........#..............#.........
	.db	#0x00, #0x01, #0x00, #0x02, #0x00	; ........#................#........
	.db	#0x80, #0x00, #0x00, #0x04, #0x00	; .......#..................#.......
	.db	#0x40, #0x00, #0x00, #0x08, #0x00	; ......#....................#......
	.db	#0x20, #0x00, #0x00, #0x10, #0x00	; .....#......................#.....
	.db	#0x10, #0x00, #0x00, #0x20, #0x00	; ....#........................#....
	.db	#0x10, #0x00, #0x00, #0x20, #0x00	; ....#........................#....
	.db	#0x08, #0x30, #0x30, #0x40, #0x00	; ...#........##......##........#...
	.db	#0x08, #0x78, #0x78, #0x40, #0x00	; ...#.......####....####.......#...
	.db	#0x08, #0x78, #0x78, #0x40, #0x00	; ...#.......####....####.......#...
	.db	#0x04, #0x30, #0x30, #0x80, #0x00	; ..#.........##......##.........#..
	.db	#0x04, #0x00, #0x00, #0x80, #0x00	; ..#............................#..
	.db	#0x04, #0x00, #0x00, #0x80, #0x00	; ..#............................#..
	.db	#0x04, #0x00, #0x00, #0x80, #0x00	; ..#............................#..
	.db	#0x08, #0x00, #0x00, #0x40, #0x00	; ...#..........................#...
	.db	#0x08, #0x00, #0x00, #0x40, #0x00	; ...#..........................#...
	.db	#0x08, #0x04, #0x80, #0x40, #0x00	; ...#......#............#......#...
	.db	#0x10, #0x04, #0x80, #0x20, #0x00	; ....#.....#............#.....#....
	.db	#0x10, #0x08, #0x40, #0x20, #0x00	; ....#......#..........#......#....
	.db	#0x20, #0x70, #0x38, #0x10, #0x00	; .....#......###....###......#.....
	.db	#0x40, #0x80, #0x07, #0x08, #0x00	; ......#........####........#......
	.db	#0x80, #0x00, #0x00, #0x04, #0x00	; .......#..................#.......
	.db	#0x00, #0x01, #0x00, #0x02, #0x00	; ........#................#........
	.db	#0x00, #0x02, #0x00, #0x01, #0x00	; .........#..............#.........
	.db	#0x00, #0x0c, #0xc0, #0x00, #0x00	; ..........##..........##..........
	.db	#0x00, #0x30, #0x30, #0x00, #0x00	; ............##......##............
	.db	#0x00, #0xc0, #0x0f, #0x00, #0x00	; ..............######..............
	.db	#0x00, #0x00, #0x00, #0x00, #0x00	; ..................................
	.db	#0x00, #0x00, #0x00, #0x00, #0x00	; ..................................

icon2:
	; not used
	.dw	#0x0000			; width
	.db	#0x00			; height
iconend:

boot:
	xor	a
	out	(#0x0d), a		; put the cpu in its highest speed

	; all of our code expects to run in ram so when we're running from
	; dataflash, we have to copy our page of flash into ram, then jump to
	; it

	; swap in a page of ram
	ld	a, #DEVICE_RAM
	out	(#SLOT_DEVICE), a
	out	(#SLOT_PAGE), a

	; copy ourselves into ram
	ld	de, #SLOT_ADDR
	ld	hl, #RUN_ADDR
	ld	bc, #0x4000
	ldir				; ld (de), (hl), de++, hl++, bc--

	jp	SLOT_ADDR + (hijump - start)

hijump:
	; PC is now in SLOT_ADDR, put our new RAM page into RUN_DEVICE/PAGE
	out	(#RUN_DEVICE), a
	out	(#RUN_PAGE), a

	; then jump back there
	jp	RUN_ADDR + (lojump - start)

lojump:
	call	gsinit
	call	find_shadows
	call	_main			; main c code
	jp	_exit


	.area	_DATA

; shadow locations
p2shadow:
	.dw	#0xdba2
p3shadow:
	.dw	#0xdba3
p28shadow:
	.dw	#0xdba0
delay_func:
	jp	0x0a5c

_debug0::
	.db	#0
_debug1::
	.db	#0
_debug2::
	.db	#0
_debug3::
	.db	#0
_debug4::
	.db	#0


	.area   _GSINIT
gsinit:
	ld	bc, #l__INITIALIZER
	ld	a, b
	or	a, c
	jr	z, gsinit_next
	ld	de, #s__INITIALIZED
	ld	hl, #s__INITIALIZER
	ldir
gsinit_next:

	.area   _GSFINAL
	ret


        .area   _CODE

; set location of port shadow variables depending on firmware version
find_shadows:
	ld	a, (#0x0037)		; firmware major version
	cp	#0x1
	jr	z, ver_1
	cp	#0x2
	jr	z, ver_2
	cp	#0x3
	jr	z, ver_3
unrecognized_firmware:			; we can't blink because that requires
	jp	0x0			; port and fw function addresses
ver_1:
	ld	a, (#0x0036)		; firmware minor version
	cp	#0x73
	jr	z, ver_1_73
	jr	unrecognized_firmware
ver_1_73:				; eMessage 1.73CID
	ld	hl, #p2shadow
	ld	(hl), #0xdb9f
	ld	hl, #p3shadow
	ld	(hl), #0xdba0		; TODO: verify
	ret
ver_2:
	ld	a, (#0x0036)		; firmware minor version
	cp	#0x54
	jr	z, ver_2_54
	jr	unrecognized_firmware
ver_2_54:				; MailStation 2.54
	ld	hl, #p2shadow
	ld	(hl), #0xdba2
	ld	hl, #p3shadow
	ld	(hl), #0xdba3
	ld	hl, #p28shadow
	ld	(hl), #0xdba0
	ret
ver_3:
	ld	a, (#0x0036)		; firmware minor version
	cp	#0x0d3
	jr	z, ver_3_03
	jr	unrecognized_firmware
ver_3_03:				; MailStation 3.03
	ld	hl, #p2shadow
	ld	(hl), #0xdba5
	ld	hl, #p3shadow
	ld	(hl), #0xdba6
	ret

; exit handler, restart
_exit::
	call	_reboot

_powerdown::
	; TODO: figure out what else needs to be set before shutting down to
	; prevent it going to the "Reset System Data" screen on next startup
	ld	hl, (#p28shadow)
	ld	a, (hl)
	set	1, a			; 74c74 pin4
	set	0, a			; modem reset
	ld	(hl), a
	di
	out	(#0x28), a
	halt
	ret

_reboot::
	jp	0x0000

; new_mail(unsigned char on)
; toggles 'new mail' light
_new_mail::
	di
	push	ix
	ld	ix, #0
	add	ix, sp
	push	hl
	push	af
	ld	a, 4(ix)
	cp	#0
	ld	hl, (p2shadow)
	jr	z, light_off
light_on:
	ld	a, (hl)
	set	4, a
	jr	write_p2
light_off:
	ld	a, (hl)
	res	4, a
write_p2:
	ld	(hl), a
	out	(#0x02), a		; write p2shadow to port2
	pop	af
	pop	hl
	pop	ix
	ei
	ret

; delay(unsigned int millis)
; call mailstation function that delays (stack) milliseconds
_delay::
	push	ix
	ld	ix, #0
	add	ix, sp
	push	af
	push	bc
	push	hl
	ld	l, 4(ix)
	ld	h, 5(ix)
	push	hl
	call	delay_func
	pop	hl
	pop	hl
	pop	bc
	pop	af
	pop	ix
	ret

; blink(unsigned int millis)
; turn new mail LED on, wait millis, turn it off, wait millis
_blink::
	push	ix
	ld	ix, #0
	add	ix, sp
	push	hl
	ld	l, #1
	push	hl
	call	_new_mail		; turn it on
	pop	hl
	ld	l, 4(ix)
	ld	h, 5(ix)
	push	hl
	call	_delay			; wait
	pop	hl
	ld	l, #0
	push	hl
	call	_new_mail		; turn it off
	pop	hl
	ld	l, 4(ix)
	ld	h, 5(ix)
	push	hl
	call	_delay			; wait
	pop	hl
	pop	af
	pop	ix
	ret

; void lcd_sleep(void)
; turn the LCD off
_lcd_sleep::
	di
	push	hl
	ld	hl, (p2shadow)
	ld	a, (hl)
	and	#0b01111111		; LCD_ON - turn port2 bit 7 off
	ld	(hl), a
	out	(#0x02), a		; write p2shadow to port2
	pop	hl
	ei
	ret


; void lcd_wake(void)
; turn the LCD on
_lcd_wake::
	di
	push	hl
	ld	hl, (p2shadow)
	ld	a, (hl)
	or	#0b10000000		; LCD_ON - turn port2 bit 7 on
	ld	(hl), a
	out	(#0x02), a		; write p2shadow to port2
	pop	hl
	ei
	ret

; unsigned char read_port(unsigned char port)
; return a byte read from a port
_read_port::
	push	ix
	ld	ix, #0
	add	ix, sp
	push	af
	push	bc
	ld	b, #0
	ld	c, 4(ix)
	in	l, (C)
	ld	h, #0
	pop	bc
	pop	af
	pop	ix
	ret


; 8-bit multiplication
; de * a = hl
mult8::
	ld	b, #8
	ld	hl, #0
mult8_loop:
	add	hl, hl
	rlca
	jr	nc, mult8_noadd
	add	hl, de
mult8_noadd:
	djnz	mult8_loop
mult8_out:
	ret

; 16-bit multiplication
; bc * de = hl
mult16:
	ld	a, b
	ld	b, #16
	ld	hl, #0
mult16_loop:
	add	hl, hl
	sla	c
	rla
	jr	nc, mult16_noadd
	add	hl, de
mult16_noadd:
	djnz	mult16_loop
	ret


; 8-bit division
; divide e by c, store result in a and remainder in b
div8:
	xor	a
	ld	b, #8
div8_loop:
	rl	e
	rla
	sub	c
	jr	nc, div8_noadd
	add	a, c
div8_noadd:
	djnz	div8_loop
	ld	b,a
	ld	a,e
	rla
	cpl
	ret

; 16-bit division
; divide bc by de, store result in bc, remainder in hl
div16:
	ld	hl, #0
	ld	a, b
	ld	b, #8
div16_loop1:
	rla
	adc	hl, hl
	sbc	hl, de
	jr	nc, div16_noadd1
	add	hl, de
div16_noadd1:
	djnz	div16_loop1
	rla
	cpl
	ld	b, a
	ld	a, c
	ld	c, b
	ld	b, #8
div16_loop2:
	rla
	adc	hl, hl
	sbc	hl, de
	jr	nc, div16_noadd2
	add	hl, de
div16_noadd2:
	djnz	div16_loop2
	rla
	cpl
	ld	b, c
	ld	c, a
	ret
