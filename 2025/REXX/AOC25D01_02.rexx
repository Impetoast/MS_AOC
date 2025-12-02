/* REXX  Advent of Code 2025 – Day 1, Part 2
 * Count how many times the dial points at 0,
 * including every intermediate click during a rotation.
 * Input  : DDNAME AOCIN  (one command per line: L### or R###)
 * Output : total count of zero positions printed to SYSTSPRT
 */

pos   = 50       /* starting position */
zeros = 0
ddname = 'AOCIN'

/* Read all input lines into stem L. */
address TSO
"EXECIO * DISKR" ddname "(STEM L. FINIS"
if rc <> 0 then do
    say 'EXECIO error, RC=' rc 'for DD' ddname
    exit 16
end

do i = 1 to L.0
    line = strip(L.i)
    if line = '' then iterate

    dir  = substr(line, 1, 1)
    dist = strip(substr(line, 2))
    dist = dist + 0              /* convert to number */

    /* Determine step direction */
    if dir = 'L' then step = -1
    else if dir = 'R' then step = 1
    else do
        say 'Unknown direction at line' i':' dir
        exit 8
    end

    /* Rotate the dial step by step */
    do j = 1 to dist
        pos = pos + step

        /* wrap around 0–99 */
        if pos >= 100 then pos = pos - 100
        if pos < 0   then pos = pos + 100

        /* count every time dial points at 0 */
        if pos = 0 then zeros = zeros + 1
    end
end

say zeros
exit 0
