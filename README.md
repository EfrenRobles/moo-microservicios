# Moo Microservices - High Performance Specialization

**Ecosistema modular de microservicios** diseñado para alta eficiencia, basado en **Java 25**, **Spring Boot 4** y arquitectura de **Monorepo**.

> **Filosofía del Proyecto: Host Inmaculado.** No instalamos Java, Gradle ni Docker Desktop en tu sistema operativo base. Todo el ciclo de vida (Build, Test, Run) ocurre de forma efímera y aislada en contenedores.

---

## 🛠️ Infraestructura "Invisible"

Este proyecto utiliza una capa de abstracción sobre **WSL2** (Windows) o **Linux nativo** para garantizar que el entorno de desarrollo sea idéntico al de producción, eliminando dependencias de software comercial o licencias restrictivas.

* **Runtime:** Docker Engine GPL (Nativo, sin Docker Desktop).
* **Orquestación:** Systemd activo dentro de la sandbox de WSL2.
* **Build System:** Agentes efímeros de **Java 25** + **Gradle 10**.
* **Networking:** Modo *Mirrored* para baja latencia y compatibilidad total con VPNs empresariales.
* **Persistencia:** Volumen de caché global para dependencias de Gradle (optimización de ancho de banda).

---

## 🚦 Pre-requisitos

Para que el orquestador `moo.sh` realice la provisión automática, asegúrate de cumplir con lo siguiente:

### Windows
1.  **Git for Windows:** [Descargar e instalar](https://git-scm.com/download/win).
2.  **Terminal:** Ejecuta los comandos desde **Git Bash** con permisos de administrador (requerido solo la primera vez para configurar la distro y el archivo `.wslconfig`).
3.  **WSL2:** Asegúrate de tener el kernel de WSL actualizado (`wsl --update`).

### Linux
1. **Git & Curl:** Instalados mediante tu gestor de paquetes.
2. **Docker Engine** (El script intentará configurarlo por ti).

### macOS
1. **Git:** Instalado vía `brew` o tu gestor de paquetes.
2. **Docker Colima:** (El script intentará configurarlo por ti).
---

## 🚀 Inicio Rápido (The "Moo" Way)

1.  **Clona el repositorio:**
    ```
      bash
      git clone <tu-repo-url>
      cd moo-vm
    ```

2.  **Provisión automática:**
    Este script detecta tu sistema operativo, instala la distro Ubuntu 24.04 si no existe, configura el usuario `moo`, activa Systemd y levanta el demonio de Docker.
    ```
      bash
      ./moo.sh setup
    ```
    *Nota: Si es una instalación limpia en Windows, es posible que el script te solicite reiniciar la terminal o ejecutar `wsl --shutdown` para aplicar los cambios de Systemd.*

3.  **Compilación Efímera:**
    Construye tus microservicios utilizando un contenedor de Java 25. El artefacto final se genera sin ensuciar tu sistema host.
    ```
      bash
      ./moo.sh build [nombre-servicio]
    ```

## Notas de Seguridad y Rendimiento

* **Recursos:** El entorno está limitado por defecto a 4GB de RAM y 8 núcleos (configurable en `setup/.wslconfig`).
* **Limpieza:** Al usar contenedores efímeros para el build, no quedan procesos de Java "zombies" consumiendo memoria o generando calor innecesario.