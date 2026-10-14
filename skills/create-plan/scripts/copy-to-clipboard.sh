#!/usr/bin/env sh
# Copy stdin to the system clipboard. Exits non-zero if no clipboard tool is found.
set -eu

if command -v pbcopy >/dev/null 2>&1; then
  exec pbcopy
elif command -v clip.exe >/dev/null 2>&1; then
  exec clip.exe
elif [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
  exec wl-copy
elif command -v xclip >/dev/null 2>&1; then
  exec xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  exec xsel --clipboard --input
fi

echo "copy-to-clipboard: no clipboard tool found (pbcopy, clip.exe, wl-copy, xclip, xsel)" >&2
exit 1
