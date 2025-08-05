#!/bin/bash

section "Configurando Nginx"

# --- Instalación de Nginx si no está activo ---
if ! systemctl is-active --quiet nginx; then
    echo -e "${CINFO} Nginx no está activo. Iniciando instalación...${CEND}"

    instalar yum-utils
    cp $installation_dir/conf/nginx.repo /etc/yum.repos.d/
    instalar nginx
fi

# --- Configuración principal para nginx---
cp $installation_dir/conf/nginx.conf /etc/nginx/

# --- Certificados para el sitio ---
mkdir -p /etc/nginx/keys

cp $SSL_CERTIFICATE /etc/nginx/keys/
cp $SSL_CERTIFICATE_KEY /etc/nginx/keys/

# --- Configuracion para varios dominios
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

cp $installation_dir/conf/site /etc/nginx/sites-available/$DOMAIN

sed -i "s/DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/CERTIFICATE/$SSL_CERTIFICATE_NAME/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/KEY/$SSL_CERTIFICATE_KEY_NAME/g" /etc/nginx/sites-available/$DOMAIN

# Crear enlace simbólico solo si no existe
if [ ! -L /etc/nginx/sites-enabled/$DOMAIN ]; then
    ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
fi

systemctl enable --now nginx
echo -e "${CSUCCESS} Nginx configurado para nuevo sitio.${CEND}"
