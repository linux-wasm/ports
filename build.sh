#!/bin/sh
# Build packages for Linux on WebAssembly.
#
#   ./build.sh                 # all packages, in dependency order
#   ./build.sh bash            # one package (its dependencies must be built)
#   ./build.sh --clean bash    # throw away its build tree first
#
# A package is a directory packages/<name>/ with a recipe.sh (see
# README.md). The result is work/out/<name>-<version>.tar.gz, to be
# unpacked at the root of a file system.
#
# Environment:
#   TOOLCHAIN   directory with the compiler driver wasm-cc
#               (default ../distro/scripts)
#   SYSROOT     musl and kernel headers, as built by linux-wasm/distro
#               (default ../distro/work/sysroot)
#   WORK        sources, build trees and results (default ./work)
#   CONTAINER   docker (default) or podman
#   IMAGE       the toolchain image (default linux-wasm-build:llvm19)
set -eu

PORTS="$(cd "$(dirname "$0")" && pwd)"
WORK="${WORK:-$PORTS/work}"
TOOLCHAIN="$(cd "${TOOLCHAIN:-$PORTS/../distro/scripts}" && pwd)"
SYSROOT="$(cd "${SYSROOT:-$PORTS/../distro/work/sysroot}" && pwd)"
CONTAINER="${CONTAINER:-docker}"
IMAGE="${IMAGE:-${LINUX_WASM_IMAGE:-linux-wasm-build:llvm19}}"

# Dependencies first.
ALL="busybox ncurses bash coreutils grep sed gawk findutils diffutils tar gzip make less nano"

clean=
if [ "${1:-}" = --clean ]; then
	clean=1
	shift
fi
[ $# -gt 0 ] || set -- $ALL

mkdir -p "$WORK/src" "$WORK/build" "$WORK/out" "$WORK/stage"

for name; do
	recipe="$PORTS/packages/$name/recipe.sh"
	[ -f "$recipe" ] || { echo "no such package: $name" >&2; exit 1; }
	# The recipe's variables, without running anything.
	eval "$(sed -n 's/^\(VERSION\|URL\|SHA256\)=/\1=/p' "$recipe")"

	# Fetch on the host (the container has no need for the network).
	archive="$WORK/src/$(basename "$URL")"
	if [ ! -f "$archive" ]; then
		echo "$name: fetching $URL"
		curl -fsSL "$URL" -o "$archive.part"
		mv "$archive.part" "$archive"
	fi
	echo "$SHA256  $archive" | sha256sum -c --quiet - ||
		{ echo "$name: checksum mismatch for $archive" >&2; exit 1; }

	[ -z "$clean" ] || rm -rf "$WORK/build/$name"

	echo "$name: building $VERSION"
	"$CONTAINER" run --rm --security-opt label=disable \
		--user "$(id -u):$(id -g)" -e HOME=/tmp \
		-v "$PORTS:/ports:ro" -v "$WORK:/pwork" \
		-v "$TOOLCHAIN:/toolchain:ro" -v "$SYSROOT:/work/sysroot:ro" \
		-w /pwork "$IMAGE" \
		sh -eu /ports/lib/build-package.sh "$name" "$(basename "$archive")" \
		> "$WORK/build/$name.log" 2>&1 || {
		echo "$name: FAILED, last lines of $WORK/build/$name.log:" >&2
		tail -n 40 "$WORK/build/$name.log" >&2
		exit 1
	}
	echo "$name: $WORK/out/$name-$VERSION.tar.gz"
done
