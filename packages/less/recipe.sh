# less: the pager (uses ncurses for the terminal description).
VERSION=668
URL=https://ftp.gnu.org/gnu/less/less-668.tar.gz
SHA256=2819f55564d86d542abbecafd82ff61e819a3eec967faa36cd3e68f1596a44b8

build() {
	configure_host --with-regex=posix
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
