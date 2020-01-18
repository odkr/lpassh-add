#!/bin/sh
#
# You should run this scripts via `make install`.
# This makes it more likely that you run it with a POSIX-compliant shell.

# SETTINGS
# ========

SHELLS='dash oksh mksh bash yash zsh'
MAN_CONFIG_PATH='/etc:/private/etc'
MAN_CONFIG_FILES='man.config:man.conf'


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
#       A signal number.
#
# Global variables:
#   EX (string): 
#       Code to be run. Unset thereafter.
#   TRAPS (space-separated list of integers):
#       Signal numbers traps have been registered for (read-only).
# 
# Exits with:
#   The value of $? at the time it was called.
onexit() {
    __ONEXIT_STATUS=$?
    # shellcheck disable=2086
    trap '' 0 ${TRAPS-2 15} || :
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
#   TRAPS (space-separated list of integers):
#       Signal numbers traps have been registered for. 
#       Adds every SIGNO to TRAPS.
#
# Returns:
#   0:
#       Always.
trapsig() {
    __TRAPSIG_FUNC="${1:?'missing FUNCTION.'}"
    shift
    for __TRAPSIG_SIGNO
    do
        # shellcheck disable=2064
        trap "$__TRAPSIG_FUNC $__TRAPSIG_SIGNO" "$__TRAPSIG_SIGNO"
        # shellcheck disable=2086
        for __TRAPSIG_TRAPPED in 0 ${TRAPS-}
        do
            [ "$__TRAPSIG_SIGNO" -eq "$__TRAPSIG_TRAPPED" ] && continue 2
        done
        TRAPS="${TRAPS-} $__TRAPSIG_SIGNO"
    done
}

# warns - Prints a message to STDERR.
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
    string="${1:?'warn: missing MESSAGE.'}"
    shift
    # shellcheck disable=2059
    case $# in
        0) printf -- "$0: $string\n" >&2 ;;
        *) printf -- "$0: $string\\n" "$@" >&2 ;;
    esac
)

# panic - Exits the script with an error message.
#
# Synopsis:
#   panic [STATUS [MESSAGE [ARG [ARG [...]]]]]
#
# Description:
#   * Prints MESSAGE to STDERR, as warn would.
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
    if [ $# -gt 0 ]; then
        shift
        [ $# -gt 0 ] && warn "$@"
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


# MAIN
# ====

# Try to find a suitable directory to copy lpassh-add to.
IFS=:
for DIR in $PATH; do
	IFS=/
	for ELEM in $DIR
	do
		if [ "$ELEM" = local ]; then
			INSTALL_DIR="$DIR"
			break 2
		fi
	done
done
unset IFS

if ! [ "${INSTALL_DIR-}" ] || ! [ -x "$INSTALL_DIR" ]; then
	panic 69 'Cannot guess a suitable installion directory.'
fi

# Try to find a POSIX-compliant shell.
IFS=' '
for SHELL in $SHELLS
do
	# shellcheck disable=2006
	IFS=: PATH=`getconf PATH`
	for DIR in $PATH
	do
		if [ -e "$DIR/$SHELL" ]; then
			SHELL_PATH="$DIR/$SHELL"
			break 2
		fi
	done
done
unset IFS

if ! [ "${SHELL_PATH-}" ] || ! [ -x "$SHELL_PATH" ]; then
	panic 69 'Cannot find a safe shell.'
fi

# Try to find a directory to copy the manual to.
IFS=:
for MAN_CONFIG_DIR in $MAN_CONFIG_PATH
do
	for MAN_CONFIG_FILE in $MAN_CONFIG_FILES
	do
		CFG="$MAN_CONFIG_DIR/$MAN_CONFIG_FILE"
		if [ -e "$CFG" ]; then
			# shellcheck disable=2006
			DIRS=`awk '/^MANPATH[[:space:]]/ && /\/local\// {print $2}' "$CFG"`
			for DIR in $DIRS
			do
				MANPATH="${MANPATH-}:$DIR"
			done
		fi
	done
done

IFS=:
for DIR in ${MANPATH-}
do
	[ -d "$DIR" ] || continue
	IFS=/
	for ELEM in $DIR
	do
		if [ "$ELEM" = local ]; then
			MAN_DIR="$DIR/man1"
			break 2
		fi
	done
done
unset IFS

# Let the user confirm what we've found.
B="" R=""
if [ "${CLICOLOR-}" ] || [ "${COLORTERM-}" ]; then
	B='\033[1m'
	R='\033[0m'
fi

warn '=================================================='
warn "Using $B$SHELL_PATH$R as interpreter."
warn "lpassh-add   -> $B$INSTALL_DIR$R"
[ "${MAN_DIR-}" ] && warn "lpassh-add.1 -> $B$MAN_DIR$R"
warn '--------------------------------------------------'
warn "Press $B<Return>$R to confirm or $B<Ctrl>$R-$B<C>$R to cancel."
warn '=================================================='

# shellcheck disable=2034,2162
read DUMMY

# Create and copy the files.
trapsig onexit 0 2 15
TMPFILE="lpassh-add.${SHELL:?}"
readonly TMPFILE
[ -e "$TMPFILE" ] && panic "%s: exists." "$TMPFILE"
# shellcheck disable=2016
EX='rm -rf "$TMPFILE"'

(	set -x
	umask 022
	printf '#!%s\n' "$SHELL_PATH" >"$TMPFILE"
  	sed -n '1n; p' lpassh-add >>"$TMPFILE"
	chmod ugo=rx "$TMPFILE"
	sudo chown 0 "$TMPFILE"
	sudo chgrp 0 "$TMPFILE"
	sudo mv "$TMPFILE" "$INSTALL_DIR/lpassh-add";	)

if [ "${MAN_DIR-}" ]; then
	(	set -x
		[ -e "$MAN_DIR" ] || sudo mkdir "$MAN_DIR"
		sudo cp lpassh-add.1 "$MAN_DIR"
		sudo chown 0 "$MAN_DIR/lpassh-add.1"
		sudo chgrp 0 "$MAN_DIR/lpassh-add.1"
		sudo chmod ugo=r "$MAN_DIR/lpassh-add.1";	)
fi
