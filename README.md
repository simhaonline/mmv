## About

mmv - minimal mailserver virtual

mmv is a script for setting up a personal email server on OpenBSD using
virtual users. It allows one to host email for multiple domains on the
same server. It also sets up a tor hidden service by default so that one
can fetch email from public WiFi anonymously.

WARNING: The script is still in development and liable to drastic
changes with no backwards compatibility.

## Prerequisites

The script automates as much as possible but there is one thing out of
its reach - DNS. If your email is `user@example.com`, you'll need A/AAAA
records for `mail.example.com`.

## Installation

    git clone git://git.yotsev.xyz/mmv.git
    cd mmv
    ./mmv example.com

If you want to add another domain, simply run the script again:

    ./mmv another-domain.tld

## Post-execution

After the script has finished executing successfully, it will have
written DNS record that you have to paste into your name server or your
registrar's interface.

## Usage

After everything is in place, you can use the newly created script
`madduser` to add a user account. You'll be prompted for a password.

    madduser DOMAIN USERNAME

You can similarly delete users with `mdeluser`.

    mdeluser DOMAIN USERNAME

And change a password with `mpasswd`.

    mpasswd DOMAIN USERNAME

# Troubleshooting

If the script fails to sign the TLS certificate, it's likely that
OpenSMTPD and Dovecot will show up as failed. In most cases just getting
the certificate will fix them because they are just failing to load
them.
