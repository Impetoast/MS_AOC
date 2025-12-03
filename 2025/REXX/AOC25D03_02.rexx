/* REXX */
/* Advent of Code 2025 - Day 3: Lobby - Part 2
 * For each bank (line), choose exactly 12 batteries (digits) in order
 * to form the largest possible 12-digit number. Sum over all banks.
 */

address TSO
numeric digits 40            /* enough precision for large totals      */

ddname = 'AOCIN'             /* DD name that holds the puzzle input    */

/* Read complete file into stem line. */
"EXECIO * DISKR" ddname "(STEM line. FINIS"
if rc <> 0 then do
  say 'Error reading input from DD' ddname 'RC='rc
  exit 16
end

total  = 0
target = 12                  /* number of batteries per bank (part 2) */

/* Process each bank (one line per bank). */
do idx = 1 to line.0
  bank = strip(line.idx)
  len  = length(bank)

  /* Skip lines that are too short (should not happen in your input). */
  if len < target then iterate

  toRemove = len - target     /* how many digits we are allowed to drop */
  stack    = ''               /* will hold the greedy best subsequence  */

  /* Greedy: build lexicographically largest subsequence of length 12. */
  do i = 1 to len
    d = substr(bank, i, 1)

    /* While we can still remove digits and last digit is smaller,
       pop it to make room for a larger digit. */
    do while toRemove > 0 & length(stack) > 0
      last = substr(stack, length(stack), 1)
      if last < d then do
        stack    = substr(stack, 1, length(stack) - 1)
        toRemove = toRemove - 1
      end
      else leave
    end

    stack = stack || d
  end

  /* If we still have removals left, cut from the right. */
  if toRemove > 0 then
    stack = substr(stack, 1, length(stack) - toRemove)

  /* Now take exactly 12 digits. */
  best = substr(stack, 1, target)

  /* Uncomment for per-line debugging:
   * say 'LINE' idx':' best bank
   */

  /* Accumulate total (best is 12-digit numeric string). */
  total = total + best
end

say 'TOTAL OUTPUT JOLTAGE (12 batteries):' total
exit 0
