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
8. Vídeo de evidencia (Screencast)  
9. Errores frecuentes y resolución  
10. Conclusiones  

## 1. Introducción

En este proyecto se realiza el despliegue de una aplicación web de **Gestión de Usuarios** sobre una infraestructura en **alta disponibilidad de cuatro capas**, basada en una pila **LEMP** (Linux, Nginx, MariaDB y PHP).

La infraestructura se despliega en entorno local utilizando **Vagrant y VirtualBox**.  
El aprovisionamiento de todas las máquinas se realiza mediante **scripts Bash**.

## 2. Descripción general de la infraestructura

La infraestructura está organizada en **cuatro capas**, interconectadas mediante redes privadas internas de VirtualBox.

### Capa 1 – Balanceador Web (Expuesta)

- **Máquina:** `balanceadorJuanma`
- **Servicio:** Nginx
- **Función:** Balanceo de carga HTTP hacia los servidores web
- **Acceso externo:** Puerto 8080 del anfitrión → Puerto 80 del balanceador

### Capa 2 – BackEnd Web

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

### Capa 3 – Balanceo de Bases de Datos

- **Máquina:** `haproxy`
- **Servicio:** HAProxy
- **Función:** Balanceo de conexiones hacia el clúster MariaDB

### Capa 4 – Datos

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

```

## 6. Aprovisionamiento de las máquinas

El aprovisionamiento de todas las máquinas se realiza de forma automática mediante **scripts Bash**, ejecutados durante el despliegue con Vagrant.

### Balanceador Web

- Instalación y configuración del servidor **Nginx**.
- Configuración del **balanceo de carga** hacia los servidores `web1Juanma` y `web2Juanma`.
- Activación y verificación del **registro de accesos** mediante logs.
- -Si quieres ver el [balanceador.sh](aprov/balanceadorJuanma.sh) pincha en el.
### Servidores Web

- Instalación del servidor **Nginx**.
- Configuración del uso de **PHP-FPM**.
- Montaje del **sistema de archivos compartido NFS** proporcionado por el servidor NFS.

### Servidor NFS y PHP-FPM

- Exportación del **directorio compartido** mediante NFS.
- Configuración del servicio **PHP-FPM**, accesible desde los servidores web.

### HAProxy

- Configuración del **balanceo de conexiones** hacia los servidores MariaDB.
- Implementación de **alta disponibilidad** para el acceso a la base de datos.

### MariaDB Galera

- Implementación de un **clúster MariaDB Galera de dos nodos**.
- Configuración de la **replicación síncrona** de los datos entre ambos nodos.

## 7. Configuración de la aplicación web

Se realiza una **personalización mínima** de la aplicación de Gestión de Usuarios para garantizar:

- Conexión correcta con la **base de datos**.
- Funcionamiento adecuado en un **entorno distribuido**.
- **Persistencia de los datos** en el clúster MariaDB.

## 8. Vídeo de evidencia (Screencast)

- Para ver el Screencast pulsa aquí: [Vídeo](https://drive.google.com/file/d/1je2Hsn53Pny0UbHWPnkEx0sGNk9hrVl-/view?usp=drive_link)

## 9. Errores frecuentes y resolución

### Error Crítico: El aprovisionamiento a veces no funciona como debería
- Si las MariaDB no funcionan como deberían es porque no se les crea la columna Edad, haz un `vagrant ssh db(1/2)Juanma` e introduce el siguiente código
   ALTER TABLE users
   ADD COLUMN age INT NOT NULL AFTER email`;
- Si en las webs no se monta el servicio NFS, haz un `vagrant ssh web(1/2)Juanma` e introduce el siguiente código
   `sudo mount -t nfs 192.168.20.20:/var/www/html/webapp /var/www/html/webapp`

### Error: La web no carga desde el navegador
- Comprobar el **puerto 8080** en el balanceador.
- Verificar que el servicio **Nginx** está activo en el balanceador.

### Error: PHP no se ejecuta
- Revisar la conexión con **PHP-FPM**.
- Verificar el **puerto y la configuración FastCGI**.

### Error: El directorio NFS no se monta
- Revisar el fichero `/etc/exports` en el servidor NFS.
- Comprobar **permisos y coincidencia de UID/GID**.

### Error: No hay conexión con la base de datos
- Verificar el estado del servicio **HAProxy**.
- Revisar las **credenciales de acceso a MariaDB**.

### Error: El clúster Galera no sincroniza
- Comprobar la configuración del **clúster Galera**.
- Verificar que los **puertos necesarios** están abiertos entre los nodos.

## 10. Conclusión

La infraestructura desplegada cumple con los requisitos de **alta disponibilidad, balanceo de carga y separación de capas**, garantizando un servicio **robusto, escalable y tolerante a fallos**.
