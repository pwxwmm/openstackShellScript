#!/bin/bash
source /etc/xiandian/openrc.sh
ping $HOST_IP -c 4 >> /dev/null 2>&1
if [ 0  -ne  $? ]; then
        echo -e "\033[31m Warning\nPlease make sure the network configuration is correct!\033[0m"
        exit 1
fi
# check system

sed -i  -e '/server/d' -e "/fudge/d" /etc/ntp.conf
sed -i  -e "1i server 127.127.1.0" -e "2i fudge 127.127.1.0 stratum 10" /etc/ntp.conf
systemctl restart ntpd
systemctl enable ntpd


yum install mariadb mariadb-server python2-PyMySQL expect mongodb-server mongodb rabbitmq-server memcached python-memcached -y
sed -i  "/^symbolic-links/a\default-storage-engine = innodb\ninnodb_file_per_table\ncollation-server = utf8_general_ci\ninit-connect = 'SET NAMES
 utf8'\ncharacter-set-server = utf8\nmax_connections=10000" /etc/my.cnf
crudini --set /usr/lib/systemd/system/mariadb.service Service LimitNOFILE 10000
crudini --set /usr/lib/systemd/system/mariadb.service Service LimitNPROC 10000
systemctl daemon-reload
systemctl enable mariadb.service
systemctl restart mariadb.service
expect -c "
spawn /usr/bin/mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$DB_PASS\r\"
expect \"Re-enter new password:\"
send \"$DB_PASS\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"n\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
