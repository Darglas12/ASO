# Práctica 2 – UT4  
## Administración remota de sistemas en red  
**ASO – Curso 2025/2026**

---

## Objetivo de la práctica

Configurar y utilizar mecanismos reales de acceso y administración remota entre sistemas Windows y Linux, aplicando criterios de seguridad, uso de usuarios dedicados, cifrado de las comunicaciones y correcta documentación técnica, propios de un entorno profesional.

---

## Infraestructura utilizada

- **Windows Server 2025** (Servidor – Controlador de Dominio)
- **Ubuntu Server 24.04** (Servidor Linux)
- **Windows 11** (Equipo administrador)
- **Red privada**
- Todas las conexiones se realizan desde Windows 11

---

## PARTE 1 – Acceso remoto seguro por SSH

### Descripción
Configuración de acceso remoto seguro por SSH a un servidor Ubuntu, utilizando un usuario dedicado y autenticación mediante clave pública.  
El acceso se realiza desde Windows 11 usando el cliente PuTTY.

---

### Acceso SSH

- **Servidor:** Ubuntu Server 24.04  
- **Servicio:** OpenSSH  
- **Cliente:** PuTTY (Windows 11)  
- **Usuario autorizado:** remoto_ssh  
- **Tipo de autenticación:** Clave pública  
- **Autenticación por contraseña:** Deshabilitada  
- **Acceso root:** Deshabilitado  

---

### Medidas de seguridad aplicadas

- Uso de un **usuario exclusivo** para acceso remoto (`remoto_ssh`)
- Autenticación basada en **clave pública**
- Deshabilitación del acceso por contraseña en SSH
- Restricción del acceso a usuarios no autorizados

---

### Evidencias (capturas)

- Servicio SSH activo en Ubuntu
- Usuario remoto_ssh creado
- Directorio .ssh y archivo authorized_keys con permisos correctos
- Acceso SSH desde PuTTY sin solicitud de contraseña
- Intento de acceso denegado con un usuario distinto de remoto_ssh

---

## PARTE 2 – Administración remota gráfica (RDP)

### Descripción
Administración remota de un Windows Server desde Windows 11 mediante Escritorio Remoto (RDP), utilizando un usuario dedicado del dominio y control explícito del acceso.

---

### Acceso RDP

- **Sistema administrado:** Windows Server 2025  
- **Cliente:** Escritorio remoto (mstsc) desde Windows 11  
- **Protocolo:** RDP  
- **Usuario RDP:** remoto_rdp (usuario de dominio)  
- **Grupo de acceso:** Remote Desktop Users  
- **Autenticación de nivel de red (NLA):** Habilitada  
- **Cifrado de la conexión:** Sí  

---

### Particularidades del entorno

El servidor Windows Server actúa como **Controlador de Dominio**, por lo que:
- No se utilizan usuarios locales
- La gestión de usuarios y grupos se realiza mediante **Active Directory**
- El acceso RDP se concede mediante pertenencia a grupos del dominio

---

### Medidas de seguridad aplicadas

- Uso de un **usuario exclusivo de dominio** para RDP (remoto_rdp)
- Pertenencia controlada al grupo **Remote Desktop Users**
- Autenticación de nivel de red (NLA) habilitada
- Restricción del acceso a usuarios no autorizados

---

### Evidencias (capturas)

- Usuario de dominio remoto_rdp creado en Active Directory
- Usuario añadido al grupo **Remote Desktop Users**
- Autenticación de nivel de red habilitada
- Sesión RDP activa mostrando el escritorio del servidor
- Intento de acceso denegado con un usuario distinto de remoto_rdp

---

## Conclusión

Se ha configurado correctamente el acceso remoto seguro a sistemas Linux y Windows, aplicando buenas prácticas de seguridad como el uso de usuarios dedicados, autenticación fuerte, cifrado de las comunicaciones y control explícito de permisos.  
La infraestructura cumple los criterios de seguridad y administración propios de un entorno profesional.
