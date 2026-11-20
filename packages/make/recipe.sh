# make: GNU make.
VERSION=4.4.1
URL=https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
SHA256=dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3

build() {
	configure_host --without-guile
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
