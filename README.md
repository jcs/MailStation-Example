# MailStation Example Program

This is an example program to get you started writing code for the
[Cidco MailStation](https://jcs.org/2019/05/03/mailstation)
Z80 computer.

The code in `lib/` sets up the C run-time (`crt0`) and gives you a `putchar`
routine that draws on the screen with a 5x8 font.

`main()` prints "Hello, World" and then loops forever echoing any keys typed on
the keyboard out to the screen.
This is where your code should go to do something more useful.

## Building

Install
[SDCC](http://sdcc.sourceforge.net/),
Ruby,
and if on a non-BSD platform, a BSD Make (bmake).

Once installed, issue `make` (or `bmake`):

	$ make obj
	$ make

This will produce a file `obj/hello.bin` for uploading to the MailStation.

By default, the linker sets up the program to be running from RAM (loaded via
[WSLoader](https://jcs.org/wifistation/loader)) at `0x4000`.
If loading to Data Flash, set `LOC` to `flash` (and clean first):

	$ make LOC=flash clean all

## Running

Run Loader/WSLoader on the MailStation and then upload `obj/hello.bin` to it
via a parallel LapLink cable or a
[WiFiStation](https://jcs.org/wifistation).

## Extending

If your code extends beyond `main.c`, add your source `.c` files to the `SRCS`
variable in `Makefile`, and any assembly files to `ASM_SRCS`.

You'll probably also want to change the `PROG` variable to be something
meaningful.

## License (ISC)

Copyright (c) 2019-2021 joshua stein <jcs@jcs.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
