# Guía Rápida de Inicio

## Para crear un nuevo proyecto a partir de esta plantilla:

### 1. Clonar desde GitHub/VSCode

```bash
# En VSCode: Ctrl+Shift+P -> Git: Clone -> Pegar URL del repo
# O desde terminal:
git clone <url-repo> minuevoproyecto
cd minuevoproyecto
```

### 2. Renombrar el proyecto

```bash
./scripts/rename-project.sh minuevoproyecto
```

### 3. Configurar y desplegar

```bash
# Revisar/editar configuración (opcional)
nano backend/.env

# Desplegar en desarrollo
./scripts/deploy-local.sh
```

### 4. Acceder a la aplicación

- **Frontend**: http://localhost:5173
- **API**: http://localhost:8000/api/
- **Admin**: http://localhost:8000/admin/

## Comandos más usados

```bash
# Ver logs
docker compose -f docker-compose.dev.yml logs -f

# Detener todo
docker compose -f docker-compose.dev.yml down

# Crear superusuario Django
docker compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser

# Acceder al shell de Django
docker compose -f docker-compose.dev.yml exec backend python manage.py shell

# Ejecutar migraciones
docker compose -f docker-compose.dev.yml exec backend python manage.py migrate
```

## Para desplegar en servidor remoto

```bash
./scripts/deploy-remote.sh mrvoodoo@192.168.1.8 nombreproyecto
```

Luego configura Nginx Proxy Manager para:
- Apuntar al puerto 80 del servidor
- Agregar SSL con Let's Encrypt

## Estructura básica para agregar funcionalidad

### Backend (Django)

1. **Modelo**: `backend/api/models.py`
2. **Serializer**: `backend/api/serializers.py`
3. **Vista**: `backend/api/views.py`
4. **URL**: `backend/api/urls.py`
5. **Migración**: `docker compose exec backend python manage.py makemigrations`

### Frontend (React)

1. **Componente**: `frontend/src/components/MiComponente.jsx`
2. **API call**: Usar `apiClient` de `frontend/src/api/client.js`
3. **Importar en App**: `frontend/src/App.jsx`

## Solución rápida de problemas

**¿No se conecta el frontend al backend?**
```bash
# Verifica que ambos contenedores estén corriendo
docker compose -f docker-compose.dev.yml ps

# Revisa los logs
docker compose -f docker-compose.dev.yml logs backend
docker compose -f docker-compose.dev.yml logs frontend
```

**¿Error de base de datos?**
```bash
# Ejecuta las migraciones
docker compose -f docker-compose.dev.yml exec backend python manage.py migrate
```

**¿Quieres empezar de cero?**
```bash
# Borra todo y reconstruye
docker compose -f docker-compose.dev.yml down -v
./scripts/deploy-local.sh
```
