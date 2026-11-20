# zlib: the compression library (needed by openssl, curl, openssh).
VERSION=1.4
URL=https://github.com/madler/zlib/releases/download/v1.4/zlib-1.4.tar.xz
SHA256=4f11c512053d7bab8d9e9b89bde3575add3e4c50a383b42ef6cb837035fc5a7c

build() {
	# Its configure is not autoconf: it takes the compiler from CC and
	# has no --host.
	WASM_CC_NO_ASYNCIFY=1 ./configure --prefix=/usr --static
	make -j"$JOBS" libz.a
	make install DESTDIR="$DEST"
}
