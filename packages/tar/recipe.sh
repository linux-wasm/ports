# tar: the GNU archiver.
VERSION=1.35
URL=https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz
SHA256=4d62ff37342ec7aed748535323930c7cf94acf71c3591882b26a7ea50f3edc16

build() {
	configure_host --without-selinux --without-posix-acls --without-xattrs
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
