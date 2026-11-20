# gzip: compression (gzip, gunzip, zcat and friends).
VERSION=1.14
URL=https://ftp.gnu.org/gnu/gzip/gzip-1.14.tar.xz
SHA256=01a7b881bd220bfdf615f97b8718f80bdfd3f6add385b993dcf6efd14e8c0ac6

build() {
	configure_host
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
