#!/bin/bash
#
source /etc/xiandian/openrc.sh
yum install openstack-dashboard -y

sed -i -e "s/^ALLOWED_HOSTS.*/ALLOWED_HOSTS = ['*','localhost']/g" \
-e "s/^OPENSTACK_HOST.*/OPENSTACK_HOST = \"$HOST_NAME\"/g" \
-e "s/^TIME_ZONE.*/TIME_ZONE = \"UTC\"/g" -e '133,138d' \
-e '128,133s/^#//' \
-e "128 i SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" \
-e "s/http:\/\/%s:5000\/v2.0/http:\/\/%s:5000\/v3/g" \
-e 's/#OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = False/OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True/g' \
-e '55,60s/^#//'  \
-e '56d' \
-e '72s/^#//' \
-e 's/OPENSTACK_KEYSTONE_DEFAULT_ROLE*.*/OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"/g' /etc/openstack-dashboard/local_settings
sed -i "s/SITE_BRANDING =.*/SITE_BRANDING = 'XianDian Dashboard'/g"  /usr/share/openstack-dashboard/openstack_dashboard/settings.py
sed -i '/WSGIScriptAlias\ \/\ \/usr\/share\/openstack-dashboard\/openstack_dashboard\/wsgi\/django.wsgi/d'  /etc/httpd/conf.d/openstack-dashboard
.conf
systemctl restart httpd.service memcached.service
