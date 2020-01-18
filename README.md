# lpassh-add

**lpassh-add** works just like [OpenSSh](https://www.openssh.com)'s
**ssh-add**, that is, it unlocks your SSh private keys, but it retrieves
the passphrases for those keys from LastPass, if possible. It is a
*dumb* wrapper around **ssh-add** and the [LastPass command line
client](https://github.com/lastpass/lastpass-cli).

**lpassh-add** is but a short-ish shell script.
You can easily check that it doesn't do anything funky.

See the [manual](MANUAL.rst), particulary the "SECURITY" section,
and the [source](lpassh-add) for details.

If you're reading this on GitHub, keep in mind that it applies to
the most recent *commit*, which may *not* be most recent *release*.
Consult the README.md, [manual](MANUAL.rst), and [source](lpassh-add)
of the release you download before using **lpassh-add**.

## INSTALLATION

You use **lpassh-add** *at your own risk*. You have been warned.

### TL;DR

If your operating system is POSIX-compliant enough
(macOS, Linux, FreeBSD, NetBSD, and OpenBSD are) *and* you have
[curl](https://curl.haxx.se/) or [wget](https://www.gnu.org/software/wget/),
which you probably do, then you can install **lpassh-add** by:

```sh
    ( set -Cfu
      NAME=lpassh-add VERS=1.1.1b
      BASE_URL=https://github.com/odkr/$NAME
      ARCHIVE="v$VERS.tar.gz"; SIG="$ARCHIVE.asc"
      for GET in 'curl -LsSo' 'wget -qO'; do
        for FILE in "archive/$ARCHIVE" "releases/download/v$VERS/$SIG"; do
          $GET "$(basename "$FILE")" "$BASE_URL/$FILE"
          case $? in 0) :;; 127) continue 2;; *) exit;; esac
        done; break
      done
      tar -xzf "$ARCHIVE"
      cd -P "$NAME-$VERS" || exit
      make install; )
```

You can simply copy-paste this code as a whole into a terminal. (Don't overlook the brackets!)

### System requirements

You need:

1. [OpenSSh](https://www.openssh.com)
2. The [LastPass command line client](https://github.com/lastpass/lastpass-cli)
3. If you want to use **lpassh-add** *without* the LastPass agent,
   which is part of the LastPass command line client,
   you also need a shell that provides `[` and `printf` as *built-ins*
   (every non-ancient shell should do so, however).

Otherwise, **lpassh-add** complies with
[POSIX.1-2017](http://pubs.opengroup.org/onlinepubs/9699919799/).
It also *aims* to be compatible with
[System V Release 4.2](https://www.in-ulm.de/~mascheck/bourne/).

It should run on any modern-ish Unix system (e.g., Linux, FreeBSD, NetBSD,
OpenBSD, and macOS). However, on some systems (e.g., Solaris) you may need to
change the shebang line, so that it points to a POSIX-compliant bourne shell.



### Tested with

Works with:

* bash v3.2.57(1), v5.0.11(1)
* dash v0.5.10.2
* ksh AJM 93u+ (but see below)
* mksh R57
* oksh v5.2.14
* yash v2.49
* zsh v5.3, v5.7.1

Doesn't work with:

* posh 0.13.2

Tests were run on macOS v10.14.6 only.

**Note**: ksh93 will write your LastPass master password to a temporary file
if, and only if, you do *not* use the LastPass agent and *do* use an
askpass utility. See "SECURITY" in the [manual](MANUAL.rst#security)
for details.

### Set-up

1. Download the repository from:
   <https://github.com/odkr/lpassh-add/archive/v1.1.1b.tar.gz>
2. Unpack the repository.
3. Copy **lpassh-add** to a directory in your `PATH`.
4. You may also want to install its manual page (`lpassh-add.1`).

*Note:* **lpassh-add** *must* reside in a directory that's in your `PATH`,
or else **ssh-add** may *not* be able to find it.

If you have [GnuPG](https://gnupg.org/) as well as
[curl](https://curl.haxx.se/) or [wget](https://www.gnu.org/software/wget/),
you probably can download and unpack **lpassh-add** by:

```sh
    ( set -Cfu
      NAME=lpassh-add VERS=1.1.1b
      BASE_URL=https://github.com/odkr/$NAME
      ARCHIVE="v$VERS.tar.gz"; SIG="$ARCHIVE.asc"
      # Download the archive and the signature.
      for GET in 'curl -LsSo' 'wget -qO'; do
        for FILE in "archive/$ARCHIVE" "releases/download/v$VERS/$SIG"; do
          $GET "$(basename "$FILE")" "$BASE_URL/$FILE"
          case $? in 0) :;; 127) continue 2;; *) exit;; esac
        done; break
      done
      set -e
      # Download my GnuPG key.
      gpg --recv-keys 0x6B06A2E03BE31BE9
      # Verify the archive.
      gpg --verify "$SIG" "$ARCHIVE" || exit
      # Unpack it.
      tar -xzf "$ARCHIVE"; )
```

You can simply copy-paste this code as a whole into a POSIX-compliant shell.
(Don't overlook the brackets!)

You can then install **lpassh-add** by:

```sh
    cd lpassh-add-1.1.1b
    # Check the source!
    more lpassh-add
    # If you like what see, continue by:
    make install
```

You *cannot* copy-paste this code as a whole, because of the `more` command.

`make install` tries to find a POSIX-compliant shell, a suitable installation
directory, and a suitable directory for the manual. It calls `sudo`, which will
prompt you for your login password. It outputs the commands it runs to install
**lpassh-add** and its manual; so you can see what it's doing.

If `make install` fails, you'll have to install **lpassh-add** manually
(i.e., follows steps 1-4 above); **lpassh-add** is more portable than
its installation script.

## DOCUMENTATION

See the [manual](MANUAL.rst) and the [source](lpassh-add).

## COMPARABLE TOOLS

* David Blewett's
  [lp-ssh-add.sh](https://gist.github.com/davidblewett/53047c4c7757b663c11b)
* Bob Copeland's
  [lp-ssh-add.sh](https://gist.github.com/bcopeland/3cabf6ff3fe94fcbd566)
* Knut Ahlers'
  [lpass-ssh.sh](https://gist.github.com/Luzifer/2f188ed3adc0f1b166f7)
* Wojciech Adam Koszek's
  [lastpass-ssh](https://github.com/wkoszek/lastpass-ssh)

**lp-ssh-add.sh**, both versions, downloads the SSH keys themselves
from LastPass, too. That's a nice feature.

## CONCTACT

If there's something wrong with **lpassh-add**,
[open an issue](https://github.com/odkr/lpassh-add/issues).

## LICENSE

Copyright 2018, 2019, 2020 Odin Kroeger

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
