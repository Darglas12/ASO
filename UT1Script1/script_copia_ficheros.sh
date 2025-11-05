# Comprobar si se pasó el directorio origen como parámetro
if [ -z "$1" ]; then
    echo "Uso: $0 <directorio_origen>"
    exit 1
fi

origen="$1"
backup="./backup"

# Verificar que el directorio origen existe
if [ ! -d "$origen" ]; then
    echo "Error: el directorio '$origen' no existe."
    exit 1
fi

# Crear carpeta backup si no existe
if [ ! -d "$]()
