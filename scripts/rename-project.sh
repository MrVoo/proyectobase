#!/bin/bash

# Script para renombrar el proyecto base a un nuevo nombre
# Uso: ./rename-project.sh <nuevo_nombre> [ruta_proyecto]

if [ $# -lt 1 ]; then
    echo "Uso: $0 <nuevo_nombre> [ruta_proyecto]"
    echo ""
    echo "Ejemplos:"
    echo "  $0 minuevoproyecto                    # Renombra el proyecto actual"
    echo "  $0 minuevoproyecto /ruta/al/proyecto  # Renombra proyecto en ruta específica"
    exit 1
fi

NEW_NAME=$1
OLD_NAME="proyectobase"

# Determinar directorio del proyecto
if [ $# -eq 2 ]; then
    PROJECT_DIR=$2
else
    # Si se ejecuta desde scripts/, subir un nivel
    if [[ $(basename $(pwd)) == "scripts" ]]; then
        PROJECT_DIR=$(dirname $(pwd))
    else
        PROJECT_DIR=$(pwd)
    fi
fi

# Verificar que el directorio existe
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: El directorio $PROJECT_DIR no existe"
    exit 1
fi

echo "=== Renombrando proyecto de '$OLD_NAME' a '$NEW_NAME' ==="
echo "Directorio: $PROJECT_DIR"
echo ""

# Confirmar con el usuario
read -p "¿Continuar con el renombrado? (s/n): " confirm
if [ "$confirm" != "s" ]; then
    echo "Operación cancelada"
    exit 0
fi

cd "$PROJECT_DIR"

echo ""
echo "Renombrando referencias en archivos..."

# Archivos a modificar
FILES_TO_RENAME=(
    "docker-compose.yml"
    "docker-compose.dev.yml"
    "backend/.env.example"
    "README.md"
)

# Renombrar en cada archivo
for file in "${FILES_TO_RENAME[@]}"; do
    if [ -f "$file" ]; then
        echo "  - Procesando $file"
        # En Linux
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sed -i "s/${OLD_NAME}/${NEW_NAME}/g" "$file"
        # En macOS
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" "$file"
        fi
    else
        echo "  - Advertencia: $file no encontrado, omitiendo..."
    fi
done

echo ""
echo "=== Renombrado completado ==="
echo ""
echo "Cambios realizados:"
echo "  - Referencias en docker-compose.yml actualizadas"
echo "  - Referencias en docker-compose.dev.yml actualizadas"
echo "  - Referencias en backend/.env.example actualizadas"
echo "  - Referencias en README.md actualizadas"
echo ""
echo "Próximos pasos:"
echo "  1. Revisa los archivos modificados"
echo "  2. Copia backend/.env.example a backend/.env y configúralo"
echo "  3. Copia frontend/.env.example a frontend/.env si es necesario"
echo "  4. Ejecuta el script de despliegue: ./scripts/deploy-local.sh"
echo ""
