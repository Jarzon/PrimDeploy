cat << EOF > /etc/apache2/conf-available/custom.conf
ServerTokens Prod
ServerSignature Off
EOF

cat << EOF > /etc/php/7.0/apache2/conf.d/custom.ini
date.timezone = America/New_York
extension=pdo_mysql.so
sendmail_path = "sendmail -t -i"
EOF

cat << EOF > /usr/share/logwatch/default.conf/custom.conf
MailTo = j@masterj.net
MailFrom = j@masterj.net
EOF

cat << 'EOF' > /etc/postfix/main.cf
#myorigin = /etc/mailname

smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

readme_directory = no

# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = vps69045.vps.ovh.ca
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = $myhostname, vps69045.vps.ovh.ca, localhost.vps.ovh.ca, , localhost
relayhost = [smtp.masterj.net]:587
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all
# enable SASL authentication
smtp_sasl_auth_enable = yes
# disallow methods that allow anonymous authentication.
smtp_sasl_security_options = noanonymous
# where to find sasl_passwd
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
# Enable STARTTLS encryption
smtp_use_tls = yes
# where to find CA certificates
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
EOF

cat << EOF > /etc/postfix/sasl_passwd
[smtp.masterj.net]:587 j@masterj.net:***REMOVED***
EOF

postmap hash:/etc/postfix/sasl_passwd

a2enmod rewrite && a2enmod expires && a2enmod ssl && a2enconf custom && service apache2 restart

echo "Generate ssl cert"

service apache2 stop
letsencrypt certonly --standalone -d masterj.net -d www.masterj.net
service apache2 start

echo "Add github auth token for satis"

composer config --global github-oauth.github.com ***REMOVED***

reboot