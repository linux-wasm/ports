# ca-certificates: the certificate authorities that TLS clients trust.
# Mozilla's list, as curl's maintainers extract it; the version is the
# date of the extract.
VERSION=2026.11.05
URL=https://curl.se/ca/cacert-2026-11-05.pem
SHA256=427c064216761a1e72a8b30f0d954d08cb6e4435a82091fb865afd20c8497285

build() {
	# One bundle, under the name Debian uses and under the one OpenSSL
	# looks for by default (/etc/ssl/cert.pem).
	install -D -m 644 cacert-2026-11-05.pem \
		"$DEST/etc/ssl/certs/ca-certificates.crt"
	ln -s certs/ca-certificates.crt "$DEST/etc/ssl/cert.pem"
}
