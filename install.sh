#!/usr/bin/env bash
# Копирует скиллы PhotoCraft в папку скиллов Codex (macOS и Linux).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${CODEX_HOME:-$HOME/.codex}/skills"

if [ ! -d "$here/skills" ]; then
  echo "Не найдена папка skills рядом со скриптом: $here" >&2
  exit 1
fi

mkdir -p "$target"

count=0
for dir in "$here"/skills/*/; do
  name="$(basename "$dir")"
  if [ ! -f "$dir/SKILL.md" ]; then
    echo "Пропускаю $name: нет SKILL.md" >&2
    continue
  fi
  mkdir -p "$target/$name"
  cp -R "$dir". "$target/$name/"
  echo "Установлен: $name"
  count=$((count + 1))
done

echo
echo "Готово: скиллов $count, папка $target"

if command -v photocraft-cli >/dev/null 2>&1; then
  echo "photocraft-cli найден: $(photocraft-cli --version 2>/dev/null | head -n 1)"
else
  echo "photocraft-cli в PATH не найден."
  echo "macOS: скачай photocraft-cli-<версия>-macos-universal.zip со страницы"
  echo "https://github.com/storytold/photocraft/releases/latest и распакуй."
  echo "Codex подскажет остальное на первом запуске."
fi

echo "Перезапусти Codex, чтобы он увидел скиллы."
