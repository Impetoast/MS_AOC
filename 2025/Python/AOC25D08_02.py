def last_connection_x_product(lines):
    """
    Connect pairs of junction boxes in order of increasing distance until
    all boxes form a single circuit. Return the product of the X coordinates
    of the final pair that completes the circuit.
    """
    # Parse coordinates
    points = []
    for line in lines:
        line = line.strip()
        if not line:
            continue

        x_str, y_str, z_str = line.split(",")
        x = int(x_str)
        y = int(y_str)
        z = int(z_str)
        points.append((x, y, z))

    n = len(points)
    if n < 2:
        return 0

    # Build list of all pairwise distances (squared) with indices
    edges = []
    for i in range(n):
        x1, y1, z1 = points[i]
        for j in range(i + 1, n):
            x2, y2, z2 = points[j]
            dx = x1 - x2
            dy = y1 - y2
            dz = z1 - z2
            d2 = dx * dx + dy * dy + dz * dz
            # Sorting by (d2, i, j) makes the order deterministic
            edges.append((d2, i, j))

    edges.sort(key=lambda t: (t[0], t[1], t[2]))

    # Union-Find (Disjoint Set Union)
    parent = list(range(n))
    size = [1] * n
    components = n

    def find(x):
        while parent[x] != x:
            x = parent[x]
        return x

    last_i = None
    last_j = None

    # Process edges from shortest to longest
    for _, i, j in edges:
        ri = find(i)
        rj = find(j)

        if ri == rj:
            continue

        # Union by size: attach smaller tree under larger one
        if size[ri] < size[rj]:
            ri, rj = rj, ri

        parent[rj] = ri
        size[ri] += size[rj]
        components -= 1

        # First time we reach a single component: this is the last needed cable
        if components == 1:
            last_i = i
            last_j = j
            break

    if last_i is None:
        # Already connected or not enough points
        return 0

    x1 = points[last_i][0]
    x2 = points[last_j][0]
    return x1 * x2


if __name__ == "__main__":
    import sys

    text = sys.stdin.read().strip()
    if not text:
        print(0)
    else:
        lines = text.splitlines()
        result = last_connection_x_product(lines)
        print(result)
