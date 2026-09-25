# BarrioTickera

## Setup

### Base de datos

Levantar contendor con compose:

```bash
docker compose up
```

Para bajar el contenedor y eliminar los volumenes/db:

```bash
docker compose down -v
```

### Python

Instalar entorno virtual, uv y dependencias:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install uv
uv sync
```
