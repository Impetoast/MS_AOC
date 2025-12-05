/* REXX */
/* Advent of Code 2025 - Day 5: Cafeteria
   Part 1: Count how many ingredient IDs are "fresh".

   Input (DD:AOCIN):
     - first section: lines "start-end" (inclusive ranges)
     - one blank line
     - second section: one ID per line
*/

numeric digits 30          /* enough precision for big IDs */

inDD  = 'AOCIN'            /* input DD name */
phase = 'RANGES'           /* current phase: RANGES or IDS */

ranges.0 = 0
fresh     = 0

/* --------------------------------------------------------- */
/* Read whole file from DD AOCIN into stem IN.               */
/* --------------------------------------------------------- */

address TSO "EXECIO * DISKR" inDD "(STEM IN. FINIS"

if rc <> 0 then do
  /* If there is any I/O error, just assume 0 fresh IDs */
  say 0
  exit 0
end

/* in.0 now contains the number of lines */

if in.0 = 0 then do
  say 0
  exit 0
end

/* --------------------------------------------------------- */
/* First pass: ranges until the first blank line             */
/* Second pass: IDs after that blank line                    */
/* --------------------------------------------------------- */

do idx = 1 to in.0
  line = strip(in.idx)

  /* Blank line switches from ranges to IDs */
  if line = '' then do
    phase = 'IDS'
    iterate
  end

  if phase = 'RANGES' then do
    /* expect "start-end" */
    parse var line start '-' end

    start = strip(start)
    end   = strip(end)

    if start = '' | end = '' then
      iterate                      /* skip malformed lines */

    /* numeric conversion (important for correct comparisons) */
    startNum = start + 0
    endNum   = end   + 0

    ranges.0        = ranges.0 + 1
    i               = ranges.0
    rstart.i        = startNum
    rend.i          = endNum

  end
  else do  /* phase = 'IDS' */
    id = strip(line)
    if id = '' then
      iterate                      /* ignore empty lines */

    idNum = id + 0                 /* numeric value of ID */

    /* Check this ID against all ranges */
    do i = 1 to ranges.0
      if idNum >= rstart.i & idNum <= rend.i then do
        fresh = fresh + 1
        leave                      /* no need to check more ranges */
      end
    end
  end
end

say fresh
exit 0
