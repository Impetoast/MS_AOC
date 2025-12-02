#!/usr/bin/env python3
import sys


def is_repeated_pattern(n: int) -> bool:
    """
    Return True if the decimal representation of n consists of
    some non-empty digit block repeated at least twice.

    Examples (invalid IDs under the new rules):
      - 11          -> "1" repeated 2 times
      - 999         -> "9" repeated 3 times
      - 123123      -> "123" repeated 2 times
      - 12341234    -> "1234" repeated 2 times
      - 1212121212  -> "12" repeated 5 times
      - 1111111     -> "1" repeated 7 times
    """
    s = str(n)
    length = len(s)

    # Try all possible block lengths for the repeating pattern.
    # The block length must be at least 1 and at most half
    # the total length (because we need at least 2 repeats).
    for block_len in range(1, length // 2 + 1):
        # Total length must be a multiple of the block length
        if length % block_len != 0:
            continue

        repeats = length // block_len
        if repeats < 2:
            continue

        block = s[:block_len]
        # Check if repeating the block 'repeats' times reproduces the whole string
        if block * repeats == s:
            return True

    return False


def parse_ranges(text: str):
    """
    Parse a comma-separated list of ranges of the form 'start-end'
    and yield (start, end) tuples as integers.

    Example:
      '11-22,95-115' -> yields (11, 22), (95, 115)
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
    Read ranges from stdin, find all IDs that match the "repeated pattern"
    rule (Part 2), and print the sum of those IDs.
    """
    # Read entire stdin; AoC style is usually 'input.txt' piped or redirected
    input_text = sys.stdin.read()

    total_sum = 0

    for start, end in parse_ranges(input_text):
        for n in range(start, end + 1):
            if is_repeated_pattern(n):
                total_sum += n

    print(total_sum)


if __name__ == "__main__":
    main()
