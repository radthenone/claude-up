#!/usr/bin/env bash
# Instalator claude-up:
#   curl -fsSL https://raw.githubusercontent.com/radthenone/claude-up/main/install.sh | bash
# Opcje (zmienne srodowiskowe):
#   CLAUDE_UP_VERSION=v0.1.0   konkretna wersja (domyslnie main)
#   CLAUDE_UP_BIN=/sciezka     wlasny katalog instalacji
set -euo pipefail

REF="${CLAUDE_UP_VERSION:-main}"
URL="https://raw.githubusercontent.com/radthenone/claude-up/$REF/claude-up"

die() { echo "claude-up: $*" >&2; exit 1; }

case "$(uname -s)" in
  Linux|Darwin) ;;
  MINGW*|MSYS*|CYGWIN*) die "Windows bez WSL nie jest obslugiwany (brak tmux). Zainstaluj WSL: wsl --install, potem uruchom instalator w WSL." ;;
  *) die "nieobslugiwany system: $(uname -s)" ;;
esac

# katalog: wlasny > tam gdzie juz jest > /usr/local/bin dla roota > ~/.local/bin
if [ -n "${CLAUDE_UP_BIN:-}" ]; then
  dest="$CLAUDE_UP_BIN"
elif existing="$(command -v claude-up 2>/dev/null)" && [ -w "$(dirname "$existing")" ]; then
  dest="$(dirname "$existing")"
elif [ "$(id -u)" = 0 ]; then
  dest="/usr/local/bin"
else
  dest="$HOME/.local/bin"
fi
mkdir -p "$dest"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
if command -v curl >/dev/null; then
  curl -fsSL "$URL" -o "$tmp" || die "nie moge pobrac $URL"
elif command -v wget >/dev/null; then
  wget -qO "$tmp" "$URL" || die "nie moge pobrac $URL"
else
  die "potrzebny curl albo wget"
fi
head -n1 "$tmp" | grep -q '^#!/usr/bin/env bash' || die "pobrany plik nie wyglada na claude-up ($URL)"

chmod 755 "$tmp"
mv "$tmp" "$dest/claude-up"
trap - EXIT
echo "zainstalowano: $dest/claude-up ($("$dest/claude-up" --version))"

missing=""
for c in tmux git python3 claude; do command -v "$c" >/dev/null || missing="$missing $c"; done
[ -z "$missing" ] || echo "uwaga: brak w PATH:$missing (python3 potrzebny tylko dla --session)"

case ":$PATH:" in
  *":$dest:"*) ;;
  *)
    rc="$HOME/.bashrc"; case "${SHELL:-}" in */zsh) rc="$HOME/.zshrc" ;; esac
    echo "uwaga: $dest nie jest w PATH. Dopisz i przeladuj powloke:"
    echo "  echo 'export PATH=\"$dest:\$PATH\"' >> $rc && source $rc"
    ;;
esac
