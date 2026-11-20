# linux-wasm ports

Build recipes for the software of a Linux system on WebAssembly: upstream
releases, compiled for the [linux-wasm kernel](https://github.com/linux-wasm/linux)
and [musl](https://github.com/linux-wasm/musl), packed as one archive per
package. [linux-wasm/distro](https://github.com/linux-wasm/distro) builds
them and unpacks them into its base image.

**Status: 14 packages, none of them patched.** Each is the upstream
release configured for cross-compilation; what a recipe adds are answers
to configure tests that would have to run a program.

| Package | Version | Tested on the running system (distro's boot test) |
|---|---|---|
| busybox | 1.38.0 | init, `/bin/sh` (ash, which runs the boot scripts), mount, ps, vi and other small tools; configured by `packages/busybox/config` |
| ncurses | 6.5 | `tput` finds the terminal description; nano and less use it |
| bash | 5.3 | the login shell: job control, pipelines, subshells, `$(...)`, `<(...)`, arrays |
| coreutils | 9.8 | `ls`, `sort`, `head`, `seq`, `cat`, `tr`, `wc`, ... throughout the test |
| grep | 3.12 | `--version`, counting matches |
| sed | 4.9 | substitution in a pipeline |
| gawk | 5.3.2 | arithmetic on fields |
| findutils | 4.10.0 | `find -type f | xargs` |
| diffutils | 3.12 | `diff -q` |
| tar | 1.35 | create and list a `.tgz` |
| gzip | 1.14 | through `tar z` |
| make | 4.4.1 | a Makefile with a function call |
| less | 668 | `--version` only |
| nano | 8.6 | type a line, write the file, quit |

No test suite of any package has been run.

## Usage

Requirements: docker (or podman), curl, and a built toolchain from
linux-wasm/distro (`scripts/build.sh toolchain musl headers`).

```sh
./build.sh                # all packages -> work/out/<name>-<version>.tar.gz
./build.sh bash           # one package; what it depends on must be built
./build.sh --clean bash   # from a fresh source tree
```

The usual way is through distro, which passes its compiler and sysroot:
`scripts/build.sh ports` there. By hand, `TOOLCHAIN` is the directory with
`wasm-cc` (default `../distro/scripts`) and `SYSROOT` the musl sysroot
(default `../distro/work/sysroot`). A failed build prints the end of
`work/build/<name>.log`.

## How it works

- `build.sh` fetches the source archive (checked against the SHA-256 in
  the recipe) and runs `lib/build-package.sh` in the toolchain container.
- `lib/build-package.sh` unpacks the source to `work/build/<name>/`,
  applies `packages/<name>/patches/*.patch`, and calls the recipe's
  `build` function with the cross-compilation environment set up
  (`CC=wasm-cc`, `AR`, `CFLAGS`, ...).
- What the package installs (`DESTDIR`) is split: headers and libraries
  go to `work/stage/`, where later packages find them; the rest, without
  documentation, becomes the archive.
- Everything is linked statically: there is no dynamic loader yet. That
  is why coreutils is built as one program with a symlink per utility.

## Writing a recipe

`packages/<name>/recipe.sh` is a shell fragment:

```sh
# name: what it is.
VERSION=1.2
URL=https://example.org/name-1.2.tar.xz
SHA256=...

build() {
	configure_host --without-something
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
```

- `VERSION`, `URL` and `SHA256` must be plain assignments at the start of
  a line (`build.sh` reads them without running the file).
- `configure_host` runs `./configure` for this machine
  (`--host=wasm32-unknown-linux-musl`, `--prefix=/usr`) with the recipe's
  extra arguments. Variables set in front of it reach configure, which is
  how to answer a test it cannot run (`gl_cv_func_..._works=yes`).
- `$DEST` is where to install, `$STAGE` has the headers and libraries of
  the packages built before, `$JOBS` is the number of CPUs.
- Add the package to `ALL` in `build.sh`, after what it depends on.

What to expect from this machine (details in the kernel's
`tools/wasm/NOTES.md` and musl's `README.md`): `fork`, `vfork`, `exec`,
signals, job control, ptys and `setjmp`/`sigsetjmp` work; there are no
shared libraries, `dlopen`, `brk`/`sbrk` or memory protection, and a
program that computes without making system calls cannot be interrupted.

## Conventions

- [Conventional Commits](https://www.conventionalcommits.org/) in English,
  with the package as scope: `feat(bash): add bash 5.3`.
- A patch carries a header saying why it is needed and whether it could
  go upstream.

## License

The recipes and scripts are MIT licensed, see [LICENSE](LICENSE). Each
package has its upstream's license, and so has a patch for it.
