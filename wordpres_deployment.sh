#!/bin/bash
#

clear 

printf "
#######################################################################
#       Este script desplegará una nueva instancia de WordPress       #
#   El stack a desplegar es LEMP(Oracle Linux, Nginx, MariaDB, PHP)   #
#######################################################################

"

. ./conf/color

instalar (){
    for pkg in $@; do
        #use &> /dev/null when you're done with debuging
        if ! dnf list installed $pkg &> /dev/null; then
            echo "Instalando $pkg"
            dnf install -y $pkg &> /dev/null || echo "Advertencia: No es posible instalar $pkg"
        else
            echo "${CWARNING}El paquete $pkg ya está instalado $CEND"
        fi
    done
}

#dnf update -y

. ./conf/variables

echo "Las variables configuradas para la instalación son:

URL: 
$CMSG $DOMAIN $CEND

Base de datos

Nombre de la base de datos:
$CMSG $DB_NAME $CEND

Credenciales Usuario Admin:
$CMSG $DB_ADMIN_USER
 $DB_ADMIN_PASS $CEND

Password Usuario root:
$CMSG $MariaDB_ROOT_PASS $CEND


Directorio donde se ubicará archivos de WordPress:
$CMSG $WEB_ROOT $CEND


Certificado SSL:
$CMSG $SSL_CERTIFICATE $CEND

Llave certficado SSL:
$CMSG $SSL_CERTIFICATE_KEY $CEND
"

while :; do echo
    read -e -p "Desea instalar una nueva instancia de WordPress con estos parametros? [s/n]: " respuesta
    if [[ ! ${respuesta} =~ ^[s,n]$ ]]; then
      echo "${CWARNING}Error de entrada! Presionar 's' o 'n'${CEND}"
    else
        [[ "$respuesta" == [Ss]* ]] && echo -e "${CSUCCESS}\nEmpezando instalación${CEND}" || exit 0
      break
    fi
done

echo $current_dir

. ./scripts/mariadb.sh

. ./scripts/nginx.sh

. ./scripts/php.sh

. ./scripts/wordpress.sh

#permission stuff
#check if rules are created
#The next stuff easily could go on another security script 
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

exit 0
