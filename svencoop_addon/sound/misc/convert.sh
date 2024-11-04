#!/bin/bash

# Crear la carpeta de salida si no existe
mkdir -p ../output

# Convertir archivos .mp3
for file in *.mp3; do
  if [ -f "$file" ]; then
    output_file="../output/${file%.mp3}.wav"
    echo "Convirtiendo: $file a $output_file"
    ffmpeg -i "$file" -ar 22050 -ac 1 -sample_fmt s16 "$output_file"
  fi
done

# Convertir archivos .ogg
for file in *.ogg; do
  if [ -f "$file" ]; then
    output_file="../output/${file%.ogg}.wav"
    echo "Convirtiendo: $file a $output_file"
    ffmpeg -i "$file" -ar 22050 -ac 1 -sample_fmt s16 "$output_file"
  fi
done

# Convertir archivos .wav
for file in *.wav; do
  if [ -f "$file" ]; then
    output_file="../output/${file%.wav}.wav"
    echo "Convirtiendo: $file a $output_file"
    ffmpeg -i "$file" -ar 22050 -ac 1 -sample_fmt s16 "$output_file"
  fi
done

echo "Conversión completa."

