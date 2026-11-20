# Runs inside the toolchain container: build one package.
#
#   build-package.sh <name> <source archive in /pwork/src>
#
# Directories:
#   /ports         this repository (read-only)
#   /pwork/build/<name>/   the unpacked, patched source: the build tree
#   /pwork/dest/<name>/    what "make install" produced (DESTDIR)
#   /pwork/stage/          headers and libraries of all built packages,
#                          for the packages that depend on them
#   /pwork/out/            the packages
#
# What a recipe can use is described in README.md.
name="$1"
archive="/pwork/src/$2"

export PATH="/toolchain:/usr/lib/llvm-19/bin:$PATH"
STAGE=/pwork/stage
DEST="/pwork/dest/$name"
SRC="/pwork/build/$name"
JOBS="$(nproc)"

# The machine the packages are for, as configure scripts name it.
HOST=wasm32-unknown-linux-musl

export CC=wasm-cc
export AR=llvm-ar RANLIB=llvm-ranlib NM=llvm-nm STRIP=true
export CC_FOR_BUILD=gcc BUILD_CC=gcc
export CFLAGS="-O2"
export CPPFLAGS="-I$STAGE/usr/include"
export LDFLAGS="-L$STAGE/usr/lib"

# configure for this machine, installing below /usr. Programs that
# configure links to see whether they link are not run through wasm-opt.
#
# gnulib looks the direction of stack growth up in a list of CPUs and
# cannot find it out by running a program: the stack in linear memory
# (the only one a program can see) grows down.
configure_host() {
	sv_cv_stack_direction=-1 sv_cv_stack_direction_msg="grows down" \
	WASM_CC_NO_ASYNCIFY=1 "${CONFIGURE:-./configure}" \
		--host="$HOST" --build="$(gcc -dumpmachine)" \
		--prefix=/usr --sysconfdir=/etc --localstatedir=/var \
		--disable-nls "$@"
}

. "/ports/packages/$name/recipe.sh"

if [ ! -f "$SRC/.unpacked" ]; then
	rm -rf "$SRC"
	mkdir -p "$SRC"
	tar -xf "$archive" -C "$SRC" --strip-components=1
	for patch in /ports/packages/"$name"/patches/*.patch; do
		[ -f "$patch" ] || continue
		echo "applying $(basename "$patch")"
		(cd "$SRC" && git apply -p1 "$patch")
	done
	touch "$SRC/.unpacked"
fi

rm -rf "$DEST"
mkdir -p "$DEST"
cd "$SRC"
build

# Development files go to the stage, for other packages to build against.
for dir in usr/include usr/lib; do
	[ -d "$DEST/$dir" ] || continue
	mkdir -p "$STAGE/$dir"
	cp -R "$DEST/$dir/." "$STAGE/$dir/"
done

# The package is what a running system needs: no headers, static
# libraries, manual pages or other documentation.
rm -rf "$DEST/usr/include" "$DEST/usr/share/man" "$DEST/usr/share/info" \
	"$DEST/usr/share/doc" "$DEST/usr/lib/pkgconfig"
find "$DEST" -name '*.a' -delete
find "$DEST" -depth -type d -empty -delete

tar -C "$DEST" --sort=name --owner=0 --group=0 --numeric-owner \
	--mtime=@0 -czf "/pwork/out/$name-$VERSION.tar.gz" .
echo "$name $VERSION: $(du -sh "$DEST" | cut -f1) installed"
