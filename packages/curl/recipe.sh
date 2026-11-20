# curl: transfers with URLs (HTTP, HTTPS, FTP, ...), and libcurl.
VERSION=8.23.0
URL=https://curl.se/download/curl-8.23.0.tar.xz
SHA256=8dadd7d2536a314f982ad05a651b713f426bf7d02cc2c76cffb9796f2218e6c5

build() {
	configure_host \
		--disable-shared --with-openssl="$STAGE/usr" --with-zlib="$STAGE/usr" \
		--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
		--without-libpsl --without-brotli --without-zstd \
		--without-nghttp2 --without-libidn2 --without-librtmp \
		--disable-ldap --disable-docs
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
