#!/bin/sh

domain=$1
maildom="mail.$domain"

replace() { \
sed "s/<domain>/$domain/g;s/<maildom>/$maildom/g" $1
}

#
# install required software
#

pkg_add opensmtpd-extras opensmtpd-filter-rspamd dovecot dovecot-pigeonhole rspamd redis sieve &&

echo "\nInstalled required software\n" &&

#
# certs
#

replace files/acme-client.conf > /etc/acme-client.conf &&

replace files/httpd.conf > /etc/httpd.conf &&

rcctl enable httpd &&
rcctl start httpd &&

acme-client -v $maildom &&

replace files/daily.local > /etc/daily.local &&

echo "\nCreated and signed tls certificates (letencrypt)\n" &&

#
# vmail user & authentication
#

touch /etc/mail/credentials &&
chmod 0440 /etc/mail/credentials &&
chown _smtpd:_dovecot /etc/mail/credentials &&
useradd -c "Virtual Mail Account" -d /var/vmail -s /sbin/nologin \
    -u 2000 -g =uid -L staff vmail &&
mkdir -p /var/vmail &&
chown vmail:vmail /var/vmail &&

replace files/virtuals > /etc/mail/virtuals &&
replace files/newuser > ./newuser &&
chmod +x ./newuser &&

echo "\nCreated vmail user & authentication file\n" &&

#
# smtpd
#

replace files/smtpd.conf > /etc/smtpd.conf &&

echo "\nConfigured OpenSMTPD\n" &&

#
# dovecot
#

echo "dovecot:\\
        :openfiles-cur=1024:\\
        :openfiles-max=2048:\\
        :tc=daemon:
" >> /etc/login.conf &&

replace files/local.conf > /etc/dovecot/local.conf &&

sed "s/^ssl_cert/#ssl_cert/;s/^ssl_key/#ssl_key/" \
	/etc/dovecot/conf.d/10-ssl.conf > tempfile &&
mv tempfile /etc/dovecot/conf.d/10-ssl.conf &&

# setup training rspamd from email moving in and out of the Junk folder

mkdir -p /usr/local/lib/dovecot/sieve &&
cp files/report-ham.sieve /usr/local/lib/dovecot/sieve &&
cp files/report-spam.sieve /usr/local/lib/dovecot/sieve &&
sievec /usr/local/lib/dovecot/sieve/report-ham.sieve &&
sievec /usr/local/lib/dovecot/sieve/report-spam.sieve &&

cp files/sa-learn-ham.sh /usr/local/lib/dovecot/sieve/ &&
cp files/sa-learn-spam.sh /usr/local/lib/dovecot/sieve/ &&
chmod 0755 /usr/local/lib/dovecot/sieve/sa-learn-ham.sh &&
chmod 0755 /usr/local/lib/dovecot/sieve/sa-learn-spam.sh &&

rcctl enable dovecot &&
rcctl start dovecot &&

echo "\nConfigured Dovecot\n" &&

#
# rspamd
#

mkdir -p /etc/mail/dkim &&
openssl genrsa -out /etc/mail/dkim/$domain.key 1024 &&
openssl rsa -in /etc/mail/dkim/$domain.key \
	    -pubout -out /etc/mail/dkim/public.key &&
chmod 0440 /etc/mail/dkim/$domain.key &&
chown root:_rspamd /etc/mail/dkim/$domain.key &&

replace files/dkim_signing.conf > /etc/rspamd/local.d/dkim_signing.conf &&

rcctl enable redis rspamd &&
rcctl start redis rspamd &&
rcctl restart smtpd &&

echo "\nConfigured rspamd\n" &&

#
# dns
#

pub_key=$(cat /etc/mail/dkim/public.key | grep -v --- | tr -d '\n' ) &&

mkdir -p dns &&
echo "mail._domainkey.$domain. IN TXT \"v=DKIM1;k=rsa;p=$pub_key\"" > ./dns/dkim-record &&
echo "$domain. IN TXT \"v=spf1 mx -all\"" > ./dns/spf-record &&
echo "_dmarc.$domain. IN TXT \"v=DMARC1;p=none;pct=100;rua=mailto:postmaster@$domain\"" > ./dns/dmarc-record &&

echo "\nWrote relevant dns records in ./dns/\n" &&
# TODO: does .forward work with virtual users?
echo \
"The creation of an admin account is required for this setup! Email to
it can be forwarded to an email address written in:
/var/vmail/$domain/admin/.forward
New users can be similarly added by running ./newuser. Please use the
username \"admin\" and a password of your choosing" &&

./newuser &&
rcctl restart smtpd
