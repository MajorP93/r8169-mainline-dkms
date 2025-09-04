#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-master}"   # e.g. v6.16, v6.15.y, master, or a commit SHA
WORK="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[*] Cloning Linux $TAG ..."
git clone --depth=1 --branch "$TAG" https://github.com/torvalds/linux.git "$TMP/linux"

SRC_DIR="$TMP/linux/drivers/net/ethernet/realtek"

# Mandatory sources
SOURCES=(r8169_main.c r8169_firmware.c r8169_phy_config.c)

# Optional source (exists in newer trees)
if [[ -f "$SRC_DIR/r8169_leds.c" ]]; then
  SOURCES+=("r8169_leds.c")
fi

# Headers: prefer new names; fall back to old realtek.h
HEADERS=()
if [[ -f "$SRC_DIR/r8169.h" ]]; then
  HEADERS+=("r8169.h")
elif [[ -f "$SRC_DIR/realtek.h" ]]; then
  HEADERS+=("realtek.h")
else
  echo "!! Neither r8169.h nor realtek.h found in $SRC_DIR" >&2
  exit 1
fi
if [[ -f "$SRC_DIR/r8169_firmware.h" ]]; then
  HEADERS+=("r8169_firmware.h")
fi

mkdir -p "$WORK/src"
echo "[*] Importing sources: ${SOURCES[*]}  headers: ${HEADERS[*]}"
for f in "${SOURCES[@]}" "${HEADERS[@]}"; do
  cp -v "$SRC_DIR/$f" "$WORK/src/"
done

# Record provenance
printf '%s\n' "$TAG" > "$WORK/VENDOR_TAG"
git -C "$TMP/linux" rev-parse HEAD > "$WORK/VENDOR_COMMIT"
echo "[*] Imported r8169 from tag: $(cat "$WORK/VENDOR_TAG") commit: $(cat "$WORK/VENDOR_COMMIT")"
