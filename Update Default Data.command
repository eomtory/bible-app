#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
INPUT_FILE="$SCRIPT_DIR/backup/bible-app-backup.json"
OUTPUT_FILE="$SCRIPT_DIR/data/default-data.js"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "$TMP_FILE"
}

close_terminal_window() {
  osascript <<'APPLESCRIPT' >/dev/null 2>&1 || true
tell application "Terminal"
  if (count of windows) > 0 then
    close front window saving no
  end if
end tell
APPLESCRIPT
}

trap cleanup EXIT

if [[ ! -f "$INPUT_FILE" ]]; then
  osascript -e 'display alert "Backup JSON not found" message "backup/bible-app-backup.json 파일이 없습니다." as critical'
  close_terminal_window
  exit 1
fi

{
  printf 'window.BIBLE_APP_DEFAULT_DATA = '
  cat "$INPUT_FILE"
  printf ';\n'
} > "$TMP_FILE"

mv "$TMP_FILE" "$OUTPUT_FILE"

osascript -e 'display alert "Update complete" message "data/default-data.js 파일을 갱신했습니다."'
close_terminal_window
