#!/bin/bash

# replace your own
FILE="/home/aris/.local/share/color-schemes/DankMatugen.colors"
ICON_THEME_DIR="/home/aris/Downloads/Vara"

cd "$ICON_THEME_DIR"

echo "Watching for changes in $FILE..."

while inotifywait -e close_write,create,modify "$(dirname "$FILE")"; do
    if [[ -f "$FILE" ]]; then
        /usr/bin/node "$ICON_THEME_DIR/generate.js"
    fi
done
