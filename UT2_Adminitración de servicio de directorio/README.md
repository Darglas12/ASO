## Implementación de la Infraestructura de Red

La unidad consistió en la implementación de una **infraestructura de red** fundamentada en **Active Directory Domain Services (AD DS)**, que utiliza el protocolo **LDAP** para la gestión centralizada de recursos como **usuarios** y **grupos**.

### Despliegue de Active Directory
El proceso de despliegue incluyó:
- La promoción del **primer Controlador de Dominio (DC)** en un **nuevo bosque**.
- La incorporación de un **segundo DC (controlador adicional)** para garantizar la **alta disponibilidad**.

### Conectividad y Seguridad
Para dotar de conectividad **WAN segura** a la red privada:
- Se implementó un **firewall pfSense** que actuó como **Puerta de Enlace**.
- Se configuraron los **reenviadores DNS** en el DC para gestionar la **resolución de nombres externos**.

### Automatización con PowerShell
También se enfatizó el uso de **PowerShell** como herramienta **orientada a objetos** esencial para la **automatización**, permitiendo:
- La configuración de red.
- La instalación de roles.
- La gestión detallada de objetos de **Active Directory** (como crear **unidades organizativas** y **usuarios**) mediante **cmdlets específicos**.

> **Nota:** No se llegó a realizar una tarea práctica sobre este último apartado.
