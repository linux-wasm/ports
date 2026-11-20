# diffutils: diff, cmp, diff3, sdiff.
VERSION=3.12
URL=https://ftp.gnu.org/gnu/diffutils/diffutils-3.12.tar.xz
SHA256=7c8b7f9fc8609141fdea9cece85249d308624391ff61dedaf528fcb337727dfd

build() {
	# A test that configure can only make by running a program; musl's
	# strcasecmp works.
	gl_cv_func_strcasecmp_works=yes configure_host
	make -j"$JOBS"
	make install DESTDIR="$DEST"
}
