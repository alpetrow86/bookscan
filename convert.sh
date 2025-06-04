#!/bin/bash

INPUT_DIR="./source"
SPLITED_DIR="./splited"
OUTPUT_PDF="$(basename "$(pwd)").pdf"
A4_WIDTH=2480   # Ширина A4 при 300 DPI
A4_HEIGHT=3508  # Высота A4 при 300 DPI

# Проверка наличия файлов
if [ $(ls -1 "$INPUT_DIR"/*.png 2>/dev/null | wc -l) -ne 1 ]; then
  echo "❌ Положите ОДИН PNG-файл в папку source!"
  exit 1
fi

# Получаем информацию об изображении
INPUT_FILE=$(ls -1 "$INPUT_DIR"/*.png)
WIDTH=$(magick identify -format "%w" "$INPUT_FILE")
HEIGHT=$(magick identify -format "%h" "$INPUT_FILE")

# Рассчитываем количество вертикальных страниц
PAGES=$(( (HEIGHT + A4_HEIGHT - 1) / A4_HEIGHT ))

echo "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
echo "Ширина изображения: ${WIDTH}px"
echo "Высота изображения: ${HEIGHT}px"
echo "Количество страниц A4: ${PAGES}"
echo "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"

# Создаем папку для фрагментов
mkdir -p "$SPLITED_DIR"

# Разрезаем изображение на A4
echo "✂️ Режу изображение на ${PAGES} страниц A4..."
magick "$INPUT_FILE" -crop ${A4_WIDTH}x${A4_HEIGHT} +repage "${SPLITED_DIR}/page_%02d.png"

# Создаем PDF
echo "📄 Собираю PDF..."
magick "${SPLITED_DIR}"/*.png -quality 100 "${OUTPUT_PDF}"

# Добавляем OCR
echo "🔍 Распознаю текст..."
ocrmypdf -l rus+eng --force-ocr "${OUTPUT_PDF}" "${OUTPUT_PDF}"

echo -e "\n✅ Готово! Файл: $(pwd)/${OUTPUT_PDF}"
