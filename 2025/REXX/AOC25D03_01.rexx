/* REXX */
/* Advent of Code 2025 - Day 3: Lobby
 * Read all banks from DD:AOCIN and compute the total maximum joltage.
 */

address TSO

ddname = 'AOCIN'      /* DD name that holds the puzzle input          */

/* Read complete file into stem line. */
"EXECIO * DISKR" ddname "(STEM line. FINIS"
if rc <> 0 then do
  say 'Error reading input from DD' ddname 'RC='rc
  exit 16
end

total = 0

/* Process each bank (one line per bank). */
do idx = 1 to line.0
  bank = strip(line.idx)
  len  = length(bank)

  /* Ignore lines shorter than 2 characters. */
  if len < 2 then iterate

  best = 0

  /* Brute-force all pairs (i < j). */
  do i = 1 to len - 1
    d1 = substr(bank, i, 1)

    do j = i + 1 to len
      d2   = substr(bank, j, 1)
      pair = d1 || d2       /* two-digit value as string */

      /* Numeric comparison works because both are digits only. */
      if pair > best then best = pair
    end
  end

  total = total + best
end

say 'TOTAL OUTPUT JOLTAGE:' total
exit 0
