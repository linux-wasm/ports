# grep: search files for lines matching a pattern.
VERSION=3.12
URL=https://ftp.gnu.org/gnu/grep/grep-3.12.tar.xz
SHA256=2649b27c0e90e632eadcd757be06c6e9a4f48d941de51e7c0f83ff76408a07b9

build() {
	configure_host --disable-perl-regexp
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
