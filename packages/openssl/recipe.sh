# openssl: TLS and cryptography (libssl, libcrypto, the openssl program).
VERSION=3.5.9
URL=https://github.com/openssl/openssl/releases/download/openssl-3.5.9/openssl-3.5.9.tar.gz
SHA256=603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a

build() {
	# linux-generic32: C only, 32-bit, little endian is detected.
	# Left out: assembly (there is none for wasm), everything that loads
	# code at run time (no dynamic loader), async (it switches stacks
	# with makecontext, which wasm cannot do), and the tests.
	WASM_CC_NO_ASYNCIFY=1 ./Configure linux-generic32 \
		--prefix=/usr --libdir=lib --openssldir=/etc/ssl \
		no-shared no-asm no-dso no-module no-engine no-async \
		no-afalgeng no-tests no-docs \
		-I"$STAGE/usr/include" -L"$STAGE/usr/lib"
	make -j"$JOBS"
	make install_sw install_ssldirs DESTDIR="$DEST"
}
