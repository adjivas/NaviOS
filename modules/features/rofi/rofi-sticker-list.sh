#!/usr/bin/env bash

set -euo pipefail

STICKER_DIR="$HOME/Pictures/Stickers"

if [[ "${ROFI_RETV:-0}" == "1" ]]; then
    sticker="$ROFI_INFO"

    if [[ ! -f "$sticker" ]]; then
        echo "Sticker not found: $sticker" >&2
        exit 1
    fi

    # setsid -f "$ROFI_STICKER_SEND" "$WINDOW_ID" "$sticker"
    # setsid -f "$ROFI_STICKER_SEND" "$WINDOW_ID" "$sticker" </dev/null >/tmp/rofi-sticker-send.log 2>&1
    setsid -f "$ROFI_STICKER_SEND" "$WINDOW_ID" "$sticker" </dev/null &>/dev/null

    exit 0
else
    find "$STICKER_DIR" \
        -maxdepth 1 \
        -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print0 |
    while IFS= read -r -d '' file; do
        name="$(basename "$file")"

        printf '%s\0icon\x1f%s\x1finfo\x1f%s\n' \
            "$name" \
            "$file" \
            "$file"
    done
fi
