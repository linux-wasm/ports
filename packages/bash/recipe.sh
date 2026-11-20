# bash: the GNU shell, with readline and job control.
VERSION=5.3
URL=https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz
SHA256=0d5cd86965f869a26cf64f4b71be7b96f90a3ba8b3d74e27e8e9d9d5550f31ba

build() {
	# configure cannot run test programs when cross-compiling and then
	# assumes the worst; these are the answers for this system (musl on
	# Linux). bash's own malloc wants sbrk(), which does not exist here.
	bash_cv_func_sigsetjmp=present \
	bash_cv_job_control_missing=present \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_ctype_nonascii=yes \
	bash_cv_dup2_broken=no \
	bash_cv_pgrp_pipe=no \
	bash_cv_opendir_not_robust=no \
	bash_cv_ulimit_maxfds=yes \
	bash_cv_getcwd_malloc=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_printf_a_format=yes \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_unusable_rtsigs=no \
	bash_cv_wcwidth_broken=no \
	bash_cv_func_snprintf=yes \
	bash_cv_func_vsnprintf=yes \
	bash_cv_wexitstatus_offset=8 \
	bash_cv_dev_fd=standard \
	bash_cv_dev_stdin=present \
	bash_cv_getenv_redef=yes \
	configure_host \
		--without-bash-malloc --with-curses --enable-readline \
		--enable-job-control --enable-history --disable-rpath
	make -j"$JOBS"
	make install DESTDIR="$DEST"
	# No loadable builtins without a dynamic loader.
	rm -rf "$DEST/usr/lib/bash" "$DEST/usr/bin/bashbug"
}
