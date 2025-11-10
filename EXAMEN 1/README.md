o Parámetros implementados: -OutputPath, -LogPath, -SessionCode, -Quiet, -c, -InputFolder, -ReportPath, -ExportToExcel.
o Qué ocurre si no hay red: Usa la carpeta "Documentos" local como fallback.
o Dónde se guarda el inventario: En la ruta especificada (por defecto \\ServidorAula\...) o en "Documentos" si falla la red.
o Cómo ejecutar el script (ejemplo de comando): .\UT1_practica1-AbianGonzalezDiego.ps1 -SessionCode "UT1_P1_DAG".
o Qué mejoras has implementado: Parametrización, comprobación de rutas, prueba de escritura, mensajes informativos, logs, monitores, control de errores, fallback a carpeta local, idempotencia, modo silencioso, consolidación, y manejo de errores CIM/IO.