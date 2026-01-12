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
echo "=== Renombrando directorio ==="
echo ""

# Preguntar si desea renombrar el directorio PRIMERO
read -p "¿Deseas renombrar el directorio de '$OLD_NAME' a '$NEW_NAME'? (s/n): " rename_dir
if [ "$rename_dir" == "s" ]; then
    CURRENT_DIR=$(basename "$PROJECT_DIR")
    PARENT_DIR=$(dirname "$PROJECT_DIR")
    NEW_DIR="$PARENT_DIR/$NEW_NAME"

    # Verificar que el directorio destino no existe
    if [ -d "$NEW_DIR" ]; then
        echo "Error: El directorio '$NEW_DIR' ya existe"
        echo "Por favor, elige otro nombre o elimina el directorio existente"
        exit 1
    else
        echo "Renombrando directorio..."
        mv "$PROJECT_DIR" "$NEW_DIR"

        if [ $? -eq 0 ]; then
            echo "✓ Directorio renombrado exitosamente"
            echo "  Antigua ubicación: $PROJECT_DIR"
            echo "  Nueva ubicación: $NEW_DIR"
            PROJECT_DIR="$NEW_DIR"
            cd "$PROJECT_DIR"
        else
            echo "Error al renombrar el directorio"
            exit 1
        fi
    fi
else
    echo "Renombrado de directorio omitido."
fi

echo ""
echo "=== Configurando repositorio Git ==="
echo ""

# Preguntar si desea crear nuevo repositorio
read -p "¿Deseas crear un nuevo repositorio Git con el nombre '$NEW_NAME'? (s/n): " create_repo
if [ "$create_repo" == "s" ]; then
    # Verificar si gh CLI está instalado
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) no está instalado."
        echo "Instálalo con: sudo apt install gh (Ubuntu/Debian) o brew install gh (macOS)"
        exit 1
    fi

    # Verificar autenticación de GitHub
    if ! gh auth status &> /dev/null; then
        echo "No estás autenticado en GitHub CLI."
        read -p "¿Deseas autenticarte ahora? (s/n): " auth_now
        if [ "$auth_now" == "s" ]; then
            gh auth login
        else
            echo "Operación cancelada. Autentica con: gh auth login"
            exit 1
        fi
    fi

    echo ""
    echo "Eliminando repositorio Git anterior..."
    rm -rf .git

    echo "Inicializando nuevo repositorio Git..."
    git init
    git add .
    git commit -m "Initial commit: $NEW_NAME"

    echo ""
    read -p "¿El repositorio debe ser público o privado? (publico/privado): " visibility

    # Crear repositorio en GitHub
    echo "Creando repositorio '$NEW_NAME' en GitHub..."
    if [ "$visibility" == "publico" ]; then
        gh repo create "$NEW_NAME" --public --source=. --remote=origin --push
    else
        gh repo create "$NEW_NAME" --private --source=. --remote=origin --push
    fi

    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ Repositorio creado exitosamente en GitHub"
        echo "  URL: https://github.com/$(gh api user --jq .login)/$NEW_NAME"
    else
        echo ""
        echo "Error al crear el repositorio en GitHub"
        exit 1
    fi
else
    echo "Configuración de repositorio omitida."
fi

echo ""
echo "=== Renombrado completado ==="
echo ""
echo "Cambios realizados:"
echo "  - Referencias en docker-compose.yml actualizadas"
echo "  - Referencias en docker-compose.dev.yml actualizadas"
echo "  - Referencias en backend/.env.example actualizadas"
echo "  - Referencias en README.md actualizadas"
if [ "$rename_dir" == "s" ]; then
    echo "  - Directorio renombrado a: $NEW_DIR"
fi
if [ "$create_repo" == "s" ]; then
    echo "  - Nuevo repositorio Git creado y vinculado a GitHub"
fi

echo ""
echo "Próximos pasos:"
if [ "$rename_dir" == "s" ]; then
    echo "  IMPORTANTE: Cambia al nuevo directorio con:"
    echo "  cd $NEW_DIR"
    echo ""
fi
echo "  1. Copia backend/.env.example a backend/.env y configúralo"
echo "  2. Copia frontend/.env.example a frontend/.env si es necesario"
echo "  3. Ejecuta el script de despliegue: ./scripts/deploy-local.sh"
echo ""
