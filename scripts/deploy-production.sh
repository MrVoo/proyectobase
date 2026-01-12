#!/bin/bash

# Script para despliegue en producción
echo "=== Desplegando proyecto en producción ==="

# Verificar que existe .env en backend
if [ ! -f backend/.env ]; then
    echo "ERROR: No existe el archivo backend/.env"
    echo "Copia backend/.env.example a backend/.env y configúralo para producción"
    exit 1
fi

# Verificar que DEBUG está en False
if grep -q "DEBUG=True" backend/.env; then
    echo "ADVERTENCIA: DEBUG está en True en el archivo .env"
    read -p "¿Continuar de todas formas? (s/n): " continue_debug
    if [ "$continue_debug" != "s" ]; then
        exit 1
    fi
fi

# Detener contenedores existentes
echo "Deteniendo contenedores existentes..."
docker compose down

# Construir y levantar contenedores
echo "Construyendo y levantando contenedores..."
docker compose up --build -d

# Esperar a que el backend esté listo
echo "Esperando a que el backend esté listo..."
sleep 15

# Ejecutar migraciones
echo "Ejecutando migraciones de Django..."
docker compose exec backend python manage.py migrate

# Recolectar archivos estáticos
echo "Recolectando archivos estáticos..."
docker compose exec backend python manage.py collectstatic --noinput

echo ""
echo "=== Despliegue completado ==="
echo "La aplicación está corriendo en el puerto 80"
echo ""
echo "Para ver los logs: docker compose logs -f"
echo "Para detener: docker compose down"
