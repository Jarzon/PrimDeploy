cat << EOF > /etc/apache2/conf-available/custom.conf
ServerTokens Prod
ServerSignature Off
EOF

cat << EOF > /etc/php/7.0/apache2/conf.d/custom.ini
date.timezone = America/New_York
sendmail_path = "sendmail -t -i"
session.gc_maxlifetime = 15552000
session.cookie_lifetime = 15552000
realpath_cache_size = 4096k
EOF

cat << EOF > /usr/share/logwatch/default.conf/custom.conf
MailTo = j@masterj.net
EOF

a2enmod rewrite && a2enmod expires && a2enmod ssl && a2enconf custom && service apache2 restart

echo "Generate ssl cert"

service apache2 stop
letsencrypt certonly --standalone -d masterj.net -d www.masterj.net
service apache2 start

echo "Add github auth token for satis"

composer config --global github-oauth.github.com ***REMOVED***

reboot