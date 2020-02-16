# lpassh-add

**lpassh-add** works just like [OpenSSH](https://www.openssh.com)'s
**ssh-add**, that is, it unlocks your SSh private keys, but it retrieves
the passphrases for those keys from LastPass, if possible. It is a
*dumb* wrapper around **ssh-add** and the [LastPass command line
client](https://github.com/lastpass/lastpass-cli).

**lpassh-add** is but a short-ish shell script.
You can easily check that it doesn't do anything funky.

See the [manual](MANUAL.rst), particulary the "SECURITY" section,
and the [source](lpassh-add) for details.

If you're reading this on GitHub, keep in mind that it applies to the
most recent *commit*, which may *not* be most recent *release*. Consult
the README.md, [MANUAL.rst](MANUAL.rst), and [source](lpassh-add)
of the release that you've downloaded.

## INSTALLATION

You use **lpassh-add** *at your own risk*. You have been warned.

### TL;DR

**lpassh-add** aims to be more portable than is reasonable.
It should "just work".
You need OpenSSH and the LastPass command line client, of course.

If (1) your operating system is POSIX-compliant enough (macOS, Linux, and
the \*BSDs all should be), (2) you have [curl](https://curl.haxx.se/) or
[wget](https://www.gnu.org/software/wget/) (you probably do), and (3)
are using a modern-ish bourne-compatible shell (bash, dash, ksh, mksh, oksh,
and yash all should do), then you can install **lpassh-add** by:

```sh
( set -Cfu; NAME=lpassh-add VERS=1.1.1
  for GET in 'curl -LsS' 'wget -qO -'; do
      $GET "https://github.com/odkr/$NAME/archive/v$VERS.tar.gz"
      [ $? -eq 127 ] || break
  done | tar -xz
  cd "$NAME-$VERS" && make install; )
```

You can simply copy-paste the above code as a whole into a terminal.
(Don't overlook the brackets!)

If you want to verify the sources using [GnuPG](https://gnupg.org/),
then read on.

### System requirements

You need:

1. [OpenSSH](https://www.openssh.com)
2. The [LastPass command line client](https://github.com/lastpass/lastpass-cli)
3. If you want to use **lpassh-add** *without* the LastPass agent,
   which ships with the LastPass command line client,
   you also need a shell that provides `[` and `printf` as *built-ins*
   (every non-ancient shell should do so, however).

Otherwise, **lpassh-add** complies with
[POSIX.1-2017](http://pubs.opengroup.org/onlinepubs/9699919799/).
It also *aims* to be compatible with
[System V Release 4.2](https://www.in-ulm.de/~mascheck/bourne/).

It should run on any modern-ish Unix system (e.g., Linux, FreeBSD, NetBSD,
OpenBSD, and macOS). However, on some systems (e.g., Solaris) you may need to
change the shebang line, so that it points to a POSIX-compliant bourne shell
(`make install` should do that for you, however).

### Tested shells

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
askpass utility. *Neither* is the default behaviour. See "SECURITY"
in the [manual](MANUAL.rst#security) for details.

### Set-up

1. Download the repository from:
   <https://github.com/odkr/lpassh-add/archive/v1.1.1.tar.gz>
2. Unpack the repository.
3. Copy **lpassh-add** to a directory in your `PATH`.
4. Copy its manual page (`lpassh-add.1`) ito a directory in your `MANPATH`.

*Note:* **lpassh-add** *must* reside in a directory that's in your `PATH`,
or else **ssh-add** may *not* be able to find it.

If you have [curl](https://curl.haxx.se/) or
            [wget](https://www.gnu.org/software/wget/),
you probably can download **lpassh-add** by:

```sh
( set -Cfu
  NAME=lpassh-add VERS=1.1.1; AR="v$VERS.tar.gz"
  # Download the archive and the signature.
  for GET in 'curl -LsSo' 'wget -qO'; do
      for FILE in "archive/$AR" "releases/download/v$VERS/$AR.asc"; do
          $GET "$(basename "$FILE")" "https://github.com/odkr/$NAME/$FILE"
          case $? in 0) :;; 127) continue 2;; *) exit;; esac
      done
      break
  done; )
```

You can simply copy-paste the above code as a whole into a terminal.
(Don't overlook the brackets!)

If you have [GnuPG](https://gnupg.org/), you can check whether
the archive that you've just downloaded has been tempered with:

```sh
# Download my GnuPG key.
gpg --recv-keys 0x6B06A2E03BE31BE9
gpg --verify v1.1.1.tar.gz.asc v1.1.1.tar.gz
```

Then unpack the archive:

```sh
tar -xzf v1.1.1.tar.gz
```

Finally, install **lpassh-add** and its manual:

```sh
cd lpassh-add-1.1.1
make install
```

`make install` tries to find a POSIX-compliant shell to run **lpassh-add** with,
copies **lpassh-add** itself and its manual to `/opt/lpassh-add`, and changes
your `~/.bash_profile`, if it exists, to add `/opt/lpassh-add/bin` to your
`PATH`. It outputs (some of) the commands it runs, so you can see what it's
doing. Note, it calls `sudo`, so it will likely prompt you for your login
password.

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

**lpassh-add** is more complex than the tools above, save for Koszek's
**lastpass-ssh**. But it's also more similar in usage to **ssh-add**,
offers more features, and doesn't require you to store the passphrases
for your SSH keys in a particular directory in LastPass; all it requires
is that the name of the item that describes your SSH key or the name of
the directory that you've put that item into contains "ssh".

## ASKPASS FOR MACOS

I couldn't find an askpass utility for macOS that is *simple*.

So, I wrote [mac-ssh-askpass](https://github.com/odkr/mac-ssh-askpass).
It works well with **lpassh-add**.

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
