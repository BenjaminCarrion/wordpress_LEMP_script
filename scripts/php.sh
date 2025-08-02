#!/bin/bash

if [ ! -e "/etc/yum.repos.d/remi.repo" ] ; then
    #add remi repo
    instalar https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
    instalar https://rpms.remirepo.net/enterprise/remi-release-9.rpm
    dnf module enable -y php:remi-8.4
    dnf makecache
fi


#if php is runing don't install it 
if ! systemctl is-active --quiet php-fpm.service;
then

    ##install php 
    instalar php php-cli php-fpm php-xml php-mbstring php-mysqli php-json php-curl php-dom php-exif php-fileinfo php-hash php-igbinary php-imagick php-intl php-openssl php-pcre php-zip php-gd

    #Improvement for php
    sed -i -e 's/^max_execution_time = .*/max_execution_time = 180/' \
           -e 's/^max_input_time = .*/max_input_time = 300/' \
           -e 's/^expose_php = .*/expose_php = Off/' \
           -e 's/^post_max_size = .*/post_max_size = 64M/' \
           -e 's/^upload_max_filesize = .*/upload_max_filesize = 64M/' \
           -e 's/^mysqli.allow_persistent = .*/mysqli.allow_persistent = Off/' \
           -e 's/^;date.timezone =/date.timezone = "America\/Guayaquil"/' \
           -e 's@^mysqli.default_socket =@mysqli.default_socket = /var/lib/mysql/mysql.sock@' \
           /etc/php.ini

    #Improvement for php-fpm
    #pm proccess should be tuned on system resources
    sed -i -e "s/nobody/nginx/g" -e "s/apache$/nginx/g"  /etc/php-fpm.d/www.conf

    #ignore due to acl allows nginx read and write the unix socket
    #sed -i '/^;listen\.\(owner\|group\|mode\)/s/^;//' /etc/php-fpm.d/www.conf

    #Improvement for php Zend opcache 
    sed -i -e 's/^opcache.memory_consumption=.*/opcache.memory_consumption=256/' \
           -e 's/^opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/' \
           -e 's/^opcache.use_cwd=.*/opcache.use_cwd=1/' \
           /etc/php.d/10-opcache.ini

    systemctl enable --now php-fpm
fi

