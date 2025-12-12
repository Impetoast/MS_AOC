/* REXX  Advent of Code 2025  Day 10: Factory
 * Compute minimal total button presses to configure all machines.
 * Input : DDNAME AOCIN (one machine per line)
 * Output: total minimal presses printed to SYSTSPRT
 */

ddname  = 'AOCIN'

/* Read all input lines into stem L. */
address TSO
"EXECIO * DISKR" ddname "(STEM L. FINIS"
if rc <> 0 then do
    say 'EXECIO error, RC=' rc 'for DD' ddname
    exit 16
end

totalPresses = 0

do li = 1 to L.0
    line = strip(L.li)
    if line = '' then iterate

    /* Extract indicator pattern between [ and ]. */
    lb = pos('[', line)
    rb = pos(']', line)
    if lb = 0 | rb = 0 then do
        say 'Malformed line' li':' line
        exit 8
    end
    pattern = substr(line, lb + 1, rb - lb - 1)
    n = length(pattern)

    /* Build target state (0 = off, 1 = on) and reset current state. */
    do i = 1 to n
        ch = substr(pattern, i, 1)
        if ch = '#' then target.i = 1
        else                target.i = 0
        state.i = 0
    end

    /* Cut off everything before ] and after { (joltage list). */
    rest = substr(line, rb + 1)
    lbbrace = pos('{', rest)
    if lbbrace > 0 then
        rest = substr(rest, 1, lbbrace - 1)

    /* Parse button definitions of form (0,2,3,4). */
    btnCount = 0
    work = rest
    p = pos('(', work)
    do while p > 0
        q = pos(')', work, p)
        if q = 0 then leave

        btnCount = btnCount + 1
        contents = substr(work, p + 1, q - p - 1)

        /* Split by comma. Store positions as 1-based indices. */
        btnCountLen = 0
        numbers = contents || ','
        do while numbers <> ''
            parse var numbers num ',' numbers
            num = strip(num)
            if num <> '' then do
                btnCountLen = btnCountLen + 1
                btn.btnCount.btnCountLen = num + 1
            end
        end
        btn.btnCount.0 = btnCountLen

        work = substr(work, q + 1)
        p = pos('(', work)
    end

    maxBtn = btnCount
    best   = maxBtn + 1

    /* Depth-first search over all subsets of buttons with pruning. */
    call dfs 1, 0

    if best = maxBtn + 1 then do
        say 'No solution found for line' li
        exit 8
    end

    totalPresses = totalPresses + best
end

say totalPresses
exit 0

/* Toggle all lights affected by button b. */
toggle:
    procedure expose btn. state.
    parse arg b

    do k = 1 to btn.b.0
        p = btn.b.k
        if state.p = 0 then state.p = 1
        else                  state.p = 0
    end
return

/* Recursive search:
 * idx     - current button index (1..maxBtn+1)
 * presses - number of buttons pressed so far
 */
dfs:
    procedure expose n maxBtn btn. state. target. best
    parse arg idx, presses

    /* Prune if already worse than best solution. */
    if presses >= best then return

    /* If we considered all buttons, check if state matches target. */
    if idx > maxBtn then do
        do i = 1 to n
            if state.i <> target.i then return
        end
        best = presses
        return
    end

    /* Option 1: do not press this button. */
    call dfs idx + 1, presses

    /* Option 2: press this button once. */
    call toggle idx
    call dfs idx + 1, presses + 1
    call toggle idx   /* undo */
return
