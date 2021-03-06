# lpassh-add

**lpassh-add** works just like [OpenSSH](https://www.openssh.com)'s
**ssh-add**, that is, it unlocks your SSH private keys, but it retrieves
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

If you

1. are running an operating system that complies with POSIX
   (FreeBSD, GNU/Linux, macOS, NetBSD, and OpenBSD should)
2. have installed [curl](https://curl.haxx.se/) or
   [wget](https://www.gnu.org/software/wget/)
   (you probably do), and
3. are using a modern-ish bourne-compatible shell
   (e.g., bash, dash, ksh, yash, or zsh),

then you can install **lpassh-add** by:

```sh
( set -Cfu; NAME=lpassh-add VERS=1.1.7
  [ "$ZSH_VERSION" ] && setopt SH_WORD_SPLIT
  for GET in 'curl -LsS' 'wget -qO -'; do
      $GET "https://github.com/odkr/$NAME/archive/v$VERS.tar.gz"
      [ $? -eq 127 ] || break
  done | tar -xz || exit
  cd "$NAME-$VERS" && make install; )
```

You can simply copy-paste the above code as a whole into a terminal.
(Don't overlook the brackets!)

If you want to verify the sources using [GnuPG](https://gnupg.org/), read on.

### System requirements

You need:

1. [OpenSSH](https://www.openssh.com)
2. The [LastPass command line client](https://github.com/lastpass/lastpass-cli)
3. If you want to use **lpassh-add** *without* the LastPass agent,
   which ships with the LastPass command line client,
   you also need a shell that provides `printf` as a *built-in*
   (every non-ancient shell should do so, however).

Otherwise, **lpassh-add** complies with
[POSIX.1-2017](http://pubs.opengroup.org/onlinepubs/9699919799/).
It also *aims* to be compatible with
[System V Release 4.2](https://www.in-ulm.de/~mascheck/bourne/).

It should run on any modern-ish Unix system (e.g., FreeBSD, GNU/Linux, macOS,
NetBSD, or OpenBSD). However, on some systems (e.g., Solaris) you may need to
change the shebang line, so that it points to a POSIX-compliant bourne shell
(`make install` should do that for you, however).

### Tested shells

**lpassh-add** should work with *any* POSIX-compliant bourne shell.
However, I ran tests and did some research on the following.
Tests were run on macOS v10.14.6 only.

#### Passing

* **bash** v3.2.57(1), v5.0.11(1), 5.0.17(1)
* **dash** v0.5.10.2
* **oksh** v5.2.14
* **yash** v2.49
* **zsh** v5.3 (but see below)

Some versions of **zsh** may *not* always exit **lpassh-add** with the correct
exit status (though zero still signifies success and non-zero failure).

#### Passing with security caveats

* **ksh**
* **mksh** (depending on your version and compile options)

ksh93 will write your LastPass master password to a temporary file
if, and only if, you do *not* use the LastPass agent and *do* use an
askpass utility. *Neither* is the default behaviour. See "SECURITY"
in the [manual](MANUAL.rst#security) for details. Note, I have only
tested ksh93. I do *not* know how older versions of **ksh** behave;
I do *not* imply that they are safe.

[Some versions](https://www.mirbsd.org/mksh.htm) of **mksh**
do *not* provide `printf` as a built-in.

#### Failing

* **posh** v0.13.2

**posh** appears to have issues on macOS.
It may pass under Debian GNU/Linux.

### Set-up

1. Download the reposintory from:
   <https://github.com/odkr/lpassh-add/archive/v1.1.7.tar.gz>
2. Unpack it.
3. Copy **lpassh-add** into a directory in your `PATH`.
4. Copy its manual page (`lpassh-add.1`) into a directory in your `MANPATH`.

*Note:* **lpassh-add** *must* reside in a directory that's in your `PATH`,
or else **ssh-add** may *not* be able to find it.

If you have [curl](https://curl.haxx.se/) or
            [wget](https://www.gnu.org/software/wget/),
you can download **lpassh-add** by:

```sh
( set -Cfu
  NAME=lpassh-add VERS=1.1.7; AR="v$VERS.tar.gz"
  [ "$ZSH_VERSION" ] && setopt SH_WORD_SPLIT
  for GET in 'curl -LsSo' 'wget -qO'; do
      for FILE in "archive/$AR" "releases/download/v$VERS/$AR.asc"; do
          $GET "${FILE##*/}" "https://github.com/odkr/$NAME/$FILE"
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
# Verify the archive.
gpg --verify v1.1.7.tar.gz.asc v1.1.7.tar.gz
```

Then unpack the archive:

```sh
tar -xzf v1.1.7.tar.gz
```

Finally, install **lpassh-add** and its manual:

```sh
cd lpassh-add-1.1.7
make install
```

`make install` tries to find a POSIX-compliant shell to run **lpassh-add** with,
copies **lpassh-add** itself and its manual to `/opt/lpassh-add`, and adds 
`/opt/lpassh-add/bin` to your `PATH` in your `~/.bash_profile` and your
`~/.zshrc` -- if they exist. It outputs (some of) the commands it runs,
so you can see what it's doing. Note, it calls `sudo`, so it will likely
prompt you for your login password.

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
  [lpass-ssh.sh](https://gist.github.com/Luzifer/2f188ed3adc0f1.1.7f7)
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
