# Verifica si el directorio existe
if [ ! -d "$directorio" ]; then
    echo "Error: '$directorio' no es un directorio válido."
    exit 1
fi

# Cuenta solo archivos 
cantidad=$(find "$directorio" -type f | wc -l)

echo "Hay $cantidad archivos en el directorio '$directorio'."
