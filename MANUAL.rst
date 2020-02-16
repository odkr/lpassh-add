NAME
====

**lpassh-add** - Unlocks OpenSSH keys using LastPass


SYNOPSIS
========

**lpassh-add** [**-cq**] [**-t** *LIFETIME*] [*KEY* [*KEY* [...]]]

**lpassh-add** **-h**

**lpassh-add** **-V**


DESCRIPTION
===========

**lpassh-add** adds *KEY* to the SSH authentication agent, just as **ssh-add**
would, but looks up the passphrase for *KEY* in LastPass. If it can't find the
passphrase there, **ssh-add** will ask you for the passphrase instead.

If you don't give a *KEY*, it tries to add ``~/.ssh/id_rsa``,
``~/.ssh/id_dsa``, ``~/.ssh/id_ecdsa``, and ``~/.ssh/id_ed25519``.

If you're not logged into LastPass and ``LPASSH_ADD_USERNAME`` is set,
**lpassh-add** logs you into LastPass; it also logs you out again when
it's done.


OPTIONS
=======

\-c
   Confirm every use of a key.
   Note, for this to work ``SSH_ASKPASS`` must be set when
   the OpenSSH authentication agent starts.

\-h
   Show help.

\-q
   Be quieter.

\-t **LIFETIME**
   Automatically re-lock keys after **LIFETIME**.

\-V
   Show version.

**-c**, **-q**, and **-t** are simply passed through to **ssh-add**.
See **ssh-add**\ (1) for details about those options.


WHERE TO STORE PASSPHRASES IN LASTPASS
======================================

You need to store the passphrase for each of your private SSH keys in the
"Passphrase" field of a so-called Secure Note of the type "SSH Key". You
also need to include "ssh" in the name of that Secure Note or in the name
of the folder that you place that note in.

You can change which Secure Notes **lpassh-add** considers to describe
SSH keys by setting the environment variable ``LPASSH_ADD_PATH_REGEX``.
``LPASSH_ADD_PATH_REGEX`` is a basic regular expression. If the path of a
Secure Note matches this expression, **lpassh-add** considers that Secure
Note to describe an SSH key. If you don't set ``LPASSH_ADD_PATH_REGEX``,
**lpassh-add** uses the regular expression "ssh".

You can also make **lpassh-add** consider *every* item in your LastPass
database to describe an SSH key, namely, by setting ``LPASSH_ADD_PATH_REGEX``
to a regular expression that matches any string, the empty string (""), for
example. This is a *bad* idea. It's slow. It will likely pass passphrases
to **ssh-add** that are none of its business. And it will likely generate
a lot of warnings (those warnings are harmless, however).


ENVIRONMENT
===========

LPASSH_ADD_PATH_REGEX
   A basic regular expression. **lpassh-add** assumes that any item in your
   LastPass database the path of which matches this expression describes an
   SSH key. If you set this variable to a regular expression that matches any
   string, the empty string (""), for instance, then **lpassh-add** will
   assume that *every* item in your LastPass database describes an SSH key.
   This is a *bad* idea. (Default if not set: "ssh".)

LPASSH_ADD_USERNAME
   A LastPass username. If set, **lpassh-add** uses this username to log
   you into LastPass if you aren't logged in already.
   (Default if not set: Don't log into LastPass.)

LPASSH_ADD_AGENT_DISABLE
   0 (for false) or 1 (for true). Whether **lpassh-add** should use the
   LastPass agent. Any value other than 0 or 1 will be ignored.
   (Default if not set: Respect ``LPASS_AGENT_DISABLE``.)

LPASS_ASKPASS
   Utility to ask for passphrases. Takes precedence over ``SSH_ASKPASS``.
   (Default if not set: Ask on teletype device of your terminal.)

SSH_ASKPASS
   Utility to ask for passphrases. Only used if ``LPASS_ASKPASS`` *isn't* set.
   (Default if not set: Ask on teletype device of your terminal.)


SECURITY
========

Basics
------

**lpassh-add** is only a shell script.

How secure a shell script is depends *a lot* on what shell you're running
it with. **ksh**, for example, creates temporary files to handle command
substitutions (i.e., ```...``` expressions) unless the command is built into
**ksh**. As a consequence, **ksh** will write your LastPass master password
to a temporary file if you do *not* use the LastPass agent *and* use an
askpass utility. Keep in mind that your **sh** may be a symlink to **ksh**.
That said, this is just an example. There are a lot of shells out there.
Use a reasonably modern and mainstream one, if possible. **bash** v5.0.11(1),
**dash** v0.5.10.2, **mksh** R57, **oksh** v5.2.14, **yash** v2.49, and
**zsh** v5.7.1 should all be fine.

You may want to read **lpassh-add** and assess the security risks yourself.

You may also want to trace what system calls your shell makes when it runs
**lpassh-add**, particularly if the shell you're running it with isn't
reasonably modern or mainstream.

The threat models of **ssh-add** and **lpass** apply.

Behaviour
---------

**lpassh-add**  may, and often will, pass the passphrases of *all*
LastPass items the path of which matches the regular expression given
in ``LPASSH_ADD_PATH_REGEX`` to **ssh-add**.

The LastPass agent
------------------

If you're using the LastPass agent, any programme that runs under your (or
the superuser's) user ID can get a copy of your password database by calling
``lpass export`` while you're logged in.

You can use **lpassh-add** *without* using the LastPass agent, by setting
``LPASSH_ADD_AGENT_DISABLE`` or ``LPASS_AGENT_DISABLE`` to 1. **lpassh-add**
will still only ask you for your LastPass password once.

However:

* **lpassh-add** will store a copy of that password in memory.

* If you do set ``LPASS_ASKPASS`` or ``SSH_ASKPASS``, **lpassh-add**
  may write your LastPass master password to a temporary file,
  depending on what shell you use to run it.

* If you do *not* set ``LPASS_ASKPASS`` or ``SSH_ASKPASS``, **lpassh-add**
  reads your LastPass master password from your terminal's teletype device.
  It does *not* have exclusive access to that device. (Neither do the
  LastPass agent or **ssh-add** for that matter.)

Of course, every process that can invoke ``lpass export`` can also change
your environment so that **lpassh-add** and **lpass** use the LastPass
agent. Disabling the LastPass agent, therefore, only improves your security
if it's a part of a more encompassing, and highly complex, policy.


EXIT STATUS
===========

0
   Success.

64
   Usage error.

69
   Any other error.

70
   Bug.

> 128
   Terminated by a signal.

Other non-zero status
   Unexpected error.

**lpassh-add** may exit with other statuses on some systems or when run
by some shells (e.g., **zsh**). However, you can safely assume that 0
indicates success and non-zero failure.


AUTHOR
======

Copyright 2018, 2019, 2020 Odin Kroeger


SEE ALSO
========

**lpass**\ (1), **ssh-add**\ (1)

https://github.com/odkr/lpassh-add
