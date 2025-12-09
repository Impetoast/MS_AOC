def largest_circuit_product(lines, k=1000):
    # Parse coordinates from input
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

    # Compute all pairwise squared distances and remember indices
    pairs = []
    for i in range(n):
        x1, y1, z1 = points[i]
        for j in range(i + 1, n):
            x2, y2, z2 = points[j]
            dx = x1 - x2
            dy = y1 - y2
            dz = z1 - z2
            d2 = dx * dx + dy * dy + dz * dz
            # Sorting by (d2, i, j) reproduces the deterministic order
            pairs.append((d2, i, j))

    pairs.sort(key=lambda t: (t[0], t[1], t[2]))

    max_pairs = n * (n - 1) // 2
    if k > max_pairs:
        k = max_pairs
    pairs = pairs[:k]

    # Union-Find (Disjoint Set Union) to build circuits
    parent = list(range(n))
    size = [1] * n

    def find(x):
        while parent[x] != x:
            x = parent[x]
        return x

    for _, i, j in pairs:
        ri = find(i)
        rj = find(j)

        if ri == rj:
            continue

        # Union by size: attach smaller tree under larger
        if size[ri] < size[rj]:
            ri, rj = rj, ri

        parent[rj] = ri
        size[ri] += size[rj]

    # Collect component sizes (roots only)
    components = []
    for i in range(n):
        if parent[i] == i:
            components.append(size[i])

    components.sort(reverse=True)

    if len(components) < 3:
        raise ValueError("Expected at least three circuits")

    return components[0] * components[1] * components[2]


if __name__ == "__main__":
    import sys

    text = sys.stdin.read().strip()
    if not text:
        print(0)
    else:
        lines = text.splitlines()
        result = largest_circuit_product(lines, k=1000)
        print(result)
