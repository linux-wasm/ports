# openssh: the clients: ssh, scp, sftp, ssh-keygen, ssh-add, ssh-agent.
VERSION=10.6p2
URL=https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p2.tar.gz
SHA256=9ae44872090cf2f06b3cf9ff147e7f16f309671340763ed2f99248398ae29d5b

build() {
	# No PAM, no login records, none of the compiler hardening that
	# assumes an ELF target.
	configure_host \
		--sysconfdir=/etc/ssh --with-privsep-path=/var/empty \
		--with-ssl-dir="$STAGE/usr" --with-zlib="$STAGE/usr" \
		--without-pam --without-stackprotect --without-hardening \
		--without-pie --disable-strip --disable-utmp --disable-utmpx \
		--disable-wtmp --disable-wtmpx --disable-lastlog \
		--with-default-path=/usr/sbin:/usr/bin:/sbin:/bin
	make -j"$JOBS"
	# Without host keys: they are made on the system, not shipped.
	make install-nokeys DESTDIR="$DEST"
	# Clients only. Nothing can connect to this system from outside, so
	# the server would only take room, and room is what static linking
	# costs: every one of these programs carries its own OpenSSL (5 MB).
	# The helpers are for hardware keys and host-based authentication.
	rm -rf "$DEST/usr/sbin" "$DEST/usr/libexec" "$DEST/var" \
		"$DEST/etc/ssh/sshd_config" "$DEST/etc/ssh/moduli" \
		"$DEST/usr/bin/ssh-keyscan"
}
