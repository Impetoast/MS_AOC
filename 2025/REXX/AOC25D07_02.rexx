/* REXX  Advent of Code 2025 – Day 7, Part 2
 * Count how many quantum tachyon timelines exist.
 *
 * Model:
 *  - Grid of '.', '^', and a single 'S'.
 *  - Particle starts at 'S' and moves downward.
 *  - If the cell below is '.': it continues straight down.
 *  - If the cell below is '^': time splits:
 *        one timeline goes down-left,
 *        the other goes down-right.
 *    If a branch would go outside the grid, that timeline ends there.
 *  - When a particle reaches the last row, the next step leaves the manifold
 *    and that counts as one finished timeline.
 *
 * Input : DDNAME AOCIN  (full manifold, one row per line)
 * Output: number of timelines printed to SYSTSPRT
 */

numeric digits 30          /* enough precision for big counts */

ddname = 'AOCIN'

/* Read the whole grid into IN. */
address TSO
"EXECIO * DISKR" ddname "(STEM IN. FINIS"
if rc <> 0 then do
    say 'EXECIO error, RC=' rc 'for DD' ddname
    exit 16
end

lineCount = IN.0
if lineCount = 0 then do
    say 'No input on DD' ddname
    exit 16
end

/* Assume all lines have the same width as the first line. */
width = length(IN.1)

/* Find start position 'S'. */
srow = 0
scol = 0
do r = 1 to lineCount
    p = pos('S', IN.r)
    if p > 0 then do
        srow = r
        scol = p
        leave
    end
end

if srow = 0 then do
    say "No start 'S' found in input"
    exit 8
end

/* Dynamic programming over rows:
 * dp.c   = number of timelines with the particle currently at row r, column c
 * next.c = same for next row (r+1)
 */
do c = 1 to width
    dp.c   = 0
    next.c = 0
end

dp.scol = 1            /* start with one particle at 'S' row/column       */
done = 0               /* finished timelines (already left the manifold)  */

/* Process from the row of 'S' down to the row above the last line. */
do r = srow to lineCount - 1
    targetRow = r + 1
    rowStr    = IN.targetRow

    /* Clear next-row DP. */
    do c = 1 to width
        next.c = 0
    end

    /* For each column in this row, propagate timelines to the next row. */
    do c = 1 to width
        ways = dp.c
        if ways = 0 then iterate

        ch = substr(rowStr, c, 1)

        if ch = '^' then do
            /* Split into left and right timelines. */

            /* Left branch */
            if c > 1 then do
                idx = c - 1
                next.idx = next.idx + ways
            end
            else do
                /* Going left would leave the manifold immediately. */
                done = done + ways
            end

            /* Right branch */
            if c < width then do
                idx = c + 1
                next.idx = next.idx + ways
            end
            else do
                /* Going right would leave the manifold immediately. */
                done = done + ways
            end
        end
        else do
            /* Any non-splitter cell: continue straight down. */
            next.c = next.c + ways
        end
    end

    /* Move to the next row. */
    do c = 1 to width
        dp.c = next.c
    end
end

/* Any timelines that have reached the last row will leave the
 * manifold on the next step – each counts as one finished timeline.
 */
do c = 1 to width
    done = done + dp.c
end

say done
exit 0
