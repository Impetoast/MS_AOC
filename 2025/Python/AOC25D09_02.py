import math
import sys
from pathlib import Path
from collections import deque

# Advent of Code 2025 - Day 9, Part 2
#
# Read list of red tiles (one "x,y" pair per line) from stdin.
# Compute the largest rectangle that:
#   - has two red tiles as opposite corners, and
#   - uses only red/green tiles (inside the loop of red+green tiles).

text = sys.stdin.read().strip()
if not text:
    print(0)
    raise SystemExit

lines = text.splitlines()
points = []
for line in lines:
    line = line.strip()
    if not line:
        continue
    x_str, y_str = line.split(",")
    points.append((int(x_str), int(y_str)))

n = len(points)
xs = [p[0] for p in points]
ys = [p[1] for p in points]

minx, maxx = min(xs), max(xs)
miny, maxy = min(ys), max(ys)

# Coordinate compression: build sets of x and y boundaries.
# We work in continuous coordinates where each tile is [x, x+1) x [y, y+1).
# The walkway between consecutive red tiles is a union of such 1x1 tiles.
xs_set = {minx - 1, maxx + 2}
ys_set = {miny - 1, maxy + 2}

for x, y in points:
    xs_set.add(x)
    xs_set.add(x + 1)
    ys_set.add(y)
    ys_set.add(y + 1)

segments = []
for i in range(n):
    x1, y1 = points[i]
    x2, y2 = points[(i + 1) % n]
    segments.append((x1, y1, x2, y2))
    if x1 == x2:
        # Vertical segment: walkway occupies [x1, x1+1] x [low, high+1]
        low, high = sorted((y1, y2))
        xs_set.add(x1)
        xs_set.add(x1 + 1)
        ys_set.add(low)
        ys_set.add(high + 1)
    else:
        # Horizontal segment: walkway occupies [low, high+1] x [y1, y1+1]
        low, high = sorted((x1, x2))
        ys_set.add(y1)
        ys_set.add(y1 + 1)
        xs_set.add(low)
        xs_set.add(high + 1)

xs_sorted = sorted(xs_set)
ys_sorted = sorted(ys_set)

Nx = len(xs_sorted)
Ny = len(ys_sorted)

x_to_idx = {x: i for i, x in enumerate(xs_sorted)}
y_to_idx = {y: i for i, y in enumerate(ys_sorted)}

# Grid of compressed cells:
#   0 = open (unknown yet)
#   1 = walkway (red/green boundary tiles)
#   2 = interior (green tiles inside the loop)
grid = [[0] * (Nx - 1) for _ in range(Ny - 1)]

# Mark walkway cells in compressed grid
for (x1, y1, x2, y2) in segments:
    if x1 == x2:
        # Vertical strip [x1, x1+1] x [low, high+1]
        x = x1
        low, high = sorted((y1, y2))
        xi1 = x_to_idx[x]
        xi2 = x_to_idx[x + 1]
        yi1 = y_to_idx[low]
        yi2 = y_to_idx[high + 1]
        for j in range(yi1, yi2):
            for i in range(xi1, xi2):
                grid[j][i] = 1
    else:
        # Horizontal strip [low, high+1] x [y1, y1+1]
        y = y1
        low, high = sorted((x1, x2))
        xi1 = x_to_idx[low]
        xi2 = x_to_idx[high + 1]
        yi1 = y_to_idx[y]
        yi2 = y_to_idx[y + 1]
        for j in range(yi1, yi2):
            for i in range(xi1, xi2):
                grid[j][i] = 1

Ny1 = len(grid)
Nx1 = len(grid[0])

visited = [[False] * Nx1 for _ in range(Ny1)]
dq = deque()

# Flood-fill from the outer border to mark cells that are outside the loop
for j in range(Ny1):
    for i in (0, Nx1 - 1):
        if grid[j][i] == 0 and not visited[j][i]:
            visited[j][i] = True
            dq.append((j, i))

for i in range(Nx1):
    for j in (0, Ny1 - 1):
        if grid[j][i] == 0 and not visited[j][i]:
            visited[j][i] = True
            dq.append((j, i))

dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]

while dq:
    j, i = dq.popleft()
    for dj, di in dirs:
        nj, ni = j + dj, i + di
        if 0 <= nj < Ny1 and 0 <= ni < Nx1:
            if grid[nj][ni] == 0 and not visited[nj][ni]:
                visited[nj][ni] = True
                dq.append((nj, ni))

# Any cell that is neither walkway nor reachable from outside is interior.
for j in range(Ny1):
    for i in range(Nx1):
        if grid[j][i] == 0 and not visited[j][i]:
            grid[j][i] = 2

# Build a 2D prefix sum over the "outside" cells (grid == 0).
# This lets us test in O(1) whether a whole rectangle contains
# any outside tiles.
outside = [[1 if grid[j][i] == 0 else 0 for i in range(Nx1)] for j in range(Ny1)]

H, W = Ny1, Nx1
ps = [[0] * (W + 1) for _ in range(H + 1)]

for j in range(H):
    for i in range(W):
        ps[j + 1][i + 1] = (
            outside[j][i]
            + ps[j][i + 1]
            + ps[j + 1][i]
            - ps[j][i]
        )

def outside_sum(j1: int, i1: int, j2: int, i2: int) -> int:
    """Sum of 'outside' cells in grid[j1:j2, i1:i2]."""
    return ps[j2][i2] - ps[j1][i2] - ps[j2][i1] + ps[j1][i1]

max_area = 0

# Try all pairs of red tiles as opposite corners
for a in range(n):
    x1, y1 = points[a]
    for b in range(a + 1, n):
        x2, y2 = points[b]

        # Must be diagonally opposite corners
        if x1 == x2 or y1 == y2:
            continue

        if x1 < x2:
            xmin, xmax = x1, x2
        else:
            xmin, xmax = x2, x1

        if y1 < y2:
            ymin, ymax = y1, y2
        else:
            ymin, ymax = y2, y1

        # Convert rectangle [xmin..xmax] x [ymin..ymax] in tile coordinates
        # to compressed grid indices: continuous rectangle [xmin, xmax+1) x [ymin, ymax+1)
        ix1 = x_to_idx[xmin]
        ix2 = x_to_idx[xmax + 1]
        iy1 = y_to_idx[ymin]
        iy2 = y_to_idx[ymax + 1]

        # If there are no outside cells in this rectangle,
        # then every tile in it is red or green.
        if outside_sum(iy1, ix1, iy2, ix2) == 0:
            area = (xmax - xmin + 1) * (ymax - ymin + 1)
            if area > max_area:
                max_area = area

print(max_area)
