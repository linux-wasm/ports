# coreutils: the GNU file, shell and text utilities.
VERSION=9.8
URL=https://ftp.gnu.org/gnu/coreutils/coreutils-9.8.tar.xz
SHA256=e6d4fd2d852c9141a1c2a18a13d146a0cd7e45195f72293a4e4c044ec6ccca15

build() {
	# One program with a symlink per utility: without shared libraries
	# every utility would carry its own copy of libc and gnulib.
	# Left out: stdbuf needs a shared library to preload; chcon and runcon
	# are for SELinux; kill and uptime come from elsewhere on a normal
	# system (here: BusyBox).
	configure_host \
		--enable-single-binary=symlinks \
		--enable-no-install-program=stdbuf,chcon,runcon,kill,uptime \
		--without-selinux --without-libgmp --without-openssl \
		--disable-acl --disable-xattr --disable-libcap
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
