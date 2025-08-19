#!/bin/sh
echo -ne '\033c\033]0;minesweeper-game\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/minesweeper-game-linux.x86_64" "$@"
