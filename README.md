# Pinbal Template

## Descripción general

Este repositorio no es una aplicación monolítica con una estructura tipo `src/`. Es una plantilla base para herramientas, utilidades y automatización de entorno, pensada para varios servicios y componentes que se ejecutan de forma independiente.

La idea del proyecto es mantener una base común de configuración, generación de variables de entorno y utilidades operativas, pero con un criterio moderno de servicio autónomo:

- cada servicio vive en su propia carpeta
- cada servicio tiene su propio descriptor y configuración
- la raíz del proyecto se reserva para utilidades compartidas, scripts y configuración base
- no se usa un “supercompose” ni una única carpeta que mezcle todo

## Propósito

El proyecto sirve para:

- centralizar la configuración del entorno en `settings.yaml`
- generar variables de entorno desde YAML hacia `.env`
- proporcionar scripts Bash y Python reutilizables
- soportar la preparación de infraestructura local y servicios auxiliares
- permitir la evolución hacia un modelo por microservicios o por componentes

## Estructura actual

```text
pinbal-template/
├── .env
├── .venv/
├── README.md
├── pyproject.toml
├── settings.yaml
├── settings.yaml.template
├── bin/
│   ├── app_clearenvbackup
│   ├── app_launcher
│   ├── app_services
│   ├── app_setenv
│   ├── app_settings
│   ├── install
│   ├── python_setup
│   ├── uv_setup
│   ├── yq_install
│   ├── lib/
│   │   ├── lib_env_utils.sh
│   │   ├── lib_stack_utils.sh
│   │   ├── lib_string_utils.sh
│   │   └── lib_yaml_utils.sh
│   └── test/
│       ├── test_env_utils.sh
│       ├── test_setup.sh
│       ├── test_string_utils.sh
│       └── test_yaml_utils.sh
├── scripts/
│   ├── __init__.py
│   └── hello.py
├── tests/
│   └── test_hello.py
├── data/
│   └── ...
└── ...
```

## Carpetas clave

### `bin/`
Contiene la lógica operativa del entorno y las utilidades de bootstrap.

Incluye:

- `app_settings`: crea o inicializa `settings.yaml` desde la plantilla
- `app_setenv`: genera `.env` a partir de `settings.yaml`
- `app_clearenvbackup`: limpieza de backups generados por el entorno
- `install`, `python_setup`, `uv_setup`, `yq_install`: ayuda de instalación y preparación del entorno
- `lib/`: librerías compartidas de entorno, strings y YAML
- `test/`: validaciones del sistema y de utilidades

### `scripts/`
Es el punto real de lógica Python del proyecto.

Actualmente incluye scripts reutilizables y utilidades ejecutables, como `hello.py`.

El descriptor del proyecto en [pyproject.toml](pyproject.toml) usa esta carpeta como paquete Python, que es coherente con la estructura actual del repositorio.

### `tests/`
Contiene pruebas del proyecto, con foco en validación de comportamiento y validación básica del entorno.

### `data/`
Es la zona de almacenamiento persistente para datos del entorno, logs, secretos, certificados y volúmenes asociados al despliegue local.

## Descriptor del proyecto

En este repositorio, el archivo principal de definición del proyecto es:

- `pyproject.toml`

Ese archivo funciona como descriptor del proyecto Python y define:

- nombre del proyecto
- versión
- descripción
- requisitos de Python
- dependencias
- scripts ejecutables
- herramientas de calidad (pytest, ruff, mypy)
- configuración de empaquetado

Es el descriptor adecuado para este repositorio, porque aquí no hay una aplicación Java/Maven ni una carpeta `src/`; la estructura real es de utilidades y scripts del entorno.

## Configuración central

El origen de configuración del entorno es:

- `settings.yaml`
- `settings.yaml.template`

La idea de trabajo es:

1. ajustar `settings.yaml`
2. ejecutar `app_settings` si hace falta regenerar la base
3. ejecutar `app_setenv` para generar `.env`
4. reutilizar las variables de entorno desde scripts, Docker y automatización

## Filosofía de servicios

Este repositorio apunta a un diseño orientado a servicios, no a un único “main” que lo contenga todo.

El patrón recomendado es:

- un servicio = una carpeta propia
- un servicio = su propio descriptor y configuración
- un servicio = su propio despliegue o Dockerfile
- la raíz del proyecto = herramientas comunes, scripts, configuración base y utilidades de soporte

Ejemplo de estructura moderna:

```text
pinbal-template/
├── infra/
│   ├── nginx/
│   ├── portainer/
│   ├── pgadmin/
│   └── shared/
├── emiservcedent/
├── keycloak/
├── scripts/
├── bin/
├── data/
├── settings.yaml
├── pyproject.toml
└── README.md
```

Con esto se evita acumular servicios y configuración en una sola raíz sin identidad clara.

## Dependencias principales

El proyecto usa Python 3.11 y actualmente trabaja con:

- PyYAML
- python-dotenv
- pytest
- ruff
- mypy

## Flujo recomendado

### Inicialización

```bash
cd /usr/local/desarrollo/Proyectos/emissors/pinbal-template
./bin/app_settings
./bin/app_setenv
```

### Validación

```bash
cd /usr/local/desarrollo/Proyectos/emissors/pinbal-template
python -m pytest
```

### Ejecutar un script Python disponible

```bash
cd /usr/local/desarrollo/Proyectos/emissors/pinbal-template
python -m scripts.hello
```

## Convenciones

- `settings.yaml` es la fuente editada por el usuario
- `.env` se considera artefacto generado
- la raíz del proyecto almacena utilidades y configuración compartida
- cada servicio nuevo debe vivir en una carpeta propia
- no se deben mezclar artefactos de diferentes servicios en la misma carpeta raíz sin criterio

## Seguridad

Antes de usar este repositorio en entornos reales, revisa:

- certificados y claves TLS
- secretos de acceso
- variables sensibles en `.env`
- permisos sobre `data/`
- puertos y hosts del entorno donde se vaya a desplegar

## Resumen

Pinbal Template es una base reutilizable para un ecosistema de servicios y utilidades, con una configuración centralizada y un enfoque modular. La estructura real del repositorio refleja una organización práctica: herramientas en raíz, scripts en `scripts/`, configuración en YAML y un descriptor Python en `pyproject.toml`.

La evolución natural del proyecto es separar cada servicio en su propia carpeta, manteniendo la raíz como soporte compartido y no como una “aplicación única”.
