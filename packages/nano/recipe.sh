# nano: a small editor (a curses program).
VERSION=8.6
URL=https://ftp.gnu.org/gnu/nano/nano-8.6.tar.xz
SHA256=f7abfbf0eed5f573ab51bd77a458f32d82f9859c55e9689f819d96fe1437a619

build() {
	# The wide-character ncurses is installed under the plain name.
	NCURSESW_CFLAGS=" " NCURSESW_LIBS="-lncurses" \
	configure_host --enable-utf8 --disable-libmagic --disable-speller
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
