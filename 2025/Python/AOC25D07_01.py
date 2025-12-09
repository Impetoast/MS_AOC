import math
import sys
from pathlib import Path

# Read full input from stdin
text = sys.stdin.read().strip()
lines = text.splitlines()

if not lines:
    print(0)
    raise SystemExit

H = len(lines)
W = max(len(l) for l in lines)

def get_char(line: str, c: int) -> str:
    """Return character at column c or '.' if line is too short."""
    return line[c] if c < len(line) else '.'

# Find starting position 'S'
s_row = None
s_col = None
for r, row in enumerate(lines):
    c = row.find('S')
    if c != -1:
        s_row = r
        s_col = c
        break

if s_row is None:
    # No start found, no splits possible
    print(0)
    raise SystemExit

# Beam presence per column in the current row
beams = [False] * W
beams[s_col] = True

splits = 0

# Move beams from the row containing 'S' down to the last row
for r in range(s_row, H - 1):
    next_row = lines[r + 1] if r + 1 < H else ""
    new_beams = [False] * W

    for c in range(W):
        if not beams[c]:
            continue

        ch = get_char(next_row, c)

        if ch == '^':
            # Beam hits splitter: current beam stops, two new beams left/right
            splits += 1
            if c - 1 >= 0:
                new_beams[c - 1] = True
            if c + 1 < W:
                new_beams[c + 1] = True
        else:
            # Empty (or any non-splitter) cell: beam continues straight down
            new_beams[c] = True

    beams = new_beams

print(splits)
