## About

mmv - minimal mailserver virtual

mmv is a script for setting up a personal email server on OpenBSD using
virtual users.

As you might have guessed, there also exists a fork -
[mms](https://git.yotsev.xyz/mms) - that uses system users.

WARNING: The script is still in development and liable to drastic
changes with no backwards compatibility.

## Prerequisites

The script automates as much as possible but there is one thing out of
its reach - dns. You'll need a valid A and/or AAAA record for the domain
you're going to use and for a subdomain `mail.domain.tld`.

## Installation

    git clone git://git.yotsev.xyz/mmv.git
    cd mmv
    ./setup.sh domain.tld

## Post-execution

After the script has finished executing successfully, it will have
written dns record that you have to paste into your name server or your
registrar's interface.

## Usage

After everything is in place, you can use the newly created script
`newuser` to add a user account.

    ./newuser
