def count_zero_positions_method_0x434C49434B(lines, start=50, size=100):
    """
    Advent of Code 2025 – Day 1, Part 2

    Count how many times the dial points at 0 using method 0x434C49434B:
    - The dial starts at `start` (default 50).
    - For each instruction Lx/Rx, the dial moves one click at a time.
    - We count EVERY click where the dial is exactly at 0,
      including clicks that are not at the end of the rotation.

    This implementation does not simulate each click.
    Instead, it uses modular arithmetic to count how many
    clicks in a given rotation land on 0.
    """
    pos = start
    zeros = 0

    for line in lines:
        line = line.strip()
        if not line:
            continue

        direction = line[0]
        distance = int(line[1:])

        if direction == "L":
            step = -1
        elif direction == "R":
            step = 1
        else:
            raise ValueError(f"Unknown direction: {direction}")

        d = distance

        # We want to know for which k in [1, d] the dial is at 0:
        #   pos_k = (pos + k * step) mod size == 0
        #
        # This is a linear congruence. Because step is ±1, there is
        # exactly one solution modulo `size`.
        #
        # Let k0 be the smallest positive k such that pos_k == 0.
        # Then all solutions are: k = k0 + n * size.
        #
        # Number of valid k in [1, d] is:
        #   0                       if k0 > d
        #   1 + (d - k0) // size    otherwise
        #
        # Compute k0 in [1, size].
        k0 = (-pos * step) % size
        if k0 == 0:
            k0 = size

        if k0 <= d:
            zeros += 1 + (d - k0) // size

        # Update final position after the whole rotation
        pos = (pos + step * d) % size

    return zeros


if __name__ == "__main__":
    import sys

    lines = sys.stdin.read().strip().splitlines()
    result = count_zero_positions_method_0x434C49434B(lines)
    print(result)
