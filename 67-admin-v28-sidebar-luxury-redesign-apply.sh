#!/usr/bin/env bash
set -Eeuo pipefail

# Compatibility alias for V28 Luxury Sidebar.
# OpenHands previously looked for this filename while the canonical patch is:
# 67-admin-v28-luxury-sidebar-apply.sh

CANONICAL_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v28-luxury-sidebar-apply.sh"
TMP="/tmp/67-admin-v28-luxury-sidebar-apply.sh"

curl -fsSL "$CANONICAL_URL" -o "$TMP"
chmod +x "$TMP"
exec bash "$TMP"
