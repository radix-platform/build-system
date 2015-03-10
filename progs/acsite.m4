
dnl ============================================================
dnl  Test for build_host `ln -s' .
dnl  ============================
dnl
dnl Usage:
dnl -----
dnl    AC_PATH_PROG_LN_S
dnl    AC_SUBST(LN)
dnl    AC_SUBST(LN_S)
dnl
dnl ============================================================
AC_DEFUN(AC_PATH_PROG_LN_S,
[AC_PATH_PROG(LN, ln, no, /usr/local/bin:/usr/bin:/bin:$PATH)
AC_MSG_CHECKING(whether ln -s works on build host)
AC_CACHE_VAL(ac_cv_path_prog_LN_S,
[rm -f conftestdata
if $LN -s X conftestdata 2>/dev/null
then
   rm -f conftestdata
   ac_cv_path_prog_LN_S="$LN -s"
else
   ac_cv_path_prog_LN_S="$LN"
fi])dnl
LN_S="$ac_cv_path_prog_LN_S"
if test "$ac_cv_path_prog_LN_S" = "$LN -s"; then
   AC_MSG_RESULT(yes)
else
   AC_MSG_RESULT(no)
fi
AC_SUBST(LN)dnl
AC_SUBST(LN_S)dnl
])

