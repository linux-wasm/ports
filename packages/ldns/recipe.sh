# ldns: a DNS library, packaged for drill, its dig-like lookup tool.
# (dig itself is part of BIND, which is a far larger port.)
VERSION=1.9.2
URL=https://www.nlnetlabs.nl/downloads/ldns/ldns-1.9.2.tar.gz
SHA256=b524fa21994b6e834200ceb8c27f1b84bda5982fe35706f058196c079db94d5d

build() {
	# GOST signatures need an OpenSSL engine, and engines are loaded at
	# run time. The two cache variables: tests that would run a program; without
	# the answers configure substitutes its own malloc.
	ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes \
	configure_host \
		--disable-shared --with-ssl="$STAGE/usr" --with-drill \
		--without-pyldns --disable-dane-verify --disable-gost \
		--with-ca-file=/etc/ssl/certs/ca-certificates.crt
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
