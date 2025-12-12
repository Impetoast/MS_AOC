#!/usr/bin/env python3
"""
Advent of Code 2025 - Day 12: Christmas Tree Farm

Input format:
- First section: N present shapes, each as:
    <index>:
    <row1>
    <row2>
    <row3>
  (blank lines may appear between shapes)

- Second section: one region per line:
    <W>x<H>: c0 c1 c2 ... c(N-1)

Task:
Count how many regions can fit all listed presents.
"""

import re
import sys
from typing import Dict, List, Tuple


def parse_shapes(lines: List[str]) -> Tuple[Dict[int, List[str]], int]:
    shapes: Dict[int, List[str]] = {}
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line == "":
            i += 1
            continue

        if line.endswith(":") and line[:-1].isdigit():
            idx = int(line[:-1])
            if i + 3 >= len(lines):
                raise ValueError("Shape header without 3 rows at line %d" % (i + 1))
            grid = [lines[i + 1].rstrip("\n"), lines[i + 2].rstrip("\n"), lines[i + 3].rstrip("\n")]
            shapes[idx] = grid
            i += 4
            continue

        break

    if not shapes:
        raise ValueError("No shapes found in input")

    return shapes, i


def count_hashes(grid: List[str]) -> int:
    return sum(row.count("#") for row in grid)


def parse_regions(lines: List[str], start: int, n_shapes: int) -> List[Tuple[int, int, List[int]]]:
    regions: List[Tuple[int, int, List[int]]] = []
    rx = re.compile(r"^\s*(\d+)x(\d+):\s*(.*)\s*$")

    for i in range(start, len(lines)):
        line = lines[i].strip()
        if line == "":
            continue
        m = rx.match(line)
        if not m:
            raise ValueError("Bad region line %d: %r" % (i + 1, lines[i]))
        w = int(m.group(1))
        h = int(m.group(2))
        nums = [int(x) for x in m.group(3).split()] if m.group(3).strip() else []
        if len(nums) != n_shapes:
            raise ValueError(
                "Region line %d has %d counts, expected %d"
                % (i + 1, len(nums), n_shapes)
            )
        regions.append((w, h, nums))

    return regions


def main() -> None:
    raw = sys.stdin.read().splitlines()
    shapes, pos = parse_shapes(raw)

    n_shapes = max(shapes.keys()) + 1
    areas = [0] * n_shapes
    for idx, grid in shapes.items():
        areas[idx] = count_hashes(grid)

    regions = parse_regions(raw, pos, n_shapes)

    ok = 0
    for w, h, counts in regions:
        need = 0
        for idx, c in enumerate(counts):
            need += c * areas[idx]
        if need <= w * h:
            ok += 1

    print(ok)


if __name__ == "__main__":
    main()
