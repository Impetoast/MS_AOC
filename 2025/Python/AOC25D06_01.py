import math
import sys
from pathlib import Path

text = sys.stdin.read().strip()
lines = text.splitlines()
ops_line = lines[-1]
num_lines = lines[:-1]

W = max(len(l) for l in lines)

def get(line, c):
    return line[c] if c < len(line) else ' '

blank = []
for c in range(W):
    blank.append(all(get(line, c) == ' ' for line in lines))

segments = []
in_seg = False
for c in range(W):
    if not blank[c]:
        if not in_seg:
            seg_start = c
            in_seg = True
    else:
        if in_seg:
            segments.append((seg_start, c - 1))
            in_seg = False
if in_seg:
    segments.append((seg_start, W - 1))

total = 0
for start, end in segments:
    nums = []
    for row in num_lines:
        slice_ = row[start:end+1]
        digits = ''.join(ch for ch in slice_ if ch.isdigit())
        nums.append(int(digits))
    slice_ops = ops_line[start:end+1]
    op = next(ch for ch in slice_ops if ch in '+*')
    val = sum(nums) if op == '+' else math.prod(nums)
    total += val

print(total)  # 5524274308182
