#!/usr/bin/env python3
import sys


def is_double_id(n: int) -> bool:
    """
    Return True if the decimal representation of n consists of
    two identical halves, e.g. 11, 6464, 123123.
    """
    s = str(n)
    length = len(s)

    # Only numbers of even length can be of the form XY with X == Y
    if length % 2 != 0:
        return False

    half = length // 2
    return s[:half] == s[half:]


def parse_ranges(text: str):
    """
    Parse a comma-separated list of ranges of the form 'start-end'
    and yield (start, end) tuples as integers.
    Example: '11-22,95-115' -> (11, 22), (95, 115)
    """
    # Allow line breaks and surrounding whitespace in the input
    cleaned = text.replace("\n", "").strip()
    if not cleaned:
        return

    for part in cleaned.split(","):
        part = part.strip()
        if not part:
            continue
        start_str, end_str = part.split("-")
        yield int(start_str), int(end_str)


def main():
    """
    Read ranges from stdin, find all IDs that have the 'double' pattern,
    and print the sum of those IDs.
    """
    # Read entire stdin; AoC style is usually 'input.txt' piped or redirected
    input_text = sys.stdin.read()

    total_sum = 0

    for start, end in parse_ranges(input_text):
        for n in range(start, end + 1):
            if is_double_id(n):
                total_sum += n

    print(total_sum)


if __name__ == "__main__":
    main()
