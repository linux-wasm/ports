# gawk: the GNU awk.
VERSION=5.3.2
URL=https://ftp.gnu.org/gnu/gawk/gawk-5.3.2.tar.xz
SHA256=f8c3486509de705192138b00ef2c00bbbdd0e84c30d5c07d23fc73a9dc4cc9cc

build() {
	# Extensions are shared libraries, and there is no dynamic loader.
	configure_host --disable-extensions --disable-mpfr --without-readline
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
