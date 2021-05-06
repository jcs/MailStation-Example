; vim:syntax=z8a:ts=8:sw=8
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

	; these are defined in addrs-*, either of which is linked into the
	; build based on where we're running from
	.globl	RUN_ADDR
	.globl	RUN_DEVICE
	.globl	RUN_PAGE
	.globl	SLOT_ADDR
	.globl	SLOT_DEVICE
	.globl	SLOT_PAGE

	; per-firmware version port shadow variables
	.globl	p2shadow
	.globl	p3shadow
	.globl	p28shadow

	; functions
	.equ	get_keycode_from_buffer,#0x0a9a
	.equ	lcd_buf_to_screen,	#0x2473

	; lcd bit storage buffer, copied with lcd_buf_to_screen
	.equ	lcd_buf,		#0xc010
	.equ	lcd_buf_end,		#lcd_buf + ((LCD_WIDTH * LCD_HEIGHT) / 8) - 1

	.equ	LCD_WIDTH,		#160 * 2		  ; 320
	.equ	LCD_HEIGHT,		#128
	.equ	LCD_COL_GROUPS,		#20
	.equ	LCD_COL_GROUP_WIDTH,	#8
	.equ	FONT_WIDTH,		#5
	.equ	FONT_HEIGHT,		#8
	.equ	LCD_COLS,		#LCD_WIDTH / FONT_WIDTH   ; 64
	.equ	LCD_ROWS,		#LCD_HEIGHT / FONT_HEIGHT ; 16
	.equ	TEXT_ROWS,		#LCD_ROWS - 1		  ; 15

	.equ	DEVICE_RAM,		#0x01
	.equ	DEVICE_LCD_LEFT,	#0x02
	.equ	DEVICE_DATAFLASH,	#0x03
	.equ	DEVICE_LCD_RIGHT,	#0x04
	.equ	DEVICE_MODEM,		#0x05

	; addressing the LCD once it's loaded in SLOT_ADDR
	.equ	LCD_START,		#SLOT_ADDR + 0x0038

	.equ	ATTR_BIT_CURSOR,	#0
	.equ	ATTR_BIT_REVERSE,	#1
	.equ	ATTR_BIT_BOLD,		#2
	.equ	ATTR_BIT_UNDERLINE,	#3

	.equ	ATTR_CURSOR,		#(1 << ATTR_CURSOR)
	.equ	ATTR_REVERSE,		#(1 << ATTR_REVERSE)
	.equ	ATTR_BOLD,		#(1 << ATTR_BOLD)
	.equ	ATTR_UNDERLINE,		#(1 << ATTR_UNDERLINE)

	.globl	_saved_cursorx
	.globl	_saved_cursory
	.globl	_delay

	; debug variables
	.globl	_debug0
	.globl	_debug1
	.globl	_debug2
	.globl	_debug3
	.globl	_debug4
