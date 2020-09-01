#!/bin/sh
#
# Installs lpassh-add.
#
# You should run this scripts via `make install`.
# This makes it more likely that you run it with a POSIX-compliant shell.

# SETTINGS
# ========

# Safe and sufficiently POSIX compliant shells.
# Space-seperated list. Must be filenames. Searched in PATH.
# Order by preference.
SHELLS='dash oksh bash yash zsh'

# Where to install lpassh-add to.
INSTALL_DIR=/opt/lpassh-add


# FUNCTIONS
# =========

# onexit - Run code on exit.
# 
# Synopsis:
#   onexit SIGNO
#
# Description:
#   * Runs the shell code in the global variable $EX.
#   * If SIGNO is greater than 0, propagates that signal to the process group.
#   * If SIGNO isn't given or 0, terminates all children.
#   * Exits the script.
#
# Arguments:
#   SIGNO (integer):
#       A signal number or 0 for "on programme exit".
#
# Global variables:
#   EX (string): 
#       Code to be run. Unset thereafter.
#   TRAPS (space-separated list of signal names):
#       Signals that traps have been registered for (read-only). 
# 
# Exits with:
#   The value of $? at the time it was called.
onexit() {
    __ONEXIT_STATUS=$?
	unset IFS
    # shellcheck disable=2086
    trap '' EXIT ${TRAPS-INT TERM} || :
    set +e
    if [ "${EX-}" ]; then
        eval "$EX"
        unset EX
    fi
    if [ "${1-0}" -gt 0 ]; then
        __ONEXIT_STATUS=$((128+$1))
        kill "-$1" "-$$" 2>/dev/null
    fi
    exit "$__ONEXIT_STATUS"
}


# signame - Get a signal's name by its number.
#
# Synopsis:
#   signame SIGNO
#
# Description:
#   Prints the name of the name of the signal with the number SIGNO.
#   If SIGNO is 0, prints "EXIT".
#
# Arguments:
#   SIGNO (integer):
#       A signal number or 0 for "on programme exit".
signame() (
    : "${1:?'missing SIGNO'}"
    if [ "$1" -eq 0 ]
        then printf 'TERM\n'
        else kill -l "$1"
    fi
)


# trapsig - Register functions to trap signals.
#
# Synopsis:
#   trapsig FUNCTION SIGNO
#
# Description:
#   Registers FUNCTION to handle SIGNO.
#
# Arguments:
#   FUNCTION (string):
#       A shell function.
#   SIGNO (integer):
#       A signal number or 0 for "on programme exit".
#
# Global variables:
#   TRAPS (space-separated list of signal names):
#       Signals that traps have been registered for. 
#       Adds the name of every given SIGNO to TRAPS.
#
# Returns:
#   0:
#       Always.
trapsig() {
    __TRAPSIG_FUNC="${1:?'missing FUNCTION'}"
    shift
    for __TRAPSIG_SIGNO
    do
        __TRAPSIG_SIGNAME="$(signame "$__TRAPSIG_SIGNO")"
        # shellcheck disable=2064
        trap "$__TRAPSIG_FUNC $__TRAPSIG_SIGNO" "$__TRAPSIG_SIGNAME"
        # shellcheck disable=2086
        for __TRAPSIG_TRAPPED in EXIT ${TRAPS-}
        do
            [ "$__TRAPSIG_SIGNAME" = "$__TRAPSIG_TRAPPED" ] && continue 2
        done
        TRAPS="${TRAPS-} $__TRAPSIG_SIGNAME"
    done
}


# warn - Prints a message to STDERR.
#
# Synopsis:
#   warn MESSAGE [ARG [ARG [...]]]
#
# Description:
#   * Formats MESSAGE with the given ARGs (think printf).
#   * Prefixes the message with "lpassh-add: ", appends a linefeed,
#     and prints the message to STDERR.
#
# Arguments:
#   MESSAGE (string):
#       The message.
#   ARG (any):
#       Arguments for MESSAGE (think printf).
#
# Returns:
#   0:
#       Always.
warn() (
    : "${1:?'warn: missing MESSAGE'}"
    exec >&2
    # shellcheck disable=2006
    printf '%s: ' "`basename "$0"`"
    # shellcheck disable=2059
    printf -- "$@"
    printf '\n'
)


# panic - Exits the script with an error message.
#
# Synopsis:
#   panic [STATUS [MESSAGE [ARG [ARG [...]]]]]
#
# Description:
#   * If a MESSAGE is given, prints it as warn would.
#   * Exits the programme with STATUS.
#
# Arguments:
#   STATUS (integer):
#       The status to exit with. Defaults to 69.
#
#   See warn for the remaing arguments.
#
# Exits with:
#   STATUS
# shellcheck disable=2059
panic() {
    set +eu
    __PANIC_STATUS="${1:-69}"
    if [ $# -gt 1 ]; then
        shift
        warn "$@"
    fi
    exit "$__PANIC_STATUS"
}


# PRELUDE
# =======

# shellcheck disable=2039
[ "$BASH_VERSION" ] && set -o posix
[ "$ZSH_VERSION"  ] && emulate sh 2>/dev/null
# shellcheck disable=2034
BIN_SH=xpg4 NULLCMD=: POSIXLY_CORRECT=x
export BIN_SH POSIXLY_CORRECT

set -Cefu

PATH=/bin:/usr/bin
# shellcheck disable=2006
PATH="`getconf PATH`:$PATH"
export PATH

: "${INSTALL_DIR:?}"


# FIND A SHELL
# ============

for SHELL in $SHELLS
do
	IFS=:
	for DIR in $PATH
	do
		if [ -e "$DIR/$SHELL" ]; then
			POSIX_SH="$DIR/$SHELL"
			break 2
		fi
	done
done
unset IFS

if ! [ "${POSIX_SH-}" ] || ! [ -x "$POSIX_SH" ]; then
	panic 69 'Cannot find a safe, POSIX-compliant shell.'
fi


# ASK FOR CONFIRMATION
# ====================

B="" R=""
if [ "${CLICOLOR-}" ] || [ "${COLORTERM-}" ]; then
	B='\033[1m' R='\033[0m'
fi

warn '------------------------------------------------------'
warn "Using  $B$POSIX_SH$R  as interpreter."
warn "lpassh-add    ->  $B$INSTALL_DIR/bin$R"
warn "lpassh-add.1  ->  $B$INSTALL_DIR/man/man1$R"
warn ' '
warn "Press $B<Return>$R to confirm or $B<Ctrl>$R-$B<c>$R to cancel."
warn 'I will likely have to ask you for your login password.'
warn '------------------------------------------------------'

# shellcheck disable=2034,2162
read DUMMY


# MAIN
# ====

# shellcheck disable=2006
DIRNAME=`expr "$0" : "\(.*\)/"` || :
if [ "$DIRNAME" ]; then
	cd "$DIRNAME" || exit
fi

# Create and copy the files.
trapsig onexit 0 2 15
# shellcheck disable=2006
POSIX_SH_NAME=`expr "//$POSIX_SH" : '.*/\(.*\)'` || exit
TMP_FILE="lpassh-add.${POSIX_SH_NAME:?}"
readonly TMP_FILE
[ -e "$TMP_FILE" ] && panic "%s: exists." "$TMP_FILE"
# shellcheck disable=2016
EX='rm -rf "$TMP_FILE"'

umask 022
printf '#!%s\n' "$POSIX_SH"   >"$TMP_FILE"
sed -n '1n; p' lpassh-add    >>"$TMP_FILE"
chmod ugo=rx                   "$TMP_FILE"

export INSTALL_DIR TMP_FILE
# shellcheck disable=1004
sudo -E sh -c 'set -Cefux
               mkdir -p        "$INSTALL_DIR/bin" \
                               "$INSTALL_DIR/man/man1"
               mv "$TMP_FILE"  "$INSTALL_DIR/bin/lpassh-add"
               cp lpassh-add.1 "$INSTALL_DIR/man/man1"
               chown -R 0      "$INSTALL_DIR"
               chgrp -R 0      "$INSTALL_DIR"' \
    || panic 69 'Installation failed. You may want to delete %s.' \
                "$INSTALL_DIR"

[ -e ~/.bash_profile ]                             || exit 0
grep -q "PATH=.*:$INSTALL_DIR/bin" ~/.bash_profile && exit 0

# shellcheck disable=2016
warn "Appending 'export PATH=\"\$PATH:%s/bin\"' to ~/.bash_profile." "$INSTALL_DIR"

( set -Cefu
  # shellcheck disable=2016
  printf '\nexport PATH="$PATH:%s/bin"\n' "$INSTALL_DIR" >> ~/.bash_profile; )
