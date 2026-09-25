# BarrioTickera

## 1. Setup

### 1.1 Requerimientos

- Docker
- Docker Compose
- python >=3.14

### 1.2 Base de datos

Levantar contendor con compose:

```bash
docker compose up
```

Cada vez que tenga que crearse/recrearse el volumen se van a aplicar
automáticamente los scripts de configuración, ddl y poblado de tablas.

Para bajar la BD:

```bash
docker compose down
```

#### Eliminar DB

Para bajar el contenedor **y eliminar** los volumenes/db usar `-v`:

```bash
docker compose down -v
```

### 1.3 Python

Instalar entorno virtual, uv y dependencias:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install uv
uv sync
```

## 2. Ejecutar

Simplemente ejecutar:

```bash
uv run main.py
```

> [!IMPORTANT]
>
> No olvidar cargar el entorno virtual antes de ejecutar:
>
> ```bash
> source .venv/bin/activate
> ```
