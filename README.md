# Proyecto Base - Django + React + Docker

Proyecto base para desarrollo de aplicaciones web full-stack con Django (backend), React (frontend) y Docker.

## Características

- **Backend**: Django 5.0 + Django REST Framework
- **Frontend**: React 18 + Vite
- **Base de datos**: SQLite (desarrollo) / PostgreSQL (producción)
- **Containerización**: Docker + Docker Compose
- **Servidor web**: Nginx
- **Despliegue**: Scripts automatizados para local y remoto

## Estructura del Proyecto

```
proyectobase/
├── backend/                # Aplicación Django
│   ├── api/               # App de API REST
│   ├── config/            # Configuración de Django
│   ├── requirements.txt   # Dependencias Python
│   ├── Dockerfile         # Dockerfile para producción
│   └── .env.example       # Variables de entorno ejemplo
├── frontend/              # Aplicación React
│   ├── src/              # Código fuente
│   ├── public/           # Archivos estáticos
│   ├── Dockerfile        # Dockerfile para producción
│   ├── Dockerfile.dev    # Dockerfile para desarrollo
│   └── .env.example      # Variables de entorno ejemplo
├── nginx/                # Configuración de Nginx
│   ├── nginx.conf
│   └── conf.d/
├── scripts/              # Scripts de utilidad
│   ├── deploy-local.sh         # Despliegue local
│   ├── deploy-production.sh   # Despliegue producción
│   ├── deploy-remote.sh        # Despliegue remoto
│   └── rename-project.sh       # Renombrar proyecto
├── docker-compose.yml          # Compose para producción
├── docker-compose.dev.yml      # Compose para desarrollo
└── README.md
```

## Requisitos Previos

- Docker
- Docker Compose
- Git
- (Opcional) Python 3.12 para desarrollo local sin Docker
- (Opcional) Node.js 18+ para desarrollo local sin Docker

## Inicio Rápido

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio> minuevoproyecto
cd minuevoproyecto
```

### 2. Renombrar el Proyecto

```bash
./scripts/rename-project.sh minuevoproyecto
```

### 3. Configurar Variables de Entorno

```bash
# Backend
cp backend/.env.example backend/.env
# Edita backend/.env con tus configuraciones

# Frontend
cp frontend/.env.example frontend/.env
# Edita frontend/.env si es necesario
```

### 4. Desplegar en Local (Desarrollo)

```bash
./scripts/deploy-local.sh
```

Esto levantará:
- Frontend en http://localhost:5173
- Backend API en http://localhost:8000/api/
- Django Admin en http://localhost:8000/admin/

## Configuración

### Variables de Entorno - Backend

Edita `backend/.env`:

```env
# Django Settings
SECRET_KEY=tu-secret-key-aqui
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database (SQLite para desarrollo)
DATABASE_ENGINE=django.db.backends.sqlite3
DATABASE_NAME=db.sqlite3

# Para PostgreSQL en producción:
# DATABASE_ENGINE=django.db.backends.postgresql
# DATABASE_NAME=nombredb
# DATABASE_USER=usuario
# DATABASE_PASSWORD=contraseña
# DATABASE_HOST=db
# DATABASE_PORT=5432

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Variables de Entorno - Frontend

Edita `frontend/.env`:

```env
VITE_API_URL=http://localhost:8000
```

## Modos de Despliegue

### Desarrollo Local

Usa SQLite, hot-reload activado, volúmenes para desarrollo:

```bash
./scripts/deploy-local.sh
```

### Producción Local

Usa PostgreSQL, archivos estáticos compilados:

```bash
./scripts/deploy-production.sh
```

### Despliegue Remoto

Despliega en un servidor remoto:

```bash
./scripts/deploy-remote.sh usuario@ip nombreproyecto
```

Ejemplo:
```bash
./scripts/deploy-remote.sh mrvoodoo@192.168.1.8 miproyecto
```

## Comandos Útiles

### Docker Compose

```bash
# Levantar servicios (desarrollo)
docker compose -f docker-compose.dev.yml up -d

# Ver logs
docker compose -f docker-compose.dev.yml logs -f

# Detener servicios
docker compose -f docker-compose.dev.yml down

# Reconstruir contenedores
docker compose -f docker-compose.dev.yml up --build
```

### Django

```bash
# Ejecutar migraciones
docker compose exec backend python manage.py migrate

# Crear superusuario
docker compose exec backend python manage.py createsuperuser

# Colectar archivos estáticos
docker compose exec backend python manage.py collectstatic

# Shell de Django
docker compose exec backend python manage.py shell
```

### Base de Datos

```bash
# Conectar a PostgreSQL
docker compose exec db psql -U postgres -d proyectobase

# Backup de base de datos
docker compose exec db pg_dump -U postgres proyectobase > backup.sql

# Restaurar base de datos
docker compose exec -T db psql -U postgres proyectobase < backup.sql
```

## Desarrollo sin Docker

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

## Estructura de la API

### Endpoints Disponibles

- `GET /api/` - Raíz de la API
- `GET /api/health/` - Health check
- `GET /admin/` - Panel de administración de Django

### Agregar Nuevos Endpoints

1. Crea vistas en `backend/api/views.py`
2. Agrega rutas en `backend/api/urls.py`
3. (Opcional) Crea serializadores en `backend/api/serializers.py`
4. (Opcional) Crea modelos en `backend/api/models.py`

Ejemplo:

```python
# backend/api/views.py
@api_view(['GET'])
def mi_vista(request):
    return Response({'mensaje': 'Hola'})

# backend/api/urls.py
urlpatterns = [
    path('mi-endpoint/', views.mi_vista, name='mi-vista'),
]
```

## Despliegue en Servidor Remoto

### Configuración del Servidor

El servidor remoto debe tener:
- Docker y Docker Compose instalados
- Nginx (para proxy reverso)
- Nginx Proxy Manager (opcional, para gestión de SSL)

### Pasos para Despliegue

1. Ejecuta el script de despliegue remoto:
   ```bash
   ./scripts/deploy-remote.sh usuario@ip nombreproyecto
   ```

2. Configura Nginx Proxy Manager para apuntar al puerto 80 del contenedor

3. Configura SSL con Let's Encrypt en Nginx Proxy Manager

## Solución de Problemas

### El frontend no se conecta al backend

Verifica:
- CORS está configurado correctamente en `backend/config/settings.py`
- `VITE_API_URL` en `frontend/.env` apunta a la URL correcta
- El backend está corriendo y accesible

### Errores de migraciones

```bash
# Resetear migraciones (solo desarrollo)
docker compose exec backend python manage.py migrate --fake
docker compose exec backend python manage.py migrate
```

### Problemas con permisos en archivos estáticos

```bash
docker compose exec backend python manage.py collectstatic --noinput --clear
```

## Contribuir

1. Haz fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## Contacto

Para soporte o consultas, contacta a [tu-email@ejemplo.com]
