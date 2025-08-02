#!/bin/bash
#
if ! systemctl is-active --quiet nginx;
then
    instalar yum-utils
    cp $installation_dir/conf/nginx.repo /etc/yum.repos.d/

    instalar nginx
fi


#añadir configuraciones de nginx
cp $installation_dir/conf/nginx.conf /etc/nginx/

mkdir -p /etc/nginx/keys

cp $SSL_CERTIFICATE /etc/nginx/keys
cp $SSL_CERTIFICATE_KEY /etc/nginx/keys

##check if directories exist
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

cat $installation_dir/conf/site > /etc/nginx/sites-available/$DOMAIN

sed -i "s/DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/CERTIFICATE/$SSL_CERTIFICATE_NAME/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/KEY/$SSL_CERTIFICATE_KEY_NAME/g" /etc/nginx/sites-available/$DOMAIN

ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/


systemctl enable --now nginx

