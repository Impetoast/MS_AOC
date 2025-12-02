/* REXX - Advent of Code 2025 Day 1 Part 1
 * Reads all lines from DDNAME AOCIN,
 * counts how many times the position hits 0.
 */

pos   = 50
zeros = 0

ddname = 'AOCIN'

/* Reading all lines from AOCIN into Stem L. */
address TSO
"EXECIO * DISKR" ddname "(STEM L. FINIS"

if rc <> 0 then do
    say 'EXECIO error, RC=' rc 'for DD' ddname
    exit 16
end

/* L.0 contains the amount of read lines */
do i = 1 to L.0
    line = strip(L.i)
    if line = '' then iterate

    dir  = substr(line, 1, 1)
    dist = strip(substr(line, 2))
    dist = dist + 0          /* convert into numeric */

    select
        when dir = 'L' then do
            tmp = pos - dist
            tmp = tmp // 100
            if tmp < 0 then tmp = tmp + 100
            pos = tmp
        end

        when dir = 'R' then do
            tmp = pos + dist
            tmp = tmp // 100
            pos = tmp
        end

        otherwise do
            say 'Unknown direction:' dir 'in line' i
            exit 8
        end
    end

    if pos = 0 then zeros = zeros + 1
end

say zeros
exit 0