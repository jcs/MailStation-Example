/*
 * MailStation example program
 * Copyright (c) 2019-2021 joshua stein <jcs@jcs.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef _INCL_MAILSTATION
#define _INCL_MAILSTATION

#include "meta_keys.h"

/* define some ports - see 0x1b2b */
__sfr __at(0x01) portkeyboard;
__sfr __at(0x02) port2;
__sfr __at(0x05) slot4000page;
__sfr __at(0x06) slot4000device;
__sfr __at(0x07) slot8000page;
__sfr __at(0x08) slot8000device;
__sfr __at(0x09) portpowerstatus;
__sfr __at(0x0d) portcpuclockrate;
__sfr __at(0x10) rtcseconds;
__sfr __at(0x11) rtc10seconds;
__sfr __at(0x12) rtcminutes;
__sfr __at(0x13) rtc10minutes;
__sfr __at(0x14) rtchours;
__sfr __at(0x15) rtc10hours;
__sfr __at(0x16) rtcdayofweek;
__sfr __at(0x17) rtcdays;
__sfr __at(0x18) rtc10days;
__sfr __at(0x19) rtcmonths;
__sfr __at(0x1a) rtc10months;
__sfr __at(0x1b) rtcyears;
__sfr __at(0x1c) rtc10years;
__sfr __at(0x28) port28;

/* defined according to whether we're running from RAM or flash */
#ifdef LOC_RAM
#define RUN_ADDR	0x8000
#define RUN_DEVICE	0x8
#define RUN_PAGE	0x7
#define SLOT_ADDR	0x4000
#define SLOT_DEVICE	0x6
#define SLOT_PAGE	0x5
#elif defined(LOC_FLASH)
#define RUN_ADDR	0x4000
#define RUN_DEVICE	0x6
#define RUN_PAGE	0x5
#define SLOT_ADDR	0x8000
#define SLOT_DEVICE	0x8
#define SLOT_PAGE	0x7
#else
#error "no LOC_RAM or LOC_FLASH defined"
#endif

/* devices to load into slot4000device or slot8000device */
#define DEVICE_RAM		0x01
#define DEVICE_LCD_LEFT		0x02
#define DEVICE_DATAFLASH	0x03
#define DEVICE_LCD_RIGHT	0x04
#define DEVICE_MODEM		0x05

/* LCD parameters (2 screens) */
#define LCD_WIDTH		(160 * 2)	// 320
#define LCD_HEIGHT		128
#define LCD_COL_GROUPS		20
#define LCD_COL_GROUP_WIDTH	8

#define FONT_WIDTH		5
#define FONT_HEIGHT		8

/* columns of characters */
#define LCD_COLS		(LCD_WIDTH / FONT_WIDTH)	// 64
#define LCD_ROWS		(LCD_HEIGHT / FONT_HEIGHT)	// 16
#define TEXT_COLS		LCD_COLS			// 64
#define TEXT_ROWS		(LCD_ROWS - 1)			// 15

#define ATTR_CURSOR		(1 << 0)
#define ATTR_REVERSE		(1 << 1)
#define ATTR_BOLD		(1 << 2)
#define ATTR_UNDERLINE		(1 << 3)

/* for printf */
#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0')


/* for debugging access from asm */
extern unsigned char debug0;
extern unsigned char debug1;
extern unsigned char debug2;
extern unsigned char debug3;
extern unsigned char debug4;


/* crt0.s */
extern void exit(void);
extern void powerdown(void);
extern void new_mail(unsigned char on);
extern void reboot(void);
extern void delay(unsigned int millis);
extern void blink(unsigned int millis);
extern unsigned char read_port(unsigned char port);


/* putchar.s */
extern unsigned char cursorx;
extern unsigned char cursory;
extern unsigned char putchar_sgr;
extern unsigned char putchar_quick;
extern unsigned char *font_addr;
extern void screen_init(void);
extern void lcd_cas(unsigned char col);
extern void lcd_sleep(void);
extern void lcd_wake(void);
extern void uncursor(void);
extern void recursor(void);
extern void clear_screen(void);
extern void clear_screen_bufs(void);
extern void redraw_screen(void);
extern void scroll_lcd_half(void);
extern void clear_lcd_half(void);
extern void stamp_char(unsigned char row, unsigned char col);
extern void putchar_attr(unsigned char row, unsigned char col, unsigned char c,
    unsigned char attr);


/* getchar.s */
extern unsigned char getscancode(unsigned char *charbuffer);
extern int getkey(void);
extern int peekkey(void);


/* wifi.s */
void wifi_init(void);
extern int wifi_write(char);
extern int wifi_read(void);

#endif
