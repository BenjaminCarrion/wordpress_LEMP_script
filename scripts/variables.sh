#!/bin/bash

declare -A VARMAP=(
    [1]="DOMAIN"
    [2]="DB_NAME"
    [3]="DB_ADMIN_USER"
    [4]="DB_ADMIN_PASS"
    [5]="MariaDB_ROOT_PASS"
    [6]="WEB_ROOT"
    [7]="SSL_CERTIFICATE"
    [8]="SSL_CERTIFICATE_KEY"
)

show_vars() {
    echo -e "\n${CBLUE}Configuración actual:${CEND}\n"

    echo -e "${CYELLOW}1) Sitio Web${CEND}"
    printf "   [1] %-20s = %s\n" "DOMAIN" "$DOMAIN"
    echo

    echo -e "${CYELLOW}2) Base de Datos${CEND}"
    printf "   [2] %-20s = %s\n" "DB_NAME" "$DB_NAME"
    printf "   [3] %-20s = %s\n" "DB_ADMIN_USER" "$DB_ADMIN_USER"
    printf "   [4] %-20s = %s\n" "DB_ADMIN_PASS" "$DB_ADMIN_PASS"
    printf "   [5] %-20s = %s\n" "MariaDB_ROOT_PASS" "$MariaDB_ROOT_PASS"
    echo

    echo -e "${CYELLOW}3) Archivos del sitio${CEND}"
    printf "   [6] %-20s = %s\n" "WEB_ROOT" "$WEB_ROOT"
    echo

    echo -e "${CYELLOW}4) Certificados SSL${CEND}"
    printf "   [7] %-20s = %s\n" "SSL_CERTIFICATE" "$SSL_CERTIFICATE"
    printf "   [8] %-20s = %s\n" "SSL_CERTIFICATE_KEY" "$SSL_CERTIFICATE_KEY"
    echo
}

# --- Función para actualizar path si se cambia el dominio ---
update_domain_dependents() {
    local domain="$1"
    WEB_ROOT="/var/www/html/$domain"
    echo -e "${CINFO}Ruta de instalación actualizada:${CEND}"
    echo -e "  WEB_ROOT = $WEB_ROOT"
}

# --- Bucle principal para edición y confirmación ---
while true; do
    show_vars
    echo -e "${CBLUE}Cambiar variables (ej: 1 4 5 o Enter/S para continuar):${CEND}"
    read -p " " -a choices

    if [[ ${#choices[@]} -eq 0 || "${choices[0],,}" == "s" ]]; then
        echo -e "${CSUCCESS}Iniciando la instalación...${CEND}"
        break
    fi

    for num in "${choices[@]}"; do
        var="${VARMAP[$num]}"
        if [[ -z "$var" ]]; then
            echo -e "${CWARNING}Número $num inválido.${CEND}"
            continue
        fi
        current_value="${!var}"
        read -e -p "Nuevo valor para $var (actual: $current_value): " new_value
        if [[ -n "$new_value" ]]; then
            eval "$var=\"\$new_value\""
            echo -e "${CSUCCESS}$var actualizado.${CEND}"
            [[ "$var" == "DOMAIN" ]] && update_domain_dependents "$new_value"
        else
            echo -e "${CINFO}Sin cambios para $var.${CEND}"
        fi
    done
done

