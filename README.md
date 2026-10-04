# claude-up

Sesje [Claude Code](https://claude.com/claude-code) z Remote Control w tmux, osobno dla każdego projektu na serwerze.

Piszesz z Claude w terminalu (SSH, Orca, cokolwiek). Kiedy zamkniesz terminal, sesja nie ginie: działa dalej w tmux, a z telefonu albo z claude.ai/code możesz ją podglądać i sterować nią.

## Wymagania

- Linux, macOS albo WSL (na Windowsie bez WSL nie ma tmux)
- `bash`, `tmux`, `git`
- `python3`, tylko dla `--session`
- `claude` w `PATH`, zalogowany (`claude auth status`)

## Instalacja

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/radthenone/claude-up/main/claude-up -o ~/.local/bin/claude-up
chmod +x ~/.local/bin/claude-up
```

`~/.local/bin` musi być w `PATH`. Aktualizacja to ta sama komenda. Konkretną wersję dostaniesz, podmieniając `main` w URL na tag, np. `v0.1.0`.

## Użycie

Każdy projekt ma jedną sesję tmux. W oknie 0 działa serwer `claude remote-control`, a każde kolejne okno to osobna rozmowa.

```bash
cd ~/projects/moj-projekt

claude-up .                 # serwer remote-control dla repo (nowe sesje zakładasz z aplikacji)
claude-up --new             # nowa rozmowa w terminalu, widoczna też w aplikacji
claude-up --new "Bugfix X"  # to samo, z własną nazwą
claude-up --session         # lista żywych sesji Claude w repo
claude-up --session 2       # wróć do sesji nr 2
claude-up --resume          # wznów starą rozmowę (lista do wyboru) w terminalu + aplikacji
```

Zarządzanie:

```bash
claude-up projects/moj-projekt "Nazwa"  # serwer dla wskazanego repo (ścieżka od $HOME, ./ albo /bezwzględna)
claude-up --all                          # serwer dla każdego repo w katalogu projektów
claude-up --list                         # sesje tmux
claude-up --stop <nazwa-tmux>
claude-up --stop-all                     # wszystkie sesje claude-up
```

`Ctrl-b d` albo zamknięcie terminala odłącza tylko widok, Claude pracuje dalej.

## Terminal czy aplikacja

| Gdzie zakładasz sesję | Terminal | Aplikacja |
|---|---|---|
| `claude-up --new` / `--resume` | tak | tak |
| w aplikacji (przez serwer z `claude-up .`) | nie | tak |

Sesja założona w aplikacji działa bez terminala, więc nie da się jej podpiąć w tmux. Żeby przenieść ją do terminala, zarchiwizuj ją w aplikacji, a potem uruchom `claude-up --resume` i wybierz ją z listy. Rozmowa wraca z pełną historią, a w aplikacji pojawia się pod nowym linkiem.

## Konfiguracja

| Co | Jak |
|---|---|
| Katalog projektów dla `--all` | `export CLAUDE_UP_ROOT=~/code`. Bez zmiennej: `~/projects`, a gdy go nie ma, bieżący katalog |
| Nazwa sesji w aplikacji | plik `.claude-name` w repo (pierwsza linia), domyślnie nazwa katalogu |

## Uwagi

- `--session` czyta `~/.claude/sessions/*.json`, czyli wewnętrzny format Claude Code (testowane na 2.1.289). Po aktualizacji Claude Code lista może przestać działać. Pozostałe komendy korzystają tylko z udokumentowanych flag CLI.
- `--stop` i `--stop-all` zamykają całą sesję tmux projektu, razem z rozmowami z `--new`.
- Okno z `--new` nie restartuje się samo. Gdy Claude w nim wyjdzie, rozmowę wznowisz przez `claude-up --resume`.

## Licencja

MIT
