#!/usr/bin/env bash
# Symlink skills and agents from this directory into ~/.agents and ~/.claude.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# link <source-dir> <dest-dir>: symlink every entry in source-dir into dest-dir.
link() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  for entry in "$src"/*; do
    [[ -e "$entry" ]] || continue
    local target="$dest/$(basename "$entry")"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "skip $target (exists and is not a symlink)" >&2
      continue
    fi
    ln -sfn "$entry" "$target"
    echo "$target -> $entry"
  done
}

link "$root/skills" "$HOME/.agents/skills"
link "$root/skills" "$HOME/.claude/skills"
link "$root/agents" "$HOME/.claude/agents"
