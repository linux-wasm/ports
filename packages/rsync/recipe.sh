# rsync: fast incremental file transfer.
VERSION=3.5.2
URL=https://download.samba.org/pub/rsync/src/rsync-3.5.2.tar.gz
SHA256=a10d591825251e070f74c98df3daad195def4ed81b4a2de16169026aea33f6c8

build() {
	# Its own copies of popt and zlib; no optional compressors and
	# checksums, no assembly.
	configure_host \
		--with-included-popt --with-included-zlib \
		--disable-xxhash --disable-zstd --disable-lz4 --disable-openssl \
		--disable-simd --disable-roll-simd --disable-asm \
		--disable-acl-support --disable-xattr-support --disable-md2man \
		--disable-idn
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
