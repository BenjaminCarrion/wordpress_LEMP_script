#!/bin/bash

section "Configurando MariaDB"

# --- Instalación y configuración inicial ---
if ! systemctl is-active --quiet mariadb.service; then
    echo -e "${CINFO} MariaDB no está activo. Iniciando instalación...${CEND}"

    instalar mariadb-server

    sed -i '/^\[mariadb\]/a skip-networking\nperformance_schema = 0' /etc/my.cnf.d/mariadb-server.cnf

    systemctl enable --now mariadb
    sleep 5

    echo -e "${CINFO} Aplicando configuración de seguridad inicial...${CEND}"

    mariadb -u root <<EOF
        # Update the root password for all hosts
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MariaDB_ROOT_PASS}';

        # Delete anonymous users
        DELETE FROM mysql.user WHERE User='';

        # Disallow remote root login
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

        # Remove the test database
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

        # Reload privilege tables
        FLUSH PRIVILEGES;
EOF
    echo -e "${CSUCCESS} Configuración de seguridad completada.${CEND}"
fi

# --- Creación de base de datos y usuario ---
echo -e "${CINFO} Verificando si la base de datos ${DB_NAME} existe...${CEND}"
RESULT=$(mariadb -u root -p"$MariaDB_ROOT_PASS" -e "SHOW DATABASES;" | grep "$DB_NAME")


if [[ "$RESULT" == "$DB_NAME" ]]; then
    echo -e "${CWARNING} La base de datos ${DB_NAME} ya existe. Terminando ejecución.${CEND}"
    exit 0
else
    echo -e "${CINFO} Creando base de datos y usuario...${CEND}"
    mariadb -u root -p"$MariaDB_ROOT_PASS" <<EOF
        CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS '$DB_ADMIN_USER'@'localhost' IDENTIFIED BY '$DB_ADMIN_PASS';
        GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_ADMIN_USER'@'localhost';
        FLUSH PRIVILEGES;
EOF
    echo -e "${CSUCCESS} Base de datos ${DB_NAME} creada exitosamente con su usuario.${CEND}"
fi

