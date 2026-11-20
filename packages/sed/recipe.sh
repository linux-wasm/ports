# sed: the stream editor.
VERSION=4.9
URL=https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz
SHA256=6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181

build() {
	configure_host --without-selinux --disable-acl
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
