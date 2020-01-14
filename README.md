# lpassh-add

**lpassh-add** works just like [OpenSSh](https://www.openssh.com)'s
**ssh-add**, that is, it unlocks your SSh private keys, but it retrieves
the passphrases for those keys from LastPass, if possible. It is a
*dumb* wrapper around **ssh-add** and the [LastPass command line
client](https://github.com/lastpass/lastpass-cli).

**lpassh-add** is but a short-ish shell script.
You can easily check that it doesn't do anything funky.

See the [manual](MANUAL.rst) and the [source](lpassh-add) for details.


## INSTALLATION

You use **lpassh-add** *at your own risk*. You have been warned.

### System requirements

You need:

1. [OpenSSh](https://www.openssh.com)
2. The [LastPass command line client](https://github.com/lastpass/lastpass-cli)
3. A bourne-compatible shell that provides a `printf` *builtin* (modern shells do).

Otherwise, **lpassh-add** complies with
[POSIX.1-2017](http://pubs.opengroup.org/onlinepubs/9699919799/). It also *aims*
to be compatible with [System V Release 4.2](https://www.in-ulm.de/~mascheck/bourne/).

It should run on any modern-ish Unix system (e.g., Linux, FreeBSD, NetBSD, OpenBSD, and
macOS). However, on some systems (e.g., Solaris) you may need to change the shebang
line on some systems, so that it points to a POSIX-compliant bourne shell.

### Set-up

1. Download the repository from:
   <https://github.com/odkr/lpassh-add/archive/v1.1.0.tar.gz>
2. Unpack the repository.
3. Copy **lpassh-add** to a directory in your `PATH`.
4. You may also want to install its manual page.

If you have [curl](https://curl.haxx.se/) or
            [wget](https://www.gnu.org/software/wget/),
you probably can do all of the above by:

```sh
    # Download the archive and the signature.
    ( DL=curl DL_OPTS='-LsSo'
      "$DL" 2>/dev/null
      [ $? -eq 127 ] && DL=wget DL_OPTS='-qO'
      "$DL" 2>/dev/null
      [ $? -eq 127 ] && exit 127
      BASE_URL=https://github.com/odkr/lpassh-add VERS=v1.1.0
      AR="$VERS.tar.gz" SIG="$VERS.tar.gz.asc"
      "$DL" $DL_OPTS "$AR" "$BASE_URL/archive/$AR"
      "$DL" $DL_OPTS "$SIG" "$BASE_URL/releases/download/$VERS/$SIG" )
    # Verify the archive.
    gpg --verify v1.1.0.tar.gz.asc
    # Unpack it.
    tar -xzf v1.1.0.tar.gz
    # Check the source!
    more lpassh-add-1.1.0/lpassh-add
    # If you like what see, continue by:
    sudo cp lpassh-add-1.1.0/lpassh-add /usr/local/bin
    sudo cp lpassh-add-1.1.0/lpassh-add.1 /usr/local/share/man/man1
```

*Note:* **lpassh-add** *must* reside in a directory that's in your `PATH`,
or else **ssh-add** may *not* be able to find it.


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
