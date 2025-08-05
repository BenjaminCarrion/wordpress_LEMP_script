#!/bin/bash

section "Configurando PHP y PHP-FPM"

if [ ! -e "/etc/yum.repos.d/remi.repo" ]; then
    echo -e "${CINFO} Repositorios Remi y EPEL no detectados. Agregando...${CEND}"
    instalar https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
    instalar https://rpms.remirepo.net/enterprise/remi-release-9.rpm
    dnf module enable -y php:remi-8.4 &> /dev/null
    dnf makecache &> /dev/null
    echo -e "${CSUCCESS} Repositorios configurados correctamente.${CEND}"
fi

# --- Si PHP esta corriendo no instalar ---
if ! systemctl is-active --quiet php-fpm.service; then

    echo -e "${CINFO} Instalando PHP y módulos requeridos...${CEND}"

    instalar php php-cli php-fpm php-xml php-mbstring php-mysqli php-json php-curl php-dom php-exif php-fileinfo php-hash php-igbinary php-imagick php-intl php-openssl php-pcre php-zip php-gd

    echo -e "${CINFO} Aplicando ajustes de configuración en /etc/php.ini...${CEND}"

    sed -i -e 's/^max_execution_time = .*/max_execution_time = 180/' \
           -e 's/^max_input_time = .*/max_input_time = 300/' \
           -e 's/^expose_php = .*/expose_php = Off/' \
           -e 's/^post_max_size = .*/post_max_size = 64M/' \
           -e 's/^upload_max_filesize = .*/upload_max_filesize = 64M/' \
           -e 's/^mysqli.allow_persistent = .*/mysqli.allow_persistent = Off/' \
           -e 's/^;date.timezone =/date.timezone = "America\/Guayaquil"/' \
           -e 's@^mysqli.default_socket =@mysqli.default_socket = /var/lib/mysql/mysql.sock@' \
           /etc/php.ini

    #pm proccess should be tuned on system resources
    echo -e "${CINFO} Ajustando configuración de PHP-FPM...${CEND}"
    sed -i -e "s/nobody/nginx/g" -e "s/apache$/nginx/g" /etc/php-fpm.d/www.conf

    #ignore due to acl allows nginx read and write the unix socket
    #sed -i '/^;listen\.\(owner\|group\|mode\)/s/^;//' /etc/php-fpm.d/www.conf


    echo -e "${CINFO} Optimizando parámetros de Zend OPcache...${CEND}"
    sed -i -e 's/^opcache.memory_consumption=.*/opcache.memory_consumption=256/' \
           -e 's/^opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/' \
           -e 's/^opcache.use_cwd=.*/opcache.use_cwd=1/' \
           /etc/php.d/10-opcache.ini

    systemctl enable --now php-fpm
    echo -e "${CSUCCESS} PHP-FPM instalado y ejecutándose.${CEND}"
fi

