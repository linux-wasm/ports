# findutils: find, xargs, locate.
VERSION=4.10.0
URL=https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz
SHA256=1387e0b67ff247d2abde998f90dfbf70c1491391a59ddfecb8ae698789f0a4f5

build() {
	configure_host --without-selinux
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
