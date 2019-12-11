==========
lpassh-add
==========

``lpassh-add`` works just like `OpenSSh <https://www.openssh.com>`_'s
``ssh-add``, that is, it unlocks your SSh private keys, but it retrieves
the passphrases for those keys from LastPass, if possible; otherwise, it
asks for the passphrase, just as ``ssh-add`` would do. It is a *dumb*
wrapper around ``ssh-add`` and the `LastPass command line client
<https://github.com/lastpass/lastpass-cli>`_.


Synopsis
========

``lpassh-add`` accepts the same arguments as ``ssh-add``.


Description
===========

``lpassh-add`` will add all keys you have stored passphrases for in LastPass
and query you for the remaining ones.

It does so by calling ``ssh-add``, but setting itself as ``SSH_ASKPASS``
utility. Therefore, ``ssh-add`` will call ``lpassh-add`` again. 
``lpassh-add`` then:

1. extracts the filename of the private key from the passphrase prompt,
2. uses that filename to locate the corresponding public key file,
3. reads that key from that file,
4. searches LastPass for a Secure Note that lists that key, and, 
   if it finds one,
5. passes the passphrase stored in that note on to ``ssh-add``.

If it doesn't find the passphrase, it asks you for it.

If you're not logged into LastPass, but ``LPASSH_ADD_USERNAME`` is set,
``lpassh-add`` logs you into LastPass. Once ``lpassh-add`` is done, if it
has logged you in, it logs you out again.


Where to store SSh keys
=======================

Filesystem
----------

``lpassh-add`` expects that you store public and private keys in the same
directory, whichever it is, with the filename of the public key being the 
same as that of the private key save for also ending in '.pub'. This is 
what OpenSSh does by default.

For example:

.. image:: illustration-keys.png
  :height: 762px
  :width: 539px
  :align: center
  :alt: Screenshot of the terminal client showing files.

LastPass
--------

``lpassh-add`` expects that:

1. You have a folder named "SSh keys" in your LastPass account (you can pick a
   different folder by setting the environment variable ``LPASSH_ADD_FOLDER``);
   that folder contain all your SSh key pairs as Secure Notes;
   and those notes are of the Note Type "SSH Key" .
2. You store, for each key pair:
   (a) the passphrase for the private key under "Passphrase" and
   (b) the corresponding public key, that is, the contents of the
   corresponding ``~/.ssh/id_*.pub`` file, under "Public Key", like so:

.. image:: illustration-lpass.png
   :height: 600px
   :width: 395px
   :align: center
   :alt: Screenshot of the LastPass client.


Security
========

``lpassh-add`` is but a shell script. You should read the source code and
evaluate the security risks yourself. Above all, since ``lpass-add`` is
but a wrapper around OpenSSh and the LastPass command line client, their
threat models apply.

``lpass-add`` itself trusts your system (i.e., your terminal emulator, 
the shell, the utilities it calls, etc.), the LastPass command line client,
and your environment. That said, it overrides the environment variables
``PATH``, ``IFS``, ``HOME``, ``LPASS_AGENT_DISABLE``, 
``LPASS_DISABLE_PINENTRY``, ``LPASS_PINENTRY``, and ``LPASS_AUTO_SYNC_TIME``,
all of which it overrides. Moreover, it checks the permissions of the utility
``SSH_ASKPASS`` points to, but only cursorily.

Note, ``lpass`` reads environment settings from ``$HOME/.lpass/env``,
so you can still override these settings.

You should be aware that if you do *not* set ``SSH_ASKPASS``, ``lpassh_add``
will prompt you for passphrases and read them from the TTY of the process.
However, it does *not* have exclusive access to that TTY, so any other process
that runs under your user (or as the superuser) can also read that TTY.
(This is true for *any* programme that prompts you for a password and reads
the answer from a TTY, including ``ssh-add``.) So set ``SSH_ASKPASS``.

``lpassh-add`` does *not* use the LastPass agent. This is because, while the
LastPass agent is running, every programme that runs under your user (or as
the superuser) can get a copy of your password database, simply by calling
``lpass export``. This conforms to their threat model, but it may still make
you feel uneasy.

As a consequence of *not* using the LastPass agent, you have to enter your
LastPass master password once for every SSh key that you want to add to the
SSh agent. However, ``ssh-add`` re-tries the last passphrase you entered for
all subsequent keys. So if you use the same passphrase for all your SSh keys
and store that passphrase in LastPass, you only have to enter your LastPass
master password once.

Also, ``lpassh-add`` is but a short-ish shell script (it's about 220 lines of
code). So you can easily check that it doesn't do anything fishy.


Environment
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


Caveats
=======

``lpassh-add`` ignores your ``PATH`` and ``IFS`` as well as some LastPass
environment variables (see *Security* above for details).


Getting ``lpassh-add``
====================

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
OpenBSD, Linux). ``lpassh-add`` also aims to be `System V Release 4
<https://www.in-ulm.de/~mascheck/bourne/>`_ compatible. So it should also
work on many older Unix systems (you may need to change the shebang line
though).


Download
--------

Download the repository from:
<https://codeload.github.com/odkr/lpassh-add/tar.gz/v1.0.4>


Installation
------------

Unpack the repository, copy ``lpassh-add`` to a directory in your ``PATH``
-- */usr/local/bin* is a good choice --, and make it executable. You may
also want to install the manual page.

You can do this by::

    curl https://codeload.github.com/odkr/lpassh-add/tar.gz/v1.0.4 | tar -xz
    # Check the source!
    more lpassh-add-1.0.4/lpassh-add
    # If -- and only if -- you like what you see, continue by:
    sudo mkdir -pm 0755 /usr/local/bin
    sudo cp lpassh-add-1.0.4/lpassh-add /usr/local/bin
    sudo cp lpassh-add.1.man /usr/local/share/man/man1

There isn't much of a point in keeping the repository around,
so you may then wish to delete it by saying::

    rm -rf lpassh-add-1.0.4


Documentation
=============

See the manual page.


Contact
=======

If there's something wrong with ``lpassh-add``, `open an issue
<https://github.com/odkr/lpassh-add/issues>`_.


License
=======

Copyright 2018, 2019 Odin Kroeger

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


Further Information
===================

GitHub:
<https://github.com/odkr/lpassh-add>
