def count_zero_positions(lines, start=50, size=100):
    pos = start
    zeros = 0

    for line in lines:
        line = line.strip()
        if not line:
            continue

        direction = line[0]
        steps = int(line[1:])

        if direction == "L":
            pos = (pos - steps) % size
        elif direction == "R":
            pos = (pos + steps) % size
        else:
            raise ValueError(f"Unknown direction: {direction}")

        if pos == 0:
            zeros += 1

    return zeros


if __name__ == "__main__":
    import sys

    lines = sys.stdin.read().strip().splitlines()
    result = count_zero_positions(lines)
    print(result)
