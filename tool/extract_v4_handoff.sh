#!/usr/bin/env bash
set -euo pipefail
ARCHIVE="${1:-artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz}"
DEST="${2:-.handoff/v4}"
mkdir -p "$DEST"
tar -xJf "$ARCHIVE" -C "$DEST"
printf 'Extracted v4 handoff to %s\n' "$DEST"
printf 'Read AGENT_START_HERE.md before using historical files.\n'
