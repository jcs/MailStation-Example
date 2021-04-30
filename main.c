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

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "lib/mailstation.h"

unsigned char lastkey;

void process_keyboard(void);
void process_input(unsigned char b);

int
main(void)
{
	/* ignore first peekkey() if it returns power button */
	lastkey = KEY_POWER;

	clear_screen_bufs();
	clear_screen();

	wifi_init();

	printf("Hello, World\n");

	for (;;) {
		process_keyboard();
	}
}

void
process_keyboard(void)
{
	unsigned char b;

	b = peekkey();

	/* this breaks key-repeat, but it's needed to debounce */
	if (b == 0)
		lastkey = 0;
	else if (b == lastkey)
		b = 0;
	else
		lastkey = b;

	if (b == 0)
		return;

	switch (b) {
	case KEY_POWER:
#if 0
		/* XXX: this triggers erroneously */
		powerdown_mode();
#endif
		break;
	case KEY_F1:
		break;
	case KEY_MAIN_MENU:
		break;
	case KEY_PAGE_UP:
		break;
	case KEY_PAGE_DOWN:
		break;
	case KEY_UP:
		break;
	case KEY_DOWN:
		break;
	case KEY_LEFT:
		break;
	case KEY_RIGHT:
		break;
	case KEY_SIZE:
		break;
	default:
		putchar(b);
	}
}