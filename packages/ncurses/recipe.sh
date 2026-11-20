# ncurses: terminal handling (libncurses, the terminfo database, tput).
VERSION=6.5
URL=https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz
SHA256=136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6

# The terminals worth describing on a machine whose only terminals are
# xterm.js in a browser and whatever a later ssh or tmux brings along.
TERMINALS="ansi dumb linux screen screen-256color tmux tmux-256color vt100 vt220 xterm xterm-256color xterm-color"

build() {
	# One wide-character library under the plain name, static only.
	# The database is compiled by the build machine's tic (same version).
	configure_host \
		--without-shared --without-debug --without-ada --without-cxx \
		--without-cxx-binding --without-manpages --without-tests \
		--without-gpm --enable-widec --disable-lib-suffixes \
		--enable-overwrite --disable-stripping --enable-pc-files=no \
		--with-default-terminfo-dir=/usr/share/terminfo \
		--with-terminfo-dirs=/usr/share/terminfo \
		--with-fallbacks=xterm-256color,xterm,linux,vt100 \
		--with-build-cc=gcc --with-build-cflags= --with-build-cppflags= \
		--with-build-ldflags=
	make -j"$JOBS"
	make install DESTDIR="$DEST"

	# Keep only the listed terminal descriptions.
	db="$DEST/usr/share/terminfo"
	mv "$db" "$db.all"
	for term in $TERMINALS; do
		dir="$(printf %.1s "$term")"
		mkdir -p "$db/$dir"
		cp -P "$db.all/$dir/$term" "$db/$dir/"
	done
	rm -rf "$db.all" "$DEST/usr/lib/terminfo"

	# Programs ask for libcurses and libtinfo too.
	ln -sf libncurses.a "$DEST/usr/lib/libcurses.a"
	ln -sf libncurses.a "$DEST/usr/lib/libtinfo.a"
}
