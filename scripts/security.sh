#!/bin/bash

# --- Configuración de firewall ---
echo -e "${CMSG}Configurando firewalld...${CEND}"

# Asegurar que los servicios HTTP y HTTPS estén habilitados
for svc in http https; do
    if ! firewall-cmd --zone=public --list-services | grep -qw "$svc"; then
        echo "Agregando servicio $svc al firewall..."
        firewall-cmd --permanent --zone=public --add-service=$svc &> /dev/null
    else
        echo "Servicio $svc ya está habilitado en el firewall."
    fi
done

# Aplicar los cambios
firewall-cmd --reload &> /dev/null
echo -e "${CSUCCESS}Reglas de firewall actualizadas correctamente.${CEND}"

