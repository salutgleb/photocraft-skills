#!/usr/bin/env bash
# Копирует скиллы в папку скиллов Codex (macOS и Linux).
#
#   bash install.sh                  папка определяется сама
#   bash install.sh ~/.codex/skills  поставить в названную папку
#
# По справке Codex личные скиллы лежат в ~/.agents/skills. Более старые
# версии ставили их в ~/.codex/skills. Если этот набор уже стоит в одной
# из папок, он обновляется там же, чтобы не появилось двух копий.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -n "${1:-}" ]; then
  target="$1"
elif [ -d "$HOME/.agents/skills/photocraft-base" ]; then
  target="$HOME/.agents/skills"
elif [ -d "${CODEX_HOME:-$HOME/.codex}/skills/photocraft-base" ]; then
  target="${CODEX_HOME:-$HOME/.codex}/skills"
else
  target="$HOME/.agents/skills"
fi

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
  echo "  macOS: скачай photocraft-cli-<версия>-macos-universal.zip со страницы"
  echo "  https://github.com/storytold/photocraft/releases/latest и распакуй."
  echo "  Codex подскажет остальное на первом запуске."
fi

if command -v lightcraft-cli >/dev/null 2>&1; then
  echo "lightcraft-cli найден: $(lightcraft-cli --version 2>/dev/null | head -n 1)"
else
  echo "lightcraft-cli не найден. Он не обязателен: нужен только для скиллов lightcraft-*."
fi

echo
echo "Перезапусти Codex, чтобы он увидел скиллы."
echo "Если после перезапуска скиллов нет в списке, поставь их во вторую папку:"
echo "  bash install.sh ~/.codex/skills"
