#!/bin/bash

FILE="$HOME/.local/share/color-schemes/DankMatugen.colors"
# change with your own
ICON_THEME_DIR="$HOME/Downloads/Vara"

cd "$ICON_THEME_DIR" || { echo "Direktori tidak ditemukan"; exit 1; }

echo "Watching for changes in $FILE..."

while inotifywait -e close_write,create,modify "$(dirname "$FILE")"; do
    if [[ -f "$FILE" ]]; then
        "$(which node)" "$ICON_THEME_DIR/generate.js"
    fi
done
