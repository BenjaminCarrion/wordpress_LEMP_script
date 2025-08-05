#!/bin/bash

clear

. ./conf/color


printf "
#######################################################################
#       Este script desplegará una nueva instancia de WordPress       #
#   El stack a desplegar es LEMP(Oracle Linux, Nginx, MariaDB, PHP)   #
#######################################################################

"


# --- Función para instalación de paquetes ---
instalar() {
    for pkg in "$@"; do
        if ! dnf list installed "$pkg" &> /dev/null; then
            echo -e "${CINFO} Instalando ${pkg}...${CEND}"
            if dnf install -y "$pkg" &> /dev/null; then
                echo -e "${CSUCCESS} Paquete ${pkg} instalado correctamente.${CEND}"
            else
                echo -e "${CWARNING} No se pudo instalar ${pkg}.${CEND}"
            fi
        else
            echo -e "${CWARNING} El paquete ${pkg} ya está instalado.${CEND}"
        fi
    done
}

# dnf update -y &> /dev/null

. ./conf/variables
. ./scripts/variables.sh

. ./scripts/mariadb.sh
. ./scripts/nginx.sh
. ./scripts/php.sh
. ./scripts/wordpress.sh
. ./scripts/security.sh

echo -e "\n${CSUCCESS} Despliegue completado con éxito.${CEND}\n"
exit 0

