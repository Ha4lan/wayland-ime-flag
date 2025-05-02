#!/bin/bash

FLAG="--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime"

SRC_DIR="/usr/share/applications"
DEST_DIR="$HOME/.local/share/applications"
mkdir -p "$DEST_DIR"

menu_items=()
while IFS= read -r -d '' file; do
    name=$(grep -m1 "^Name=" "$file" | cut -d= -f2-)
    if [[ -n "$name" ]]; then
        menu_items+=("$name|$(basename "$file")")
    fi
done < <(find "$SRC_DIR" -name "*.desktop" -print0)

selected_line=$(printf "%s\n" "${menu_items[@]}" | sort | wofi --dmenu --prompt "アプリを選んでください" --width 600 --height 400)

if [[ -z "$selected_line" ]]; then
    echo "❌ キャンセルされました。"
    exit 1
fi

filename=$(echo "$selected_line" | cut -d'|' -f2)
src_file="$SRC_DIR/$filename"
dest_file="$DEST_DIR/$filename"

cp "$src_file" "$dest_file"

if grep -qF "$FLAG" "$dest_file"; then
    notify-send "Waylandフラグ" "⚠️ すでに追加済み: $filename"
else
    sed -i "/^Exec=/ s|$| $FLAG|" "$dest_file"
    notify-send "Waylandフラグ" "✅ フラグを追加しました: $filename"
fi
