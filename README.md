## About

mmv - minimal mailserver virtual

mmv is a script for setting up a personal email server on OpenBSD using
virtual users. It allows one to host email for multiple domains on the
same server. It also sets up a tor hidden service by default so that one
can fetch email from public WiFi anonymously.

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

After everything is in place, you can use the newly installed scripts to
manage user accounts.

To add a user:      (you'll be prompted for a password)

    madduser username@domain.tld

To delete a user:

    mdeluser username@domain.tld

To change a user's password:

    mpasswd username@domain.tld

## Troubleshooting

If the script fails to sign the TLS certificate, it's likely that
OpenSMTPD and Dovecot will show up as failed. In most cases just getting
the certificate will fix them because they are just failing to load it.
