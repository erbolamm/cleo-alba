#!/data/data/com.termux/files/usr/bin/bash
# Script para reparar DNS en Debian proot

echo "Reparando DNS en el entorno Debian de Termux..."

proot-distro login debian -- bash -c "
echo -e 'nameserver 1.1.1.1\nnameserver 8.8.8.8' > /etc/resolv.conf
echo 'DNS actualizado en /etc/resolv.conf'
ping -c 3 google.com || echo 'Aviso: ping falló, pero la resolución podría estar funcionando.'
"

echo "Sincronizando cambios en scripts de búsqueda..."
# Asegurarnos de que el script de búsqueda también sepa qué hacer si falla el host
# (Opcional: podríamos añadir las IPs al /etc/hosts de Debian si el DNS persiste fallando)
