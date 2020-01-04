==========
lpassh-add
==========

``lpassh-add`` works just like `OpenSSh <https://www.openssh.com>`_'s
``ssh-add``, that is, it unlocks your SSh private keys, but it retrieves
the passphrases for those keys from LastPass, if possible. It is a *dumb*
wrapper around ``ssh-add`` and the `LastPass command line client
<https://github.com/lastpass/lastpass-cli>`_.

``lpassh-add`` is but a short-ish shell script. (It's about 255 lines of
code.) So you can easily check that it doesn't do anything funky.


SYNOPSIS
========

``lpassh-add`` accepts the same arguments as ``ssh-add``.


DESCRIPTION
===========

``lpassh-add`` adds SSh keys to the SSh agent, just as ``ssh-add`` would.
However, it looks up the passphrases for those keys in LastPass. It only asks
you for the passphrase for a key if it can't find that passphrase there.


Mode of operation
-----------------

``lpassh-add`` calls ``ssh-add``, but sets itself as ``SSH_ASKPASS`` utility.

Consequently, ``ssh-add`` calls ``lpassh-add`` again.

``lpassh-add`` then:

1. extracts the filename of the private key from the passphrase prompt,
2. uses that filename to locate the corresponding public key file,
3. searches LastPass for a Secure Note that lists that public key, and
4. passes on the passphrase stored in that note to ``ssh-add``.

If it doesn't find the passphrase of a key in LastPass, it asks you for it.

If you're not logged into LastPass, but ``LPASSH_ADD_USERNAME`` is set,
``lpassh-add`` logs you into LastPass. It also logs you out again.


Where to store SSh keys
-----------------------

*Filesystem:* You need to store public and private keys in the same directory,
with the filename of the public key being that of the private key, save for
additionally ending with '.pub'. (This is what OpenSSh does by default.)
For example:

.. image:: illustration-keys.png
  :height: 762px
  :width: 539px
  :align: center
  :alt: Screenshot of a terminal client showing files.

*LastPass:* You need to store the passphrase for each of your private SSh keys
in the "Passphrase" field of a so-called Secure Note of the type "SSH Key". You
also need to store the public key that corresponds to that private key in the
"Public Key" field of that note, so that ``lpassh-add`` can identify the entry
for that key. Moreover, you need to place such Secure Notes in a folder named
"SSh keys". You can pick another folder by setting the environment variable
``LPASSH_ADD_FOLDER``.
For example:

.. image:: illustration-lpass.png
   :height: 600px
   :width: 395px
   :align: center
   :alt: Screenshot of the LastPass client showing an entry for an SSh key.


ENVIRONMENT
===========

+----------------------------+-----------------------------------------------+
| Variable                   | Description                                   |
+============================+===============================================+
| LPASSH_ADD_LASTPASS_FOLDER | LastPass folder you store your SSh keys in.   |
|                            +-----------------------------------------------+
|                            | Default: "SSh keys"                           |
+----------------------------+-----------------------------------------------+
| LPASSH_ADD_USERNAME        | A LastPass username. If set, ``lpassh-add``   |
|                            | uses this username to log you into LastPass   |
|                            | if you are not logged in already.             |
|                            | If ``lpassh-add`` logs you in, it will also   |
|                            | log you out once it's done.                   |
|                            +-----------------------------------------------+
|                            | Default: *none*                               |
+----------------------------+-----------------------------------------------+
| LPASSH_ADD_KEYS            | A list of absolute paths to OpenSSh private   |
|                            | keys, separated by colons (':'); for example: |
|                            | "$HOME/.ssh/id_ed25519:$HOME/.ssh/id_rsa".    |
|                            | If set to a non-empty value, ``lpassh-add``   |
|                            | will ignore other keys.                       |
|                            +-----------------------------------------------+
|                            | Default: *empty* (Try all keys.)              |
+----------------------------+-----------------------------------------------+
| LPASSH_ADD_IGNORE_KEYS     | A list of absolute paths to OpenSSh private   |
|                            | keys, separated by colons (':'); for example: |
|                            | "$HOME/.ssh/id_rsa". If set to a non-empty    |
|                            | value, ``lpassh-add`` will ignore those keys. |
|                            +-----------------------------------------------+
|                            | Default: *empty* (Don't ignore any key.)      |
+----------------------------+-----------------------------------------------+
| SSH_ASKPASS                | Utility to ask for passphrases you didn't     |
|                            | store in LastPass if STDIN is not a terminal. |
|                            +-----------------------------------------------+
|                            | Default: *none*                               |
+----------------------------+-----------------------------------------------+


SECURITY
========

``lpassh-add`` is but a shell script. You should read the source code and
evaluate the security risks yourself. Above all, since ``lpass-add`` is
but a wrapper around OpenSSh and the LastPass command line client, their
threat models apply.

``lpass-add`` itself trusts your system (i.e., your terminal emulator,
the shell, the utilities it calls, etc.), the LastPass command line client,
and your environment. That said, it overrides the environment variables
``PATH``, ``IFS``, ``LPASS_AGENT_DISABLE``, ``LPASS_DISABLE_PINENTRY``,
``LPASS_PINENTRY``, and ``LPASS_AUTO_SYNC_TIME``. Moreover, it checks
the permissions of the utility that ``SSH_ASKPASS`` points to.

``lpassh-add`` does *not* use the LastPass agent. This is because every
programme that runs under your user (or as the superuser) can get a copy
of your password database while the LastPass agent is running, by calling
``lpass export``. This conforms to their threat model, but it may still
make you feel uneasy.

*Note:* ``lpass`` reads environment settings from ``$HOME/.lpass/env``,
so you can still override these settings.

You should be aware that if you do *not* set ``SSH_ASKPASS``, ``lpassh_add``
will prompt you for passphrases and read them from the TTY of the process.
However, it does *not* have exclusive access to that TTY, so any other process
that runs under your user (or as the superuser) can also read that TTY.
(This is true for *any* programme that prompts you for a password and reads
the answer from a TTY, including ``ssh-add``.) So set ``SSH_ASKPASS``.


CAVEATS
=======

``lpassh-add`` ignores your ``PATH`` and ``IFS`` as well as some of LastPass'
environment variables (see *Security* above for details).


INSTALLATION
============

You use ``lpassh-add`` **at your own risk**. You have been warned.


System requirements
-------------------

You need:

1. `OpenSSh <https://www.openssh.com>`_
2. The `LastPass command line client
   <https://github.com/lastpass/lastpass-cli>`_

Apart from OpenSSh and the LastPass command line client, ``lpassh_add`` is
`POSIX.1-2017 <http://pubs.opengroup.org/onlinepubs/9699919799/>`_ compliant.
So it should work on any modern Unix system (e.g., macOS, FreeBSD, NetBSD,
OpenBSD, Linux). ``lpassh-add`` also aims to be `System V Release 4.2
<https://www.in-ulm.de/~mascheck/bourne/>`_ compatible. So it should also
work on many older Unix systems (you may need to change the shebang line
though).

``lpassh_add`` is known to work with:

+-------------------------+----------+
| Bourne-compatible shell | version  |
+=========================+==========+
| bash                    | 3.2.57   |
+-------------------------+----------+
| dash                    | 0.5.10.2 |
+-------------------------+----------+
| yash                    | 2.49     |
+-------------------------+----------+
| zsh                     | 5.3      |
+-------------------------+----------+


Download
--------

Download the repository from:
<https://codeload.github.com/odkr/lpassh-add/tar.gz/v1.0.5>


Set-up
------

Unpack the repository, copy ``lpassh-add`` to a directory in your ``PATH``,
and make it executable. You may also want to install the manual page.

If you have `curl <https://curl.haxx.se/>`_ or
`wget <https://www.gnu.org/software/wget/>`_,
you can do so by::

    NAME=lpassh-add VERS=1.0.5
    PROG="${NAME:?}-${VERS:?}/${NAME:?}"
    URL="https://github.com/odkr/${NAME:?}/archive/v${VERS:?}.tar.gz"
    {
        curl -L "$URL" || ERR=$?
        [ "${ERR-0}" -eq 127 ] && wget -q -O - "$URL"
    } | tar -xz
    # Check the source!
    more "${PROG:?}"
    # If you like what you've seen, continue by:
    sudo mkdir -pm 0755 /usr/local/bin
    sudo cp "${PROG:?}" /usr/local/bin
    sudo cp "${PROG:?}.1.man" /usr/local/share/man/man1

*Note:* ``lpassh-add`` *must* reside in a directory that's in your ``PATH``,
or else ``ssh-add`` won't be able to find it.


DOCUMENTATION
=============

See the manual.


CONCTACT
========

If there's something wrong with ``lpassh-add``, `open an issue
<https://github.com/odkr/lpassh-add/issues>`_.


LICENSE
=======

Copyright 2018, 2019, 2020 Odin Kroeger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


FURTHER INFORMATION
===================

GitHub:
<https://github.com/odkr/lpassh-add>
