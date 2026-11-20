# busybox: init, /bin/sh (ash) and small versions of the usual commands.
# What it installs is decided by the file "config" next to this recipe.
VERSION=1.38.0
URL=https://busybox.net/downloads/busybox-1.38.0.tar.bz2
SHA256=34f9ea6ff8636f2c9241153b9114eefa9e65674a45318ae1ef95bb5f31c53bb2

build() {
	bb_make() {
		make CC=wasm-cc HOSTCC=gcc AR=llvm-ar NM=llvm-nm STRIP=true \
			SKIP_STRIP=y "$@"
	}

	bb_make allnoconfig > /dev/null
	grep -v '^#' /ports/packages/busybox/config | while read -r opt; do
		[ -n "$opt" ] || continue
		grep -q "^# CONFIG_$opt is not set" .config ||
			{ echo "busybox/config: unknown option $opt" >&2; exit 1; }
		sed -i "s/^# CONFIG_$opt is not set/CONFIG_$opt=y/" .config
	done
	# /bin/sh is ash (a choice, which allnoconfig leaves at "none").
	sed -i 's/^CONFIG_SH_IS_NONE=y/CONFIG_SH_IS_ASH=y/' .config
	# Where BusyBox finds itself to run an applet as a new process; the
	# default, /proc/self/exe, needs /proc to be mounted.
	sed -i 's|^CONFIG_BUSYBOX_EXEC_PATH=.*|CONFIG_BUSYBOX_EXEC_PATH="/bin/busybox"|' .config
	yes "" | bb_make oldconfig > /dev/null

	bb_make -j"$JOBS"
	# /bin/busybox and a symlink per applet, where each applet belongs
	# (/bin, /sbin, /usr/bin, /usr/sbin).
	bb_make install CONFIG_PREFIX="$DEST"
}
