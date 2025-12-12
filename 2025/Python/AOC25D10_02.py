#!/usr/bin/env python3
# Advent of Code 2025 - Day 10, Part 2: Factory (Joltage Mode)
#
# Reads input from stdin, one machine per line.
# Each line:
#   [lights] (button...) ... {targets}
# We ignore the lights, and treat buttons as which counters they increment.
# For each machine, we solve A * x = t with:
#   - A: m x n 0/1 matrix (rows = counters, cols = buttons)
#   - x_j >= 0 integers (how often each button is pressed)
#   - t: target counter values
# Objective: minimize sum_j x_j.

import sys
from fractions import Fraction


def parse_buttons_targets(line: str):
    """Parse one machine line into (buttons, targets) without regex."""
    line = line.strip()

    # Targets sind im letzten {...} auf der Zeile
    lb = line.rfind("{")
    rb = line.rfind("}")
    if lb == -1 or rb == -1 or rb < lb:
        raise ValueError(f"No target list in line: {line}")
    targets_str = line[lb + 1 : rb]
    targets = [int(x) for x in targets_str.split(",")]

    # Alles davor enthält die Buttons in (...)
    before = line[:lb]
    buttons = []
    i = 0
    while True:
        p = before.find("(", i)
        if p == -1:
            break
        q = before.find(")", p)
        if q == -1:
            break
        contents = before[p + 1 : q].strip()
        if contents:
            buttons.append([int(x) for x in contents.split(",")])
        i = q + 1

    return buttons, targets


def build_A_and_ub(line: str):
    """Build coefficient matrix A and upper bounds ub for one machine."""
    buttons, targets = parse_buttons_targets(line)
    m = len(targets)
    n = len(buttons)

    # A[i][j] = 1 if button j affects counter i, else 0
    A = [[0] * n for _ in range(m)]
    for j, idxs in enumerate(buttons):
        for i in idxs:
            A[i][j] = 1

    # Upper bound ub[j]: pressing button j more than this would overshoot
    # some counter's target.
    ub = []
    for j, idxs in enumerate(buttons):
        if not idxs:
            ub.append(0)
        else:
            ub.append(min(targets[i] for i in idxs))
    return A, targets, ub


def rref_solve(A, t):
    """
    Compute RREF of the augmented system [A | t] over the rationals.

    Returns:
      pivot_cols: list of basic variable indices
      free_cols : list of free variable indices
      const     : dict pivot_col -> Fraction (constant term)
      coeff     : dict pivot_col -> dict(free_col -> Fraction)
                  s.t. for each pivot p:
                    x_p = const[p] + sum_f coeff[p][f] * x_f
    """
    m = len(A)
    if m == 0:
        return [], list(range(len(A[0]) if A else 0)), {}, {}

    n = len(A[0])
    # Build augmented matrix M (m x (n+1))
    M = [
        [Fraction(A[i][j]) for j in range(n)] + [Fraction(t[i])]
        for i in range(m)
    ]

    pivot_col = [-1] * n
    pivot_row = [-1] * m
    row = 0

    for col in range(n):
        # Find pivot row at/below current row
        pivot = None
        for r in range(row, m):
            if M[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            continue

        # Swap into place
        M[row], M[pivot] = M[pivot], M[row]

        # Normalize pivot row
        pivval = M[row][col]
        M[row] = [x / pivval for x in M[row]]

        # Eliminate this column from all other rows
        for r in range(m):
            if r == row:
                continue
            factor = M[r][col]
            if factor != 0:
                M[r] = [
                    M[r][c] - factor * M[row][c]
                    for c in range(n + 1)
                ]

        pivot_col[col] = row
        pivot_row[row] = col
        row += 1
        if row == m:
            break

    # Check for inconsistency (0 ... 0 | nonzero)
    for r in range(m):
        if all(M[r][c] == 0 for c in range(n)) and M[r][n] != 0:
            raise ValueError("Inconsistent system")

    pivot_cols = [c for c in range(n) if pivot_col[c] != -1]
    free_cols = [c for c in range(n) if pivot_col[c] == -1]

    const = {}
    coeff = {}
    for c in pivot_cols:
        r = pivot_col[c]
        const_c = M[r][n]
        coeff_c = {}
        # Equation is: x_c + sum_f M[r][f] * x_f = const_c
        # => x_c = const_c - sum_f M[r][f] * x_f
        for f in free_cols:
            if M[r][f] != 0:
                coeff_c[f] = -M[r][f]
        const[c] = const_c
        coeff[c] = coeff_c

    return pivot_cols, free_cols, const, coeff


def solve_machine(line: str) -> int:
    """
    Solve one machine's system A x = t with x >= 0 integer,
    minimizing total presses sum(x_j).
    """
    A, t, ub = build_A_and_ub(line)
    m = len(A)
    n = len(A[0])

    pivot_cols, free_cols, const, coeff = rref_solve(A, t)
    d = len(free_cols)

    best = None

    def check_solution(f_vals_by_col):
        nonlocal best
        # Build x vector of length n
        x = [0] * n

        # Free variables
        for col, val in f_vals_by_col.items():
            if val < 0 or val > ub[col]:
                return
            x[col] = val

        # Pivot variables
        for p in pivot_cols:
            val = const[p]
            for f, c in coeff[p].items():
                val = val + c * f_vals_by_col[f]

            # Must be integer
            if val.denominator != 1:
                return
            v = val.numerator
            if v < 0 or v > ub[p]:
                return
            x[p] = v

        # Verify A x = t (safety check)
        for i in range(m):
            s = 0
            for j in range(n):
                if A[i][j]:
                    s += x[j]
            if s != t[i]:
                return

        total = sum(x)
        if best is None or total < best:
            best = total

    # Enumerate free-variable combinations (dimension <= 3 in this puzzle)
    if d == 0:
        check_solution({})
    elif d == 1:
        f0 = free_cols[0]
        for v0 in range(0, ub[f0] + 1):
            check_solution({f0: v0})
    elif d == 2:
        f0, f1 = free_cols
        for v0 in range(0, ub[f0] + 1):
            for v1 in range(0, ub[f1] + 1):
                check_solution({f0: v0, f1: v1})
    elif d == 3:
        f0, f1, f2 = free_cols
        for v0 in range(0, ub[f0] + 1):
            for v1 in range(0, ub[f1] + 1):
                for v2 in range(0, ub[f2] + 1):
                    check_solution({f0: v0, f1: v1, f2: v2})
    else:
        # Für dieses Input passiert das nicht.
        raise ValueError(f"Unexpected free-variable dimension: {d}")

    if best is None:
        raise ValueError("No non-negative integer solution found")
    return best


def main():
    text = sys.stdin.read().strip()
    if not text:
        return
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    total = 0
    for line in lines:
        total += solve_machine(line)
    print(total)


if __name__ == "__main__":
    main()
