#!/bin/bash 
#

if ! systemctl is-active --quiet mariadb.service;
then
    instalar mariadb-server 
    sed -i '/^\[mariadb\]/a skip-networking\nperformance_schema = 0' /etc/my.cnf.d/mariadb-server.cnf
    #skip-name-resolve could give a little improvement

    systemctl enable --now mariadb

    sleep 5

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

echo "MariaDB secure installation complete."
fi

#REVISAR SI LA BASE DE DATOS YA SE ENCUENTRA CREADA
RESULT=`mariadb -u root -p$MariaDB_ROOT_PASS -e "SHOW DATABASES" | grep $DB_NAME`

if [ "$RESULT" == "$DB_NAME" ]; then
    echo "${CFAILURE}La base de datos ya existe terminando la ejecución del script$CEND"
    exit 0;
else
    echo "Creando base de datos"

    mariadb -u root -p$MariaDB_ROOT_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '$DB_ADMIN_USER'@'localhost' IDENTIFIED BY '$DB_ADMIN_PASS';
    GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_ADMIN_USER'@'localhost';
    FLUSH PRIVILEGES;" 
fi


