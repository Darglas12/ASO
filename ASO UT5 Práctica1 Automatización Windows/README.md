# Práctica 1 – Automatización de Tareas (UT5 ASO 25/26)

## Contexto
Esta práctica tiene como objetivo automatizar tareas administrativas en entornos Windows Server mediante GPO y scripts.  

Se realizaron dos automatizaciones principales:

1. **Mapeo automático de unidades de red** según el grupo de seguridad del usuario.  
2. **Script de limpieza automático** de archivos temporales en clientes, ejecutándose periódicamente sin intervención.

---

## Infraestructura
- **Servidor:** Windows Server 2025  
- **Cliente:** Windows 11  
- **Red:** Privada  
- **Active Directory:**  
  - `UO_Administracion`: user_admin1, user_admin2  
  - `UO_Informatica`: user_info1, user_info2  
  - `UO_Usuarios`: user_user1, user_user2  
- **Grupos de seguridad:**  
  - `GRP_Administracion` → usuarios de UO_Administracion  
  - `GRP_Informatica` → usuarios de UO_Informatica  

---

## Tarea 1 – Mapeo Automático de Unidades

### Objetivo
Mapear automáticamente unidades de red según el grupo de seguridad del usuario, garantizando acceso correcto y evitando acceso a recursos de otros departamentos.

### Procedimiento
1. Crear carpetas compartidas en servidor:

| Carpeta local         | Nombre compartido     | Acceso |
|----------------------|---------------------|--------|
| C:\Compartidas\Admin | Compartida-Admin     | GRP_Administracion |
| C:\Compartidas\Informatica | Compartida-Info | GRP_Informatica |
| C:\Compartidas\Comun | Compartida-Todos     | Todos los usuarios |

![1](img/Sección%20“Captura%20de%20la%20estructura%20de%20carpetas%20en%20el%20servidor”.png)

2. Configurar permisos NTFS y de compartido según grupo.

![2](img/Sección%20“Permisos%20de%20la%20carpeta”.png)

![3](img/Sección%20“Permisos%20de%20la%20carpeta”2.png)

3. Crear GPO `Mapeo-Unidades-[INICIALES]`.

![4](img/Sección%20“GPO%20creada”.png)

4. Configurar unidades dentro de la GPO:

- **Z:** \\servidor\Compartida-Admin → GRP_Administracion  
- **Y:** \\servidor\Compartida-Info → GRP_Informatica  
- **X:** \\servidor\Compartida-Todos → todos los usuarios  

![5](img/Sección%20“Configuración%20de%20unidades%20en%20la%20GPO”.png)

![6](img/Sección%20“Configuración%20de%20unidades%20en%20la%20GPO”2.png)

5. Vincular la GPO a las UO correspondientes: `UO_Administracion`, `UO_Informatica`, `UO_Usuarios`.

![7](img/Sección%20“Vinculación%20GPO%20a%20UOs”.png)

![8](img/Sección%20“Vinculación%20GPO%20a%20UOs”2.png)

![8](img/Sección%20“Vinculación%20GPO%20a%20UOs”3.png)

6. Verificación en clientes:

- `user_admin1` → Z: y X:  
- `user_info1` → Y: y X:  
- Intentar acceso a recursos de otro grupo → “Acceso denegado”

![9](img/Sección%20“Unidades%20en%20cliente”.png)

![10](img/Sección%20“Acceso%20denegado”.png)

---

## Tarea 2 – Script de Limpieza Automático

### Objetivo
Desplegar mediante GPO un script que limpie archivos temporales y genere un log automáticamente en los clientes.

### Procedimiento
1. Copiar script `Limpieza_Sistema.txt` a:  
```text
\\[dominio].local\SYSVOL\[dominio].local\scripts\
```
![11](img/Sección%20“Script%20en%20SYSVOL”.png)

2. Crear GPO Mantenimiento-Automatico-[INICIALES] y configurar tarea programada:

Ejecutarse semanalmente

Cuenta: SYSTEM

Privilegios elevados

Ejecutar PowerShell apuntando al script

![12](img/Sección%20“GPO%20creada”2.png)

![13](img/Sección%20“Tarea%20programada”.png)

![14](img/Sección%20“Tarea%20programada”2.png)

![15](img/Sección%20“Tarea%20programada”3.png)

3. Vincular la GPO a UO_Usuarios.

![16](img/Sección%20“Vinculación%20de%20limpieza”.png)

4. Verificación en cliente:

Ejecutar gpupdate /force

Abrir taskschd.msc

Ejecutar manualmente la tarea

Comprobar log generado en C:\Logs

![17](img/Sección%20“Log%20generado”.png)


## SCRIPT

Yo en vez de generar las cosas a mano con este script he conseguido crear automáticamente usuarios, grupos, unidades organizativas (UO) y carpetas compartidas con sus permisos correspondientes en un dominio de Active Directory, dejando todo listo para la práctica de mapeo de unidades y control de accesos.

```powershell
$Dominio = "dag.local"
$RutaBase = "C:\Compartidas"

Import-Module ActiveDirectory

$UOs = @(
    "UO_Administracion",
    "UO_Informatica",
    "UO_Usuarios",
    "UO_Equipos_Politica",
    "UO_Equipos_Control"
)

foreach ($uo in $UOs) {
    New-ADOrganizationalUnit -Name $uo -Path "DC=$(($Dominio -replace '\.',',DC='))" -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
}

New-ADGroup -Name "GRP_Administracion" -GroupScope Global -GroupCategory Security -Path "CN=Users,DC=$(($Dominio -replace '\.',',DC='))" -ErrorAction SilentlyContinue
New-ADGroup -Name "GRP_Informatica" -GroupScope Global -GroupCategory Security -Path "CN=Users,DC=$(($Dominio -replace '\.',',DC='))" -ErrorAction SilentlyContinue

$Password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force

$Usuarios = @(
    @{Nombre="user_admin1"; UO="UO_Administracion"; Grupo="GRP_Administracion"},
    @{Nombre="user_admin2"; UO="UO_Administracion"; Grupo="GRP_Administracion"},
    @{Nombre="user_info1"; UO="UO_Informatica"; Grupo="GRP_Informatica"},
    @{Nombre="user_info2"; UO="UO_Informatica"; Grupo="GRP_Informatica"},
    @{Nombre="user_user1"; UO="UO_Usuarios"; Grupo=$null},
    @{Nombre="user_user2"; UO="UO_Usuarios"; Grupo=$null}
)

foreach ($u in $Usuarios) {
    $OUPath = "OU=$($u.UO),DC=$(($Dominio -replace '\.',',DC='))"

    New-ADUser -Name $u.Nombre `
        -SamAccountName $u.Nombre `
        -UserPrincipalName "$($u.Nombre)@$Dominio" `
        -AccountPassword $Password `
        -Enabled $true `
        -Path $OUPath `
        -ErrorAction SilentlyContinue

    if ($u.Grupo) {
        Add-ADGroupMember -Identity $u.Grupo -Members $u.Nombre -ErrorAction SilentlyContinue
    }
}

$Carpetas = @("Admin","Informatica","Comun")

if (!(Test-Path $RutaBase)) {
    New-Item -ItemType Directory -Path $RutaBase
}

foreach ($c in $Carpetas) {
    New-Item -ItemType Directory -Path "$RutaBase\$c" -Force
}

New-SmbShare -Name "Compartida-Admin" -Path "$RutaBase\Admin" -FullAccess "GRP_Administracion" -ErrorAction SilentlyContinue
New-SmbShare -Name "Compartida-Info" -Path "$RutaBase\Informatica" -FullAccess "GRP_Informatica" -ErrorAction SilentlyContinue
New-SmbShare -Name "Compartida-Todos" -Path "$RutaBase\Comun" -FullAccess "Domain Users" -ErrorAction SilentlyContinue

icacls "$RutaBase\Admin" /inheritance:r
icacls "$RutaBase\Admin" /grant "GRP_Administracion:(OI)(CI)F"

icacls "$RutaBase\Informatica" /inheritance:r
icacls "$RutaBase\Informatica" /grant "GRP_Informatica:(OI)(CI)F"

icacls "$RutaBase\Comun" /inheritance:r
icacls "$RutaBase\Comun" /grant "Domain Users:(OI)(CI)F"

Write-Host "TODO CREADO CORRECTAMENTE"

```