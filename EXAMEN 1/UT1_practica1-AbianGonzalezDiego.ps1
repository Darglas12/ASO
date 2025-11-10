# UT1_practica1-AbianGonzalezDiego.ps1
# Autor: Abian Gonzalez Diego
# Fecha: 10/11/2025

param(
    [string]$OutputPath = "\\ServidorAula\Comparte_aula\Practica_PS", # Define la ruta donde guardar el inventario (por defecto una carpeta en la red) # Mejora 1: Parametrización de rutas
    [string]$LogPath = "\\ServidorAula\Comparte_aula\Practica_PS\logs", # Define la ruta donde guardar el diario (log) (por defecto una subcarpeta en la red) # Mejora 1: Parametrización de rutas
    [string]$SessionCode = "UT1_P1_DAG", # Código para identificar esta ejecución (como un nombre único para la receta)
    [switch]$Quiet = $true,  # Opción para silenciar el script (no muestra nada en pantalla, activado por defecto) # Mejora 10: Modo silencioso
    [switch]$c, # Interruptor para activar el modo "consolidación" (juntar varios inventarios) # Mejora 11: Consolidación sin interacción
    [string]$InputFolder, # Ruta de la carpeta con archivos a juntar (usado con -c) # Mejora 11: Consolidación sin interacción
    [string]$ReportPath, # Ruta donde guardar el archivo juntado (usado con -c) # Mejora 11: Consolidación sin interacción
    [switch]$ExportToExcel # Opción para generar un archivo Excel en lugar de CSV # Mejora Extra: Exportación a Excel
)

# Inicialización de variables
$infoColl = @() # Crea una caja vacía para guardar datos temporalmente, como un plato donde poner ingredientes
$csvName = "$env:computername-Inventory.csv" # Crea el nombre del archivo CSV usando el nombre de tu computadora (ej. IF04-19-Inventory.csv)
$logFile = $null # Prepara una variable para la ruta del diario (log), empezando vacía

# Función para escribir en el diario (log)
function Write-Log {
    param([string]$Message, [string]$Level = "INFO") # Toma un mensaje y un nivel (por defecto "INFO" como "todo bien") # Mejora 5: Registro de actividad
    if (-not $logFile) { return } # Si no hay ruta de log, sale y no hace nada para evitar errores
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" # Obtiene la fecha y hora actual en formato "año-mes-día hora:min:sec"
    $entry = "[$timestamp] $Level $env:computername $SessionCode $Message" # Crea una línea para el log con fecha, nivel, nombre del equipo, código y mensaje
    try { # Intenta hacer algo # Mejora 7: Inicialización correcta y control de errores
        Add-Content -Path $logFile -Value $entry -ErrorAction Stop # Añade la línea al archivo de log
    } catch { } # Si falla, no hace nada (silencio)
}

# Función para probar si se puede escribir en una carpeta
function Test-WriteAccess {
    param([string]$Path) # Toma una ruta como entrada # Mejora 3: Prueba real de escritura
    $test = Join-Path $Path "test_$(Get-Random).tmp" # Crea un nombre de archivo temporal aleatorio en la ruta
    try { # Intenta # Mejora 3: Prueba real de escritura
        "test" | Out-File -FilePath $test -ErrorAction Stop # Escribe "test" en el archivo temporal
        Remove-Item -Path $test -ErrorAction Stop # Borra el archivo temporal
        return $true # Devuelve "verdadero" si todo salió bien
    } catch { return $false } # Si falla, devuelve "falso" (no se puede escribir)
}

# Función para obtener una ruta válida
function Get-LocalPath {
    param([string]$Path) # Toma una ruta como entrada
    if ((Test-Path $Path) -and (Test-WriteAccess $Path)) { # Si la ruta existe y se puede escribir... # Mejora 2: Comprobación de ruta de salida
        return $Path # Devuelve la ruta original
    } else { # Si no... # Mejora 8: Salida a carpeta compartida con fallback
        return [Environment]::GetFolderPath("MyDocuments") # Devuelve la ruta de "Documentos" local
    }
}

# Configuración de rutas
$OutputPath = Get-LocalPath $OutputPath # Usa la función para obtener una ruta válida para el CSV (original o "Documentos") # Mejora 2: Comprobación de ruta de salida
$LogPath = Get-LocalPath $LogPath # Igual para el log # Mejora 2: Comprobación de ruta de salida
$csv = Join-Path $OutputPath $csvName # Crea la ruta completa del CSV uniendo la carpeta y el nombre
$logFile = Join-Path $LogPath "Inventory_$SessionCode.log" # Crea la ruta completa del log

# Crear log si no existe
if (-not (Test-Path $logFile)) { # Si el log no existe...
    try { New-Item -Path $logFile -ItemType File -Force | Out-Null } catch { } # Crea el archivo de log (fuerza si es necesario) y esconde la salida # Mejora 5: Registro de actividad
}

Write-Log "Iniciando ejecución del inventario" "INFO" # Registra el inicio en el log # Mejora 4: Mensajes informativos

# Modo consolidación
if ($c) { # Si el interruptor -c está activado... # Mejora 11: Consolidación sin interacción
    if (-not $InputFolder -or -not $ReportPath) { # Si faltan carpetas necesarias...
        Write-Log "Error: -InputFolder y -ReportPath requeridos para -c" "ERROR" # Registra el error # Mejora 5: Registro de actividad
        exit 1 # Sale del script con error
    }
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss" # Crea un nombre con fecha para el reporte
    $report = Join-Path $ReportPath "PowerShell-PC-Inventory-Report-$timestamp.csv" # Crea la ruta del reporte
    $unique = @{} # Crea una "caja" para guardar datos únicos
    Get-ChildItem -Path $InputFolder -Filter *.csv | ForEach-Object { # Busca todos los CSV en la carpeta y para cada uno...
        Import-Csv $_.FullName | ForEach-Object { # Lee el CSV y para cada fila...
            $key = $_ | Out-String # Crea una "llave" única de la fila
            if (-not $unique.ContainsKey($key)) { $unique[$key] = $_ } # Si no está duplicada, añádela a la caja
        }
    }
    $unique.Values | Export-Csv -Path $report -NoTypeInformation -Force # Exporta los datos únicos a un nuevo CSV
    Write-Log "Consolidación completada: $report" "INFO" # Registra el éxito # Mejora 4: Mensajes informativos
    exit 0 # Sale del script con éxito
}

# Recopilación de datos
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss" # Obtiene la fecha actual

# IP y MAC
try { # Intenta # Mejora 12: Control de errores en CIM/IO
    $route = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1 # Encuentra la ruta principal de red
    $index = $route.InterfaceIndex # Toma el número de la interfaz
    $ip = (Get-NetIPAddress -InterfaceIndex $index -AddressFamily IPv4).IPAddress # Obtiene la IP
    $mac = (Get-NetAdapter -InterfaceIndex $index).MacAddress # Obtiene la MAC
} catch { $ip = "N/A"; $mac = "N/A" } # Si falla, pone "No disponible" # Mejora 12: Control de errores en CIM/IO

# Datos del sistema
try { $SN = (Get-CimInstance Win32_BIOS).SerialNumber } catch { $SN = "N/A" } # Obtiene el número de serie # Mejora 12: Control de errores en CIM/IO
try { $Model = (Get-CimInstance Win32_ComputerSystem).Model } catch { $Model = "N/A" } # Obtiene el modelo # Mejora 12: Control de errores en CIM/IO
try { $CPU = (Get-CimInstance Win32_Processor).Name } catch { $CPU = "N/A" } # Obtiene el procesador # Mejora 12: Control de errores en CIM/IO
try { $RAM = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2) } catch { $RAM = "N/A" } # Calcula la RAM en GB # Mejora 12: Control de errores en CIM/IO
try { $Storage = [math]::Round((Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'").Size / 1GB, 2) } catch { $Storage = "N/A" } # Calcula el almacenamiento # Mejora 12: Control de errores en CIM/IO

# Datos de GPUs
try {
    $gpus = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Description # Obtiene las tarjetas gráficas # Mejora 6: Monitores (aplicado a GPUs)
    $GPU0 = if ($gpus -and $gpus.Count -gt 0) { $gpus[0] } else { "N/A" } # Primera GPU o "No disponible" # Mejora 12: Control de errores en CIM/IO
    $GPU1 = if ($gpus -and $gpus.Count -gt 1) { $gpus[1] } else { "N/A" } # Segunda GPU o "No disponible" # Mejora 12: Control de errores en CIM/IO
} catch { $GPU0 = "N/A"; $GPU1 = "N/A" } # Si falla, pone "No disponible" # Mejora 12: Control de errores en CIM/IO

# Datos del sistema operativo
try {
    $os = Get-CimInstance Win32_OperatingSystem # Obtiene info del sistema # Mejora 12: Control de errores en CIM/IO
    $OSName = $os.Caption # Nombre del sistema
    $OSBuild = $os.BuildNumber # Número de versión
    $uptime = (Get-Date) - $os.LastBootUpTime # Calcula el tiempo encendido
    $uptimeStr = "$($uptime.Days) días, $($uptime.Hours) h, $($uptime.Minutes) min" # Formato del tiempo
} catch { $OSName = "N/A"; $OSBuild = "N/A"; $uptimeStr = "N/A" } # Si falla, pone "No disponible" # Mejora 12: Control de errores en CIM/IO

# Usuario
$Username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name # Obtiene el nombre del usuario actual

# Datos de monitores
try {
    $mon = Get-CimInstance -Namespace "root\WMI" -Class "WMIMonitorID" # Obtiene info de monitores # Mejora 6: Monitores
    $info = @() # Crea una lista vacía para los datos
    foreach ($m in $mon) { # Para cada monitor...
        $manuf = [System.Text.Encoding]::ASCII.GetString($m.ManufacturerName) -replace "\0","" # Nombre del fabricante
        $name = [System.Text.Encoding]::ASCII.GetString($m.UserFriendlyName) -replace "\0","" # Nombre del monitor
        $sn = [System.Text.Encoding]::ASCII.GetString($m.SerialNumberID) -replace "\0","" # Número de serie
        $info += $manuf, $name, $sn # Añade a la lista
    }
    $Monitor1 = if ($info.Count -ge 2) { "$($info[0]) $($info[1])" } else { "N/A" } # Primer monitor # Mejora 6: Monitores
    $Monitor1SN = if ($info.Count -ge 3) { $info[2] } else { "N/A" } # Número de serie del primero # Mejora 6: Monitores
    $Monitor2 = if ($info.Count -ge 5) { "$($info[3]) $($info[4])" } else { "N/A" } # Segundo monitor # Mejora 6: Monitores
    $Monitor2SN = if ($info.Count -ge 6) { $info[5] } else { "N/A" } # Número de serie del segundo # Mejora 6: Monitores
    $Monitor3 = if ($info.Count -ge 8) { "$($info[6]) $($info[7])" } else { "N/A" } # Tercer monitor # Mejora 6: Monitores
    $Monitor3SN = if ($info.Count -ge 9) { $info[8] } else { "N/A" } # Número de serie del tercero # Mejora 6: Monitores
} catch {
    $Monitor1 = $Monitor1SN = $Monitor2 = $Monitor2SN = $Monitor3 = $Monitor3SN = "N/A" # Si falla, todo "No disponible" # Mejora 12: Control de errores en CIM/IO
}

# Tipo de equipo
try {
    $chassis = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes[0] # Obtiene el tipo de carcasa # Mejora 12: Control de errores en CIM/IO
    $ChassisDesc = switch ($chassis) { # Convierte el tipo en texto
        3 {"Desktop"} 4 {"Low Profile Desktop"} 7 {"Tower"} 9 {"Laptop"} 10 {"Notebook"}
        default {"Otro"}
    }
} catch { $ChassisDesc = "N/A" } # Si falla, "No disponible" # Mejora 12: Control de errores en CIM/IO

# Creación del objeto de inventario
$obj = [PSCustomObject]@{ # Crea una "tabla" con todos los datos
    "Fecha Recopilada" = $Date
    "Hostname" = $env:computername
    "IP" = $ip
    "MAC" = $mac
    "Usuario" = $Username
    "Tipo" = $ChassisDesc
    "Serial Number" = $SN
    "Modelo" = $Model
    "CPU" = $CPU
    "RAM (GB)" = $RAM
    "Almacenamiento (GB)" = $Storage
    "GPU 0" = $GPU0
    "GPU 1" = $GPU1
    "OS" = $OSName
    "Versión OS" = $OSBuild
    "Uptime" = $uptimeStr
    "Monitor 1" = $Monitor1
    "Monitor 1 SN" = $Monitor1SN
    "Monitor 2" = $Monitor2
    "Monitor 2 SN" = $Monitor2SN
    "Monitor 3" = $Monitor3
    "Monitor 3 SN" = $Monitor3SN
    "Apps Instaladas" = "N/A"
}

# Idempotencia (evitar duplicados) # Mejora 9: Idempotencia
if (Test-Path $csv) { # Si el CSV ya existe...
    $existing = Import-Csv $csv | Where-Object { $_.Hostname -ne $env:computername } # Lee el CSV y filtra duplicados
    $existing | Export-Csv -Path $csv -NoTypeInformation -Force # Guarda solo los no duplicados
}

# Exportación del inventario
try { # Intenta # Mejora 7: Inicialización correcta y control de errores
    if ($ExportToExcel -and (Get-Module -ListAvailable -Name ImportExcel)) { # Si quiere Excel y tiene el programa
        $excel = $csv -replace '\.csv$', '.xlsx' # Cambia el nombre a .xlsx
        $obj | Export-Excel -Path $excel -AutoSize -FreezeTopRow -ErrorAction Stop # Guarda como Excel
        Write-Log "Exportado a Excel: $excel" "INFO" # Registra # Mejora 4: Mensajes informativos
    } else { # Si no...
        $obj | Export-Csv -Path $csv -NoTypeInformation -Append -Force -Encoding UTF8 -ErrorAction Stop # Guarda como CSV con codificación correcta # Mejora 3: Prueba real de escritura
        Write-Log "Exportado a CSV: $csv" "INFO" # Registra # Mejora 4: Mensajes informativos
    }
} catch { # Si falla...
    Write-Log "Error al exportar: $_" "ERROR" # Registra el error # Mejora 5: Registro de actividad
}

Write-Log "Inventario completado con éxito" "INFO" # Registra el final # Mejora 4: Mensajes informativos
exit 0 # Termina el script con éxito