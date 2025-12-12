/* REXX  Advent of Code 2025 - Day 11, Part 1
 * Count all distinct paths from device 'you' to device 'out'.
 *
 * Input : DDNAME AOCIN (each line:  name: targets...)
 * Output: number of paths printed to SYSTSPRT / terminal
 */

numeric digits 20

ddname = 'AOCIN'

/* --------------------------------------------------- */
/*  Input einlesen                                     */
/* --------------------------------------------------- */
address TSO
"EXECIO * DISKR" ddname "(STEM L. FINIS"
if rc <> 0 then do
    say 'EXECIO error, RC=' rc 'for DD' ddname
    exit 16
end

if L.0 = 0 then do
    say 'No input read from DD' ddname
    exit 16
end

/* --------------------------------------------------- */
/*  Adjazenzliste aufbauen                             */
/*    adj.<name>.<i>  = i-ter Nachbar                  */
/*    adjCount.<name> = Anzahl Nachbarn                */
/* --------------------------------------------------- */
do i = 1 to L.0
    line = strip(L.i)
    if line = '' then iterate

    /* Format:  name: target1 target2 ... */
    parse var line name ':' rest
    name = strip(name)
    rest = strip(rest)

    if name = '' then iterate

    if rest = '' then do
        adjCount.name = 0
        iterate
    end

    j = 0
    do while rest <> ''
        parse var rest target rest
        target = strip(target)
        if target = '' then iterate
        j = j + 1
        adj.name.j = target
    end
    adjCount.name = j
end

/* --------------------------------------------------- */
/*  Start                                              */
/* --------------------------------------------------- */
call main
exit 0

/* ===================== main ======================== */
main:
    total = count_paths('you')
    say total
    return

/* ================= count_paths ===================== */
/* memo.<name> = Anzahl Pfade von <name> nach 'out'    */
count_paths: procedure expose adj. adjCount. memo.
    parse arg node

    /* Basisfall: 'out' selbst */
    if node = 'out' then return 1

    /* Schon berechnet? */
    if symbol('memo.' || node) = 'VAR' then
        return memo.node

    /* Anzahl Nachbarn holen; wenn uninitialisiert -> 0 */
    n = adjCount.node
    if datatype(n, 'N') = 0 then n = 0

    total = 0
    do k = 1 to n
        tgt = adj.node.k
        if tgt = '' then iterate
        total = total + count_paths(tgt)
    end

    memo.node = total
    return total
