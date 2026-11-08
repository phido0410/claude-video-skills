#!/usr/bin/env bash
# Cài 28 skill làm video cho Claude Code vào ~/.claude/skills (dùng cho mọi dự án):
#   21 skill chính thức (Remotion, GSAP, Motion), tải bản mới nhất từ repo gốc;
#   7 skill trong thư mục skills/ của repo này.
# Skill tự viết đã có trên máy thì bản cũ được chuyển sang ~/.claude/skills-backup-<giờ>/ trước khi chép đè.
set -euo pipefail
cd "$(dirname "$0")"

DEST="$HOME/.claude/skills"
OFFICIAL=(remotion-dev/skills greensock/gsap-skills motiondivision/ai-kit)

command -v node >/dev/null || { echo "Thiếu Node.js (cần 22.20 trở lên): https://nodejs.org" >&2; exit 1; }
command -v git >/dev/null || { echo "Thiếu git" >&2; exit 1; }

for repo in "${OFFICIAL[@]}"; do
  echo "== $repo"
  npx -y skills add "$repo" --skill '*' -g -a claude-code --copy -y
done

mkdir -p "$DEST"
backup=""
for dir in skills/*/; do
  name=$(basename "$dir")
  if [ -e "$DEST/$name" ]; then
    backup="${backup:-$HOME/.claude/skills-backup-$(date +%Y%m%d-%H%M%S)}"
    mkdir -p "$backup"
    mv "$DEST/$name" "$backup/"
  fi
  cp -R "$dir" "$DEST/$name"
  echo "đã cài $name"
done
if [ -n "$backup" ]; then echo "Bản cũ của skill tự viết: $backup"; fi

command -v uv >/dev/null || echo "Lưu ý: chưa có uv, cần để tạo giọng đọc (xem README, mục Chuẩn bị)."
echo "Xong. Mở phiên Claude Code mới để thấy skill."
