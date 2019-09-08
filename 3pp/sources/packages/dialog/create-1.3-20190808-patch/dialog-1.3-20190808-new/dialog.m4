dnl #
dnl # /usr/share/aclocal/dialog.m4
dnl #
dnl # Configure paths for dialog
dnl # Andrew V.Kosteltsev

dnl ============================================================
dnl
dnl  Synopsis:
dnl     AC_CHECK_DIALOG([MIN-VERSION [,                  # minimum dialog version, e.g. 1.3-20190211
dnl                           DEFAULT-WITH-DIALOG [,     # default value for --with-dialog option
dnl                           DEFAULT-WITH-DIALOG-TEST [,# default value for --with-dialog-test option
dnl                           EXTEND-VARS [,                  # whether CFLAGS/LDFLAGS/etc are extended
dnl                           ACTION-IF-FOUND [,              # action to perform if dialog was found
dnl                           ACTION-IF-NOT-FOUND             # action to perform if dialog was not found
dnl                          ]]]]]])
dnl  Examples:
dnl     AC_CHECK_DIALOG(1.3-20190211)
dnl     AC_CHECK_DIALOG(1.3-20190211,,,no,CFLAGS="$CFLAGS -DHAVE_DIALOG $DIALOG_CFLAGS")
dnl     AC_CHECK_DIALOG(1.3-20190211,yes,yes,yes,CFLAGS="$CFLAGS -DHAVE_DIALOG")
dnl
dnl
dnl  If you have to change prefix returned by dialog-config script or change
dnl  location of dialog-config, you may set environment variable DIALOG_CONFIG,
dnl  for example:
dnl
dnl  # export DIALOG_CONFIG="dialog-config --prefix=/usr/local"
dnl  # export DIALOG_CONFIG="/usr/bin/dialog-config --prefix=/usr/local"
dnl
dnl ============================================================
dnl
dnl ============================================================
dnl  auxilliary macros
dnl ============================================================
AC_DEFUN([_AC_DIALOG_ERROR], [dnl
AC_MSG_RESULT([*FAILED*])
cat <<EOT | sed -e 's/^[[ 	]]*/ | /' -e 's/>>/  /' 1>&2
$1
EOT
exit 1
])

AC_DEFUN([_AC_DIALOG_VERBOSE], [dnl
if test ".$verbose" = .yes; then
    AC_MSG_RESULT([  $1])
fi
])

dnl ============================================================
dnl  the user macro
dnl ============================================================
AC_DEFUN([AC_CHECK_DIALOG], [dnl
dnl
dnl ============================================================
dnl  prerequisites
dnl ============================================================
AC_REQUIRE([AC_PROG_CC])dnl
AC_REQUIRE([AC_PROG_CPP])dnl
dnl
dnl ============================================================
dnl  set DIALOG_CONFIG variable
dnl ============================================================
if test -z "$DIALOG_CONFIG"; then
  DIALOG_CONFIG='dialog-config'
fi
dnl
DIALOG_CFLAGS=''
DIALOG_LDFLAGS=''
DIALOG_LIBS=''
AC_SUBST(DIALOG_CFLAGS)
AC_SUBST(DIALOG_LDFLAGS)
AC_SUBST(DIALOG_LIBS)
dnl
dnl ============================================================
dnl  command line options
dnl ============================================================
_AC_DIALOG_VERBOSE([])
AC_ARG_WITH(dialog,dnl
[  --with-dialog[=ARG]       Build with dialog Library  (default=]ifelse([$2],,yes,$2)[)],dnl
,dnl
with_dialog="ifelse([$2],,yes,$2)"
)dnl
AC_ARG_WITH(dialog-test,dnl
[  --with-dialog-test      Perform dialog Sanity Test (default=]ifelse([$3],,yes,$3)[)],dnl
,dnl
with_dialog_test="ifelse([$3],,yes,$3)"
)dnl
_AC_DIALOG_VERBOSE([+ Command Line Options:])
_AC_DIALOG_VERBOSE([    o --with-dialog=$with_dialog])
_AC_DIALOG_VERBOSE([    o --with-dialog-test=$with_dialog_test])
dnl
dnl ============================================================
dnl  configuration
dnl ============================================================
if test ".$with_dialog" != .no; then
    dialog_subdir=no
    dialog_subdir_opts=''
    case "$with_dialog" in
        subdir:* )
            dialog_subdir=yes
            changequote(, )dnl
            dialog_subdir_opts=`echo $with_dialog | sed -e 's/^subdir:[^ 	]*[ 	]*//'`
            with_dialog=`echo $with_dialog | sed -e 's/^subdir:\([^ 	]*\).*$/\1/'`
            changequote([, ])dnl
            ;;
    esac
    dialog_version=""
    dialog_location=""
    dialog_type=""
    dialog_cflags=""
    dialog_ldflags=""
    dialog_libs=""
    if test ".$with_dialog" = .yes; then
        #   via config script in $PATH
        changequote(, )dnl
        dialog_version=`($DIALOG_CONFIG --version) 2>/dev/null |\
                      sed -e 's/^.*\([0-9]\.[0-9]*[-][0-9]*\).*$/\1/'`
        changequote([, ])dnl
        if test ".$dialog_version" != .; then
            dialog_location=`$DIALOG_CONFIG --prefix`
            dialog_type='installed'
            dialog_cflags=`$DIALOG_CONFIG --cflags`
            dialog_ldflags=`$DIALOG_CONFIG --ldflags`
            dialog_libs=`$DIALOG_CONFIG --libs`
        fi
    elif test -d "$with_dialog"; then
        with_dialog=`echo $with_dialog | sed -e 's;/*$;;'`
        dialog_found=no
        #   via config script under a specified directory
        #   (a standard installation, but not a source tree)
        if test ".$dialog_found" = .no; then
            for _dir in $with_dialog/bin $with_dialog; do
                if test -f "$_dir/dialog-config"; then
                    test -f "$_dir/dialog-config.in" && continue # dialog-config in source tree!
                    changequote(, )dnl
                    dialog_version=`($_dir/dialog-config --version) 2>/dev/null |\
                                  sed -e 's/^.*\([0-9]\.[0-9]*[.][0-9]*\).*$/\1/'`
                    changequote([, ])dnl
                    if test ".$dialog_version" != .; then
                        dialog_location=`$_dir/dialog-config --prefix`
                        dialog_type="installed"
                        dialog_cflags=`$_dir/dialog-config --cflags`
                        dialog_ldflags=`$_dir/dialog-config --ldflags`
                        dialog_libs=`$_dir/dialog-config --libs`
                        dialog_found=yes
                        break
                    fi
                fi
            done
        fi
    fi
    _AC_DIALOG_VERBOSE([+ Determined Location:])
    _AC_DIALOG_VERBOSE([    o path: $dialog_location])
    _AC_DIALOG_VERBOSE([    o type: $dialog_type])
    if test ".$dialog_version" = .; then
        if test ".$with_dialog" != .yes; then
             _AC_DIALOG_ERROR([dnl
             Unable to locate dialog under $with_dialog.
             Please specify the correct path to either a dialog installation tree
             (use --with-dialog=DIR if you used --prefix=DIR for installing dialog in
             the past).])
        else
             _AC_DIALOG_ERROR([dnl
             Unable to locate dialog in any system-wide location (see \$PATH).
             Please specify the correct path to either a dialog installation tree
             (use --with-dialog=DIR if you used --prefix=DIR for installing dialog in
             the past, or set the DIALOG_CONFIG environment variable to the full path
             to dialog-config).])
        fi
    fi
    dnl ========================================================
    dnl  Check whether the found version is sufficiently new
    dnl ========================================================
    _req_version="ifelse([$1],,1.0.0,$1)"
    for _var in dialog_version _req_version; do
        eval "_val=\"\$${_var}\""
        _major=`echo $_val | sed 's/\([[0-9]]*\)\.\([[0-9]]*\)\([[.]]\)\([[0-9]]*\)/\1/'`
        _minor=`echo $_val | sed 's/\([[0-9]]*\)\.\([[0-9]]*\)\([[.]]\)\([[0-9]]*\)/\2/'`
        _micro=`echo $_val | sed 's/\([[0-9]]*\)\.\([[0-9]]*\)\([[.]]\)\([[0-9]]*\)/\4/'`
        _hex=`echo dummy | awk '{ printf("%d%02d%02d", major, minor, micro); }' \
              "major=$_major" "minor=$_minor" "micro=$_micro"`
        eval "${_var}_hex=\"\$_hex\""
    done
    _AC_DIALOG_VERBOSE([+ Determined Versions:])
    _AC_DIALOG_VERBOSE([    o existing: $dialog_version -> 0x$dialog_version_hex])
    _AC_DIALOG_VERBOSE([    o required: $_req_version -> 0x$_req_version_hex])
    _ok=0
    if test ".$dialog_version_hex" != .; then
        if test ".$_req_version_hex" != .; then
            if test $dialog_version_hex -ge $_req_version_hex; then
                _ok=1
            fi
        fi
    fi
    if test ".$_ok" = .0; then
        _AC_DIALOG_ERROR([dnl
        Found dialog version $dialog_version, but required at least version $_req_version.
        Upgrade dialog under $dialog_location to $_req_version or higher first, please.])
    fi
    dnl ========================================================
    dnl  Perform dialog Sanity Compile Check
    dnl ========================================================
    if test ".$with_dialog_test" = .yes; then
        _ac_save_CFLAGS="$CFLAGS"
        _ac_save_LDFLAGS="$LDFLAGS"
        _ac_save_LIBS="$LIBS"
        CFLAGS="$CFLAGS $dialog_cflags"
        LDFLAGS="$LDFLAGS $dialog_ldflags"
        LIBS="$LIBS $dialog_libs"
        _AC_DIALOG_VERBOSE([+ Test Build Environment:])
        _AC_DIALOG_VERBOSE([    o CFLAGS=\"$CFLAGS\"])
        _AC_DIALOG_VERBOSE([    o LDFLAGS=\"$LDFLAGS\"])
        _AC_DIALOG_VERBOSE([    o LIBS=\"$LIBS\"])
        cross_compile=no
        define(_code1, [dnl

#include <stdlib.h>
#include <stdio.h>
#include <strings.h>  /* index(3)    */

#include <dialog.h>
#include <dlg_colors.h>
#include <dlg_keys.h>

        ])
        define(_code2, [dnl

int main( void )
{
  int status = 0;

  bzero( (void *)&dialog_vars, sizeof(DIALOG_VARS) );

  init_dialog(stdin, stdout);

  dialog_vars.colors = 1;
  dialog_vars.backtitle = "\\Z7Test\\Zn \\Z1dialog\\Zn \\Z7Library\\Zn";
  dialog_vars.dlg_clear_screen = 1;
  dialog_vars.sleep_secs = 1;


  dlg_put_backtitle();

  /*************************************************
    Ruler: 68 characters + 2 spaces left and right:

                           | ----handy-ruler----------------------------------------------------- | */
  status = dialog_msgbox( " \\Z4Dialog ==>\\Zn\\Z1libdialog\\Zn\\Z4<== [required]\\Zn ",
                          "\nPackage is installed and corect.\n",
                          5, 72, 0 );

  if( dialog_vars.sleep_secs )
    (void)napms(dialog_vars.sleep_secs * 1000);

  if( dialog_vars.dlg_clear_screen )
  {
    dlg_clear();
    (void)refresh();
  }
  end_dialog();

  exit( 0 );
}
        ])
        _AC_DIALOG_VERBOSE([+ Performing Sanity Checks:])
        _AC_DIALOG_VERBOSE([    o pre-processor test])
        AC_TRY_CPP(_code1, _ok=yes, _ok=no)
        if test ".$_ok" != .yes; then
            _AC_DIALOG_ERROR([dnl
            Found dialog $dialog_version under $dialog_location, but
            was unable to perform a sanity pre-processor check. This means
            the dialog header dialog.h was not found.
            We used the following build environment:
            >> CPP="$CPP"
            See config.log for possibly more details.])
        fi
        _AC_DIALOG_VERBOSE([    o link check])
        AC_TRY_LINK(_code1, _code2, _ok=yes, _ok=no)
        if test ".$_ok" != .yes; then
            _AC_DIALOG_ERROR([dnl
            Found dialog $dialog_version under $dialog_location, but
            was unable to perform a sanity linker check. This means
            the dialog library libdialog.a was not found.
            We used the following build environment:
            >> CC="$CC"
            >> CFLAGS="$CFLAGS"
            >> LDFLAGS="$LDFLAGS"
            >> LIBS="$LIBS"
            See config.log for possibly more details.])
        fi
        _extendvars="ifelse([$4],,yes,$4)"
        if test ".$_extendvars" != .yes; then
            CFLAGS="$_ac_save_CFLAGS"
            LDFLAGS="$_ac_save_LDFLAGS"
            LIBS="$_ac_save_LIBS"
        fi
    else
        _extendvars="ifelse([$4],,yes,$4)"
        if test ".$_extendvars" = .yes; then
            if test ".$dialog_subdir" = .yes; then
                CFLAGS="$CFLAGS $dialog_cflags"
                LDFLAGS="$LDFLAGS $dialog_ldflags"
                LIBS="$LIBS $dialog_libs"
            fi
        fi
    fi
    DIALOG_CFLAGS="$dialog_cflags"
    DIALOG_LDFLAGS="$dialog_ldflags"
    DIALOG_LIBS="$dialog_libs"
    AC_SUBST(DIALOG_CFLAGS)
    AC_SUBST(DIALOG_LDFLAGS)
    AC_SUBST(DIALOG_LIBS)

    AC_SUBST(HAVE_DIALOG, [1])

    AC_CHECK_HEADERS(dialog.h dlg_colors.h dlg_keys.h)

    _AC_DIALOG_VERBOSE([+ Final Results:])
    _AC_DIALOG_VERBOSE([    o DIALOG_CFLAGS=\"$DIALOG_CFLAGS\"])
    _AC_DIALOG_VERBOSE([    o DIALOG_LDFLAGS=\"$DIALOG_LDFLAGS\"])
    _AC_DIALOG_VERBOSE([    o DIALOG_LIBS=\"$DIALOG_LIBS\"])
fi
if test ".$with_dialog" != .no; then
    AC_MSG_CHECKING(for libdialog)
    AC_MSG_RESULT([version $dialog_version, $dialog_type under $dialog_location])
    ifelse([$5], , :, [$5])
else
    AC_MSG_CHECKING(for libdialog)
    AC_MSG_RESULT([no])
    ifelse([$6], , :, [$6])
fi
])

