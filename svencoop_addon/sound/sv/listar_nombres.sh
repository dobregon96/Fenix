#!/bin/bash

# Archivo donde se guardarán los nombres de los archivos
output_file="nombres_sonidos.txt"

# Limpiar el archivo de salida si ya existe
> "$output_file"

# Obtener la ruta actual
ruta=$(pwd)

# Listar los nombres de los archivos y guardarlos en el archivo de texto
for file in *; do
    if [[ -f "$file" ]]; then
        echo "$file $ruta/$file" >> "$output_file"
    fi
done

echo "Lista de archivos guardada en $output_file"
