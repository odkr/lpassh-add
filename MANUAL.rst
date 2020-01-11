NAME
====

**lpassh-add** - Unlocks SSH keys using LastPass


SYNOPSIS
========

**lpassh-add** [**-cq**] [**-t** *LIFETIME*] [*KEY* [*KEY* [...]]]

**lpassh-add** **-h**

**lpassh-add** **-V**


DESCRIPTION
===========

**lpassh-add** adds *KEY* to the SSH authentication agent, just as **ssh-add**
would, but looks up the passphrase for *KEY* in LastPass. If it can't find it
there, it passes the *KEY* to **ssh-add**, which will ask you for it.

If you don't give any *KEY*, it tries ``~/.ssh/id_rsa``, ``~/.ssh/id_dsa``,
``~/.ssh/id_ecdsa``, and ``~/.ssh/id_ed25519``.

If you're not logged into LastPass and ``LPASSH_ADD_USERNAME`` is set,
**lpassh-add** logs you into LastPass; it also logs you out again when
it's done.


OPTIONS
=======

\-c
   Confirm every use of an identity.
   Note, for this to work `SSH_ASKPASS` must be set when
   the SSH authentication agent starts.

\-h
   Show help.

\-q
   Be quieter.

\-t **LIFETIME**
   Automatically re-lock keys after **LIFETIME**.

\-V
   Show version.

**-c**, **-q**, and **-t** are simply passed through to **ssh-add**.
See **ssh-add**(1) for details about those options.


WHERE TO STORE PASSPHRASES IN LASTPASS
======================================

You need to store the passphrase for each of your private SSH keys in the
"Passphrase" field of a so-called Secure Note of the type "SSH Key". You
also need to include "ssh" in the name of that Secure Note or in the name
of the folder that you place that note in.

You can change which Secure Notes **lpassh-add** should consider to describe
SSH keys by setting the environment variable ``LPASSH_ADD_PATH_REGEX``.
``LPASSH_ADD_PATH_REGEX`` is a basic regular expression. If the path of a
Secure Note matches this expression. **lpassh-add** considers that Secure
Note to describe an SSH key. If you don't set ``LPASSH_ADD_PATH_REGEX``,
**lpassh-add** uses the regular expression "ssh".

You can also make **lpassh-add** consider *every* item in your LastPass
database to describe an SSH key, namely, by setting ``LPASSH_ADD_PATH_REGEX``
to a regular expression that matches any string, the empty string (""), for
example. This is a *bad* idea. It's slow. It will likely pass passphrases
to **ssh-add** that are none of its business. And it will likely generate
a lot of warnings, even though those warnings are harmless.


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

**lpassh-add** is but a shell script. You should read the source code and
assess the security risks yourself. The threat models of OpenSSH and the
LastPass command line client apply.

**lpassh-add**  may, and often will, pass the passphrases of *all*
LastPass items the path of which matches the regular expression given
in ``LPASSH_ADD_PATH_REGEX`` to **ssh-add**.

If you're using the LastPass agent, any programme that runs under your (or
the superuser's) user ID can get a copy of your password database by calling
``lpass export`` while you're logged into LastPass and the agent is running.
This conforms to LastPass' threat model, but it may make you feel uneasy.
You can use **lpassh-add** *without* using the LastPass agent, by setting
``LPASSH_ADD_AGENT_DISABLE`` or ``LPASS_AGENT_DISABLE`` to 1. **lpassh-add**
will still only ask you for your LastPass password once. However, it will
store a copy of the LastPass master password in memory while it's running.
(If you're using the LastPass agent, it won't.)

If you do *not* set ``LPASS_ASKPASS`` or ``SSH_ASKPASS``, **lpassh-add** will
read passphrases from the teletype device of your terminal. However, it does
*not* have exclusive access to that device; any other process that runs under
your (or the superuser's) user ID can also read from that device. (This is
true for *any* programme that runs in a terminal and reads data from a
teletype device, including **ssh-add**.)


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
