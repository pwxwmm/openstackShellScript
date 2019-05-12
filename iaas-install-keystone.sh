#!/bin/bash
source /etc/xiandian/openrc.sh
yum install -y openstack-keystone httpd mod_wsgi


mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS keystone ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS' ;"

crudini --set /etc/keystone/keystone.conf database connection  mysql+pymysql://keystone:$KEYSTONE_DBPASS@$HOST_NAME/keystone
ADMIN_TOKEN=$(openssl rand -hex 10)
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
crudini --set /etc/keystone/keystone.conf token provider  fernet
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sed -i "s/#ServerName www.example.com:80/ServerName $HOST_NAME/g" /etc/httpd/conf/httpd.conf
cat >/etc/httpd/conf.d/wsgi-keystone.conf<<- EOF
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
