/* REXX */
/* Advent of Code 2025 - Day 5: Cafeteria - Part 2
   Count how many ingredient IDs are considered fresh by the ranges.

   Input (DD:AOCIN):
     - first section: lines "start-end" (inclusive ranges)
     - one blank line
     - second section: one ID per line (ignored in Part 2)
*/

numeric digits 30          /* enough precision for big IDs */

inDD  = 'AOCIN'            /* input DD name */

ranges.0 = 0

/* --------------------------------------------------------- */
/* Read whole file from DD AOCIN into stem IN.               */
/* --------------------------------------------------------- */

address TSO "EXECIO * DISKR" inDD "(STEM IN. FINIS"

if rc <> 0 then do
  /* On I/O error, assume 0 */
  say 0
  exit 0
end

if in.0 = 0 then do
  say 0
  exit 0
end

/* --------------------------------------------------------- */
/* First phase: read ranges until first blank line           */
/* --------------------------------------------------------- */

do idx = 1 to in.0
  line = strip(in.idx)

  /* blank line = end of range section */
  if line = '' then
    leave

  /* expect "start-end" */
  parse var line start '-' end

  start = strip(start)
  end   = strip(end)

  if start = '' | end = '' then
    iterate                /* skip malformed lines */

  /* numeric conversion */
  startNum = start + 0
  endNum   = end   + 0

  ranges.0 = ranges.0 + 1
  i        = ranges.0
  rstart.i = startNum
  rend.i   = endNum
end

if ranges.0 = 0 then do
  say 0
  exit 0
end

/* --------------------------------------------------------- */
/* Sort ranges by start ascending (simple bubble sort)       */
/* --------------------------------------------------------- */

do i = 1 to ranges.0 - 1
  do j = i + 1 to ranges.0
    if rstart.j < rstart.i then do
      tmp       = rstart.i
      rstart.i  = rstart.j
      rstart.j  = tmp

      tmp       = rend.i
      rend.i    = rend.j
      rend.j    = tmp
    end
  end
end

/* --------------------------------------------------------- */
/* Merge overlapping/adjacent ranges and compute union size  */
/* --------------------------------------------------------- */

curStart = rstart.1
curEnd   = rend.1

merged.0 = 0

do i = 2 to ranges.0
  s = rstart.i
  e = rend.i

  /* overlap or directly adjacent? (inclusive ranges) */
  if s <= curEnd + 1 then do
    /* extend current merged range if necessary */
    if e > curEnd then
      curEnd = e
  end
  else do
    /* close current merged range */
    merged.0       = merged.0 + 1
    k              = merged.0
    mstart.k       = curStart
    mend.k         = curEnd

    /* start new merged range */
    curStart = s
    curEnd   = e
  end
end

/* store last open merged range */
merged.0       = merged.0 + 1
k              = merged.0
mstart.k       = curStart
mend.k         = curEnd

/* --------------------------------------------------------- */
/* Sum lengths of all merged ranges                          */
/* --------------------------------------------------------- */

total = 0

do i = 1 to merged.0
  span = mend.i - mstart.i + 1     /* inclusive range length */
  total = total + span
end

say total
exit 0
