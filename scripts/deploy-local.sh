#!/bin/bash

# Script para despliegue local (desarrollo)
echo "=== Desplegando proyecto en local para desarrollo ==="

# Verificar que existe .env en backend
if [ ! -f backend/.env ]; then
    echo "Creando archivo .env desde .env.example..."
    cp backend/.env.example backend/.env
    echo "¡IMPORTANTE! Edita backend/.env con tus configuraciones antes de continuar"
    read -p "Presiona Enter cuando hayas editado el archivo .env..."
fi

# Verificar que existe .env en frontend
if [ ! -f frontend/.env ]; then
    echo "Creando archivo .env frontend desde .env.example..."
    cp frontend/.env.example frontend/.env
fi

# Detener contenedores existentes
echo "Deteniendo contenedores existentes..."
docker compose -f docker-compose.dev.yml down

# Construir y levantar contenedores
echo "Construyendo y levantando contenedores..."
docker compose -f docker-compose.dev.yml up --build -d

# Esperar a que el backend esté listo
echo "Esperando a que el backend esté listo..."
sleep 10

# Ejecutar migraciones
echo "Ejecutando migraciones de Django..."
docker compose -f docker-compose.dev.yml exec backend python manage.py migrate

# Crear superusuario (opcional)
echo ""
read -p "¿Deseas crear un superusuario de Django? (s/n): " create_superuser
if [ "$create_superuser" = "s" ]; then
    docker compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser
fi

echo ""
echo "=== Despliegue completado ==="
echo "Frontend: http://localhost:5173"
echo "Backend API: http://localhost:8000/api/"
echo "Django Admin: http://localhost:8000/admin/"
echo ""
echo "Para ver los logs: docker compose -f docker-compose.dev.yml logs -f"
echo "Para detener: docker compose -f docker-compose.dev.yml down"
