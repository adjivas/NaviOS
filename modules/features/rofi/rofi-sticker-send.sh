#!/usr/bin/env bash

set -euo pipefail

window_id="$1"
sticker="$2"

echo "start"
echo "WINDOW_ID=$window_id"
echo "sticker=$sticker"

wl-copy < "$sticker"

niri msg action focus-window --id "$window_id"
# sleep 1

echo "before paste"
wtype -M ctrl -k v -m ctrl
echo "after paste"
