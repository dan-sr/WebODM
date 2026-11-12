#!/bin/bash
# Instala WebODM en Ubuntu Server (Examen Unidad I - CTE 334)
# Uso:  sudo bash instalar_webodm.sh TU_USUARIO_DE_GITHUB
set -e

GH_USER="$1"
if [ -z "$GH_USER" ]; then
echo "Falta tu usuario de GitHub. Ejemplo: sudo bash instalar_webodm.sh juanperez"
exit 1
fi
if [ "$(id -u)" -ne 0 ]; then
echo "Ejecuta con sudo: sudo bash instalar_webodm.sh $GH_USER"
exit 1
fi

echo "== 0. Usando todo el espacio del disco =="
lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv || true
df -h /

echo "== 1. Actualizando el sistema =="
add-apt-repository -y universe
apt-get update -y
apt-get install -y git git-buildpackage debhelper devscripts openssh-server \
apt-transport-https ca-certificates curl gnupg-agent software-properties-common

echo "== 2. Instalando Docker =="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

if apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
echo "Docker instalado desde el repositorio oficial."
else
echo "El repositorio de Docker aun no soporta esta version de Ubuntu. Usando el Docker de Ubuntu..."
rm -f /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker.io docker-compose-v2 docker-buildx
fi
apt-get autoremove -y --purge

echo "== 3. Creando el usuario webodm =="
if ! id webodm >/dev/null 2>&1; then
adduser --disabled-password --gecos "" webodm
fi
usermod -aG sudo webodm
usermod -aG docker webodm
usermod -aG www-data webodm

echo "== 4. Preparando la carpeta /opt/WebODM =="
mkdir -p /opt/WebODM/
chown -Rf webodm:www-data /opt/WebODM/
chmod -Rf 775 /opt/WebODM/

echo "== 5. Descargando tu copia del repositorio =="
if [ ! -d /opt/WebODM/.git ]; then
sudo -u webodm git clone "https://github.com/$GH_USER/WebODM.git" --config core.autocrlf=input --depth 1 /opt/WebODM
fi

echo "== 6. Revisando la IP en .env =="
IP=$(hostname -I | awk '{print $1}')
sudo -u webodm sed -i "s/^WO_HOST=.*/WO_HOST=$IP/" /opt/WebODM/.env
grep WO_HOST /opt/WebODM/.env

echo "== 7. Encendiendo WebODM (la primera vez tarda varios minutos) =="
cd /opt/WebODM
sudo -u webodm ./webodm.sh start --detached

echo ""
echo "LISTO. Abre en el navegador de tu computadora:  http://$IP:8000"
