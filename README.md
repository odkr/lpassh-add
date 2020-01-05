# lpassh-add

**lpassh-add** works just like [OpenSSh](https://www.openssh.com)'s
**ssh-add**, that is, it unlocks your SSh private keys, but it retrieves
the passphrases for those keys from LastPass, if possible. It is a
*dumb* wrapper around **ssh-add** and the [LastPass command line
client](https://github.com/lastpass/lastpass-cli).

**lpassh-add** is but a short-ish shell script.
You can easily check that it doesn't do anything funky.

See the [manual](MANUAL.md) and the [source](lpassh-add) for details.


## INSTALLATION

You use **lpassh-add** *at your own risk*. You have been warned.

You need:

1. [OpenSSh](https://www.openssh.com)
2. The [LastPass command line client](https://github.com/lastpass/lastpass-cli)

Apart from OpenSSh and the LastPass command line client, **lpassh-add** is
[POSIX.1-2017](http://pubs.opengroup.org/onlinepubs/9699919799/)-compliant.
So it should run on any modern-ish Unix system (e.g., Linux, FreeBSD, NetBSD,
OpenBSD, or macOS). **lpassh-add** also *aims* to be
[System V Release 4.2](https://www.in-ulm.de/~mascheck/bourne/)-compatible.
So it should also run on many older Unix systems
(you may need to adapt the shebang line though).

Download the repository from:
<https://github.com/odkr/lpassh-add/archive/v1.0.5.tar.gz>

Unpack the repository, copy **lpassh-add** to a directory in your `PATH`,
and make it executable. You may also want to install the manual page.

If you have [curl](https://curl.haxx.se/) or
            [wget](https://www.gnu.org/software/wget/),
you can do all of the above by:

```sh
    NAME=lpassh-add VERS=1.0.5
    PROG="${NAME:?}-${VERS:?}/${NAME:?}"
    URL="https://github.com/odkr/${NAME:?}/archive/v${VERS:?}.tar.gz"
    {
        ERR=0
        curl -L "$URL" || ERR=$?
        [ "$ERR" -eq 127 ] && wget -q -O - "$URL"
    } | tar -xz
    # Check the source!
    more "${PROG:?}"
    # If you like what you've seen, continue by:
    sudo mkdir -pm 0755 /usr/local/bin
    sudo cp "${PROG:?}" /usr/local/bin
    sudo cp "${PROG:?}.1" /usr/local/share/man/man1
```

*Note:* **lpassh-add** *must* reside in a directory that's in your `PATH`,
or else **ssh-add** won't be able to find it.


## DOCUMENTATION

See the [manual](MANUAL.md) and the [source](lpassh-add).


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
