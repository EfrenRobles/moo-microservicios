# Moo Microservices - High Performance Specialization

**Ecosistema modular de microservicios** diseñado para alta eficiencia, basado en **Java 25**, **Spring Boot 4** , **Gradle 10** y arquitectura de **Monorepo**.

> **Filosofía del Proyecto: Host Inmaculado.** No instalamos Java, Gradle ni Docker Desktop en tu sistema operativo base. Todo el ciclo de vida (Build, Test, Run) ocurre de forma efímera y aislada en contenedores.

---

## Infraestructura "Invisible"

Este proyecto utiliza una capa de abstracción sobre **WSL2** (Windows) o **Linux nativo** para garantizar que el entorno de desarrollo sea idéntico al de producción, eliminando dependencias de software comercial o licencias restrictivas.

* **Runtime:** Docker Engine GPL (Nativo, sin Docker Desktop).
* **Orquestación:** Systemd activo dentro de la sandbox de WSL2 (Windows).
* **Build System:** Agentes efímeros de **Java 25** + **Gradle 10**.
* **Networking:** Modo *Mirrored* para baja latencia y compatibilidad total con VPNs empresariales.
* **Persistencia:** Volumen de caché global para dependencias de Gradle (optimización de ancho de banda).

---

## Pre-requisitos

Para que el orquestador `menu.sh` realice la provisión automática, asegúrate de cumplir con lo siguiente:

### Windows
1.  **Git for Windows:** [Descargar e instalar](https://git-scm.com/download/win).
2.  **Terminal:** Ejecuta los comandos desde **Git Bash** (requerido todo el tiempo para ejecutar el menu).
3.  **WSL2:** Asegúrate de tener el kernel de WSL actualizado (`wsl --update`).

### Todo: //Linux
1. **Git & Curl:** Instalados mediante tu gestor de paquetes.
2. **Docker Engine** (El script intentará configurarlo por ti).

### Todo: //macOS
1. **Git:** Instalado vía `brew` o tu gestor de paquetes.
2. **Docker Colima:** (El script intentará configurarlo por ti).
---

## Inicio Rápido (The "Moo" Way)

1.  **Clona el repositorio:**
    ```
      bash
      git clone <tu-repo-url>
    ```

2.  **Provisión automática:**
    Este script detectara tu sistema operativo, instala la distro Ubuntu 24.04 si no existe, configura el usuario `moo`, activa Systemd y levanta el demonio de Docker.
    ```
      bash
      ./menu.sh
    ```

3.  **Todo: //Compilación Efímera:**
    Construye los microservicios utilizando un contenedor de Java 25. El artefacto final se genera sin ensuciar tu sistema host.
    (servicio de jenkins pendiente)

## Estructura del Proyecto (Monorepo)

El repositorio está organizado como un proyecto multi-módulo de Gradle:

* **`moo-auth/`, `moo-users/`**: Dominios principales. Cada uno dividido en `-api`, `-client` y `-service` para máxima desacoplación.
* **`moo-gateway/`**: Punto de entrada único al ecosistema.
* **`moo-commons/`**: Librerías transversales (Logging, JPA, Flyway, Feign, etc).
* **`buildSrc/`**: Lógica de construcción centralizada (Kotlin DSL) para garantizar versiones uniformes de Java 25 y Spring Boot 4.
* **`moo-vm/`**: Orquestador del entorno local. Contiene los scripts de setup (`menu.sh`), configuraciones de Docker, Jenins, etc.

## Contenedores de dockers integrados en moo-vm
* **'PostgreSQL 18'**
* **'RabbitMQ 4.0 - Enterprise Message Broker (AWS SQS/SNS Compatible via Binder)'**
* **'OpenLDAP AD-like Directory'**
* **'Dozzle (Container Log Viewer)'**
* **'Jenkins: Automation Server'**
* **'Redis: High Performance Cache'**
* **'Vault: Secret Management'**

## Notas de Seguridad y Rendimiento

* (Windows version)
* **Recursos:** El entorno está limitado por defecto a 4GB de RAM y 8 núcleos (configurable en `setup/.wslconfig`).
* **Limpieza:** Al usar contenedores efímeros para el build, no quedan procesos de Java "zombies" consumiendo memoria o generando calor innecesario.

// Todo
Multipass (Linux, Mac)
Lima
Shuru

4. **Estructura de archivos y directorios **

**VHDX 1: moo-ubuntu.vhdx (The "Compute" - Disposable)**
└── /
    ├── etc/
    │   └── wsl.conf            <-- Configures automount & metadata
    ├── var/
    │   └── lib/
    │       └── docker/         <-- [SYMLINK] points to VHDX 2
    └── home/
        └── moo/
            ├── .gitconfig      <-- [SYMLINK] points to VHDX 2
            ├── .ssh/           <-- [SYMLINK] points to VHDX 2
            └── work/           <-- [SYMLINK] points to VHDX 2/monorepo

-----------------------------------------------------------------------

**VHDX 2: moo-data.vhdx (The "State" - Persistent)**
└── /mnt/moo-data/              <-- Mount Point for VHDX 2
    ├── docker-engine/          <-- Contains all Images, Containers, and Cache
    ├── user-config/
    │   ├── .gitconfig          <-- Shared Git identity
    │   ├── .ssh/               <-- Shared keys (if needed for GitLab/GitHub)
    │   └── .bashrc_ext         <-- Custom aliases/PS1 for moo-vm
    └── projects/
        └── moo-microservices/  <-- The Monorepo (Java 25 / Spring Boot 4)
            ├── .git/
            ├── services/
            └── dockers/        <-- Local orchestration files