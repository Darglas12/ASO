# Práctica 2 – UT4 Administración remota de sistemas en red  

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

![imagen 1](Capturas/Servicio%20SSH%20activo.png)

- Usuario remoto_ssh creado

![imagen 2](Capturas/Usuario%20creado.png)

- Claves generadas

![imagen 3](Capturas/Claves%20generadas.png)

- Acceso por contraseña deshabilitado.

![imagen 4](Capturas/Acceso%20por%20contraseña%20deshabilitado.png)

- Acceso SSH desde PuTTY sin solicitud de contraseña

![imagen 5](Capturas/Acceso%20SSH%20desde%20PuTTY%20con%20remoto_ssh.png)

- Intento de acceso denegado con un usuario distinto de remoto_ssh

![imagen 6](Capturas/Acceso%20denegado%20a%20otro%20usuario.png)

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

- Usuario de dominio remoto_rdp creado en Active Directory y añadido a su grupo correspondiente

![imagen 7](Capturas/Usuario%20remoto_rdp%20creado%20y%20añadido%20al%20grupo%201.png)

- Habilitación de escritorio remoto tanto en windows server 

![imagen 8](Capturas/Habilitacion%20de%20escritorio%20remoto1.png)

![imagen 9](Capturas/Habilitacion%20de%20escritorio%20remoto2.png)

- Permitir en Directiva de Seguridad

![imagen 10](Capturas/Permitir%20en%20Directiva%20de%20Seguridad.png)

- Sesión RDP activa mostrando el escritorio del servidor

![imagen 11](Capturas/Sesión%20RDP%20activa%20donde%20se%20vea%20escritorio%20del%20servidor%20y%20usuario%20remoto_rdp%20conectado.png)

- Intento de acceso denegado con un usuario distinto de remoto_rdp

![imagen 12](Capturas/Acceso%20denegado%20a%20otro%20usuario_ejercicio2.png)

---

## Conclusión

Se ha configurado correctamente el acceso remoto seguro a sistemas Linux y Windows, aplicando buenas prácticas de seguridad como el uso de usuarios dedicados, autenticación fuerte, cifrado de las comunicaciones y control explícito de permisos.  
La infraestructura cumple los criterios de seguridad y administración propios de un entorno profesional.
