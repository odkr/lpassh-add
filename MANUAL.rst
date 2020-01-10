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

**lpassh-add** adds **KEY** to the SSH authentication agent, just as
**ssh-add** would, but looks up the passphrase for **KEY** in LastPass.
If it can't find it there, it asks you for it.

If you don't give any **KEY**, it tries to add ``~/.ssh/id_rsa``,
``~/.ssh/id_dsa``, ``~/.ssh/id_ecdsa``, and ``~/.ssh/id_ed25519``,
ignoring those that don't exist.

If you're not logged into LastPass and ``LPASSH_ADD_USERNAME`` is set,
**lpassh-add** logs you into LastPass; it also logs you out again when
it's done.

If you try to unlock multiple keys, **lpassh-add** always retries the last
passphrase, regardless of whether it found that passphrase in LastPass or
you've just entered it. So, if you use the same passphrase for all keys, it
will stop quering LastPass or you once it has encountered that passphrase.


OPTIONS
=======

Most of these options are simply passed through to **ssh-add**.

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


WHERE TO STORE PASSPHRASES IN LASTPASS
======================================

You need to store the passphrase for each of your private SSH keys in
the "Passphrase" field of a so-called Secure Note of the type "SSH Key".
You also need to include "ssh" in the name of that Secure Note or in the
name of the folder that you place that note in.

You can change which Secure Notes and folders **lpassh-add** tries by
setting the environment variable ``LPASSH_ADD_LPASS_PATH_REGEX``.

You can also make **lpassh-add** try *every* item in your LastPass database
to describe an SSH key, by setting ``LPASSH_ADD_LPASS_PATH_REGEX`` to the
empty string ("") or any other regular expression that matches any string.
This is a *bad* idea. It's slow. It will likely pass passphrases to
**ssh-add** that are none of its business. And it will likely generate a lot
of warnings; these are harmless, however.


ENVIRONMENT
===========

LPASSH_ADD_LPASS_PATH_REGEX
   A basic regular expression. **lpassh-add** assumes that any item in your
   LastPass database the path of which matches this expression describes an
   SSH key. If you set this variable to the empty string ("") or any other
   expression that matches any string, **lpassh-add** will assume that *every*
   item in your LastPass database describes an SSH key. This is a *bad* idea.
   (Default if not set: "ssh".)

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

**lpassh-add** is but a shell script. You should read the source code
and assess the security risks yourself. Above all, since **lpassh-add**
is a wrapper around OpenSSH and the LastPass command line client, their
threat models apply.

**lpassh-add** trusts your system (i.e., your terminal, your shell, the
utilities it calls, etc.), OpenSSH, the LastPass command line client,
whatever utility you have set in ``LPASS_ASKPASS`` or ``SSH_ASKPASS``,
and your environment.

**lpassh-add** stores the passphrases of all LastPass itemes that match
the regular expression given in ``LPASSH_ADD_LPASS_PATH_REGEX`` in
memory. It also may pass all of those passphrases to **ssh-add**.

If you're using the LastPass agent, any programme you (or the superuser)
run can get a copy of your password database by calling ``lpass export``
while the agent is running. This conforms to LastPass' threat model, but
it may make you feel uneasy. You can use **lpassh-add** *without* using
the LastPass agent, by setting ``LPASSH_ADD_AGENT_DISABLE`` or
``LPASS_AGENT_DISABLE`` to 1. **lpassh-add** will still only ask you for
your LastPass password once. However, it will then store a copy of the
LastPass master password in memory while it's running. (If you're using
the LastPass agent, it won't.)

If you do *not* set ``LPASS_ASKPASS`` or ``SSH_ASKPASS``, **lpassh-add**
will read passphrases from the teletype device of your terminal.
However, it does *not* have exclusive access to that device; any other
process that you (or the superuser) runs can also read from that device.
(This is true for *any* programme that reads data from a teletype
device, including **ssh-add**.)


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


CAVEATS
=======

**lpassh-add** ignores your ``PATH`` and ``IFS`` as well as some of
LastPass' environment variables.


AUTHOR
======

Copyright 2018, 2019, 2020 Odin Kroeger


SEE ALSO
========

**lpass**\ (1), **ssh-add**\ (1)

https://github.com/odkr/lpassh-add
