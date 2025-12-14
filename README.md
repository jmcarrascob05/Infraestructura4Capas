# Despliegue de Aplicación Web en Alta Disponibilidad con LEMP

**Autor:** Juan Manuel Carrasco Benítez  
**Ciclo:** ASIR  
**Tecnologías:** Vagrant, VirtualBox, Debian 12, Nginx, PHP-FPM, NFS, HAProxy, MariaDB Galera

## Índice

1. Introducción  
2. Descripción general de la infraestructura  
3. Esquema de red y direccionamiento IP  
4. Requisitos previos  
5. Despliegue de la infraestructura con Vagrant  
6. Aprovisionamiento de las máquinas  
7. Configuración de la aplicación web  
8. Comprobaciones de funcionamiento  
9. Vídeo de evidencia (Screencast)  
10. Errores frecuentes y resolución  
11. Conclusiones  

## 1. Introducción

En este proyecto se realiza el despliegue de una aplicación web de **Gestión de Usuarios** sobre una infraestructura en **alta disponibilidad de cuatro capas**, basada en una pila **LEMP** (Linux, Nginx, MariaDB y PHP).

La infraestructura se despliega en entorno local utilizando **Vagrant y VirtualBox**.  
El aprovisionamiento de todas las máquinas se realiza mediante **scripts Bash**.

## 2. Descripción general de la infraestructura

La infraestructura está organizada en **cuatro capas**, interconectadas mediante redes privadas internas de VirtualBox.

### 🔹 Capa 1 – Balanceador Web (Expuesta)

- **Máquina:** `balanceadorJuanma`
- **Servicio:** Nginx
- **Función:** Balanceo de carga HTTP hacia los servidores web
- **Acceso externo:** Puerto 8080 del anfitrión → Puerto 80 del balanceador

### 🔹 Capa 2 – BackEnd Web

- **Máquinas:**
  - `web1Juanma`
  - `web2Juanma`
- **Servicio:** Nginx
- **Función:** Servir la aplicación web
- **Características:**
  - Uso de almacenamiento compartido vía NFS
  - Uso de PHP-FPM

- **Servidor adicional:**
  - **Máquina:** `nfsJuanma`
  - **Servicios:** NFS y PHP-FPM

### 🔹 Capa 3 – Balanceo de Bases de Datos

- **Máquina:** `haproxy`
- **Servicio:** HAProxy
- **Función:** Balanceo de conexiones hacia el clúster MariaDB

### 🔹 Capa 4 – Datos

- **Máquinas:**
  - `db1Juanma`
  - `db2Juanma`
- **Servicio:** MariaDB Galera
- **Función:** Almacenamiento de datos en alta disponibilidad

## 3. Esquema de red y direccionamiento IP

### Redes internas utilizadas

| Red | Función |
|----|--------|
| redbalanceador | Balanceador ↔ exterior |
| redwebsNFS | Webs ↔ NFS |
| redhaproxy | NFS ↔ HAProxy |
| reddb | HAProxy ↔ BBDD |

### Direccionamiento IP

| Máquina | IP | Red |
|------|----|----|
| balanceadorJuanma | 192.168.10.10 | redbalanceador |
| balanceadorJuanma | 192.168.20.5 | redwebsNFS |
| web1Juanma | 192.168.20.10 | redwebsNFS |
| web2Juanma | 192.168.20.15 | redwebsNFS |
| nfsJuanma | 192.168.20.20 | redwebsNFS |
| nfsJuanma | 192.168.30.20 | redhaproxy |
| haproxy | 192.168.30.10 | redhaproxy |
| haproxy | 192.168.40.5 | reddb |
| db1Juanma | 192.168.40.10 | reddb |
| db2Juanma | 192.168.40.11 | reddb |

## 4. Requisitos previos

- VirtualBox instalado
- Vagrant instalado
- Git instalado
- Sistema anfitrión Windows
- Conexión a Internet

## 5. Despliegue de la infraestructura con Vagrant

El despliegue se realiza mediante el fichero `Vagrantfile`:

```bash
vagrant up
