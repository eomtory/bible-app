#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"

close_terminal_window() {
  osascript <<'APPLESCRIPT' >/dev/null 2>&1 || true
tell application "Terminal"
  if (count of windows) > 0 then
    close front window saving no
  end if
end tell
APPLESCRIPT
}

cd "$SCRIPT_DIR"

COMMIT_MESSAGE="$(osascript <<'APPLESCRIPT'
text returned of (display dialog "커밋 메시지를 입력하세요." default answer "Update bible app data" buttons {"취소", "확인"} default button "확인")
APPLESCRIPT
)"

git add -- \
  admin.html \
  data/default-data.js \
  backup/bible-app-backup.json \
  BibleCards_Images \
  offline-index.html \
  "Update Default Data.command" \
  "Publish Bible Data.command"

if git diff --cached --quiet; then
  osascript -e 'display alert "No staged changes" message "커밋할 데이터 변경이 없습니다."'
  close_terminal_window
  exit 0
fi

git commit -m "$COMMIT_MESSAGE"
git push origin main

osascript -e 'display alert "Publish complete" message "GitHub main 브랜치로 푸시했습니다."'
close_terminal_window
