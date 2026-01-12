#!/bin/bash

# Script para despliegue en servidor remoto
# Uso: ./deploy-remote.sh <usuario>@<ip> <nombre_proyecto>

if [ $# -lt 2 ]; then
    echo "Uso: $0 <usuario@ip> <nombre_proyecto>"
    echo "Ejemplo: $0 mrvoodoo@192.168.1.8 miproyecto"
    exit 1
fi

REMOTE_HOST=$1
PROJECT_NAME=$2
REMOTE_PATH="/home/${REMOTE_HOST#*@}/projects/${PROJECT_NAME}"

echo "=== Desplegando ${PROJECT_NAME} en ${REMOTE_HOST} ==="

# Crear directorio en el servidor remoto
echo "Creando directorio en servidor remoto..."
ssh $REMOTE_HOST "mkdir -p ${REMOTE_PATH}"

# Sincronizar archivos (excluir node_modules, venv, etc.)
echo "Sincronizando archivos..."
rsync -avz --progress \
    --exclude 'node_modules' \
    --exclude 'venv' \
    --exclude '.git' \
    --exclude '*.pyc' \
    --exclude '__pycache__' \
    --exclude 'db.sqlite3' \
    --exclude '.env' \
    --exclude 'staticfiles' \
    --exclude 'media' \
    ./ ${REMOTE_HOST}:${REMOTE_PATH}/

# Copiar .env.example como referencia
echo "Configurando archivos .env en remoto..."
ssh $REMOTE_HOST << EOF
cd ${REMOTE_PATH}

# Crear .env para backend si no existe
if [ ! -f backend/.env ]; then
    cp backend/.env.example backend/.env
    echo "Archivo backend/.env creado. Debes editarlo con las configuraciones de producción."
fi

# Crear .env para frontend si no existe
if [ ! -f frontend/.env ]; then
    cp frontend/.env.example frontend/.env
fi
EOF

# Ejecutar despliegue en el servidor remoto
echo "Ejecutando despliegue en servidor remoto..."
ssh $REMOTE_HOST << EOF
cd ${REMOTE_PATH}

# Detener contenedores existentes
docker compose down

# Construir y levantar contenedores
docker compose up --build -d

# Esperar a que el backend esté listo
sleep 15

# Ejecutar migraciones
docker compose exec -T backend python manage.py migrate

# Recolectar archivos estáticos
docker compose exec -T backend python manage.py collectstatic --noinput

echo ""
echo "=== Despliegue completado en servidor remoto ==="
EOF

echo ""
echo "=== Despliegue remoto finalizado ==="
echo "Proyecto desplegado en: ${REMOTE_HOST}:${REMOTE_PATH}"
echo ""
echo "IMPORTANTE: Debes configurar nginx-proxy-manager para apuntar al puerto 80 del proyecto"
echo "O configurar manualmente nginx en el servidor"
