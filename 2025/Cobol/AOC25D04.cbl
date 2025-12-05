       IDENTIFICATION DIVISION.
       PROGRAM-ID. AOC25D04.
       AUTHOR. IMPETUS.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO SYSIN
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  INPUT-FILE
           RECORD CONTAINS 1000 CHARACTERS
           BLOCK CONTAINS 0 RECORDS
           RECORDING MODE F.
       01  INPUT-LINE                PIC X(1000).
      *  Adjust PIC X(1000) to match your dataset LRECL if needed.

       WORKING-STORAGE SECTION.
      * --- Grid size limits (safe upper bound for AoC-like input) ---
       77  MAX-ROWS                  PIC 9(4) VALUE 200.
       77  MAX-COLS                  PIC 9(4) VALUE 200.

      * --- Actual grid dimensions for the current input ---
       77  NUM-ROWS                  PIC 9(4) COMP VALUE 0.
       77  NUM-COLS                  PIC 9(4) COMP VALUE 0.

      * --- General loop indices ---
       77  WS-ROW                    PIC S9(4) COMP VALUE 0.
       77  WS-COL                    PIC S9(4) COMP VALUE 0.

      * --- Neighbor calculation helpers ---
       77  NB-ROW                    PIC S9(4) COMP VALUE 0.
       77  NB-COL                    PIC S9(4) COMP VALUE 0.
       77  NEIGHBOR-COUNT            PIC 9(3)  COMP VALUE 0.

      * --- Result counters ---
       77  REMOVABLE-COUNT           PIC 9(9)  COMP VALUE 0.
       77  PART1-RESULT              PIC 9(9)  COMP VALUE 0.
       77  PART2-RESULT              PIC 9(9)  COMP VALUE 0.

      * --- Misc flags and temporary values ---
       77  EOF-FLAG                  PIC X     VALUE 'N'.
       77  DO-REMOVE-FLAG            PIC X     VALUE 'N'.
       77  CURRENT-CHAR              PIC X     VALUE SPACE.

      * --- The main grid: '@' for roll, '.' for floor (or SPACE treated as flo
       01  GRID.
           05 GRID-ROW OCCURS 200 TIMES.
              10 GRID-COL OCCURS 200 TIMES.
                 15 GRID-CELL        PIC X.

      * --- Mask for cells to remove in a wave (Part 2) ---
       01  REMOVE-MASK.
           05 RM-ROW OCCURS 200 TIMES.
              10 RM-COL OCCURS 200 TIMES.
                 15 RM-FLAG          PIC X.

      * --- Offsets for the 8-direction Moore neighborhood ---
      *     (dr, dc) pairs: (-1,-1), (-1,0), (-1,1),
      *                     ( 0,-1),        ( 0,1),
      *                     ( 1,-1), ( 1,0), ( 1,1)
       01  NEIGHBOR-OFFSETS.
           05 OFFSET-ENTRY OCCURS 8 TIMES
                                 INDEXED BY OFFSET-IDX.
              10 OFFSET-DR        PIC S9(3) COMP.
              10 OFFSET-DC        PIC S9(3) COMP.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
      * ------------------------------------------------------------
      *  Program entry point
      * ------------------------------------------------------------
           PERFORM INIT-OFFSETS.

      * --- Part 1: read grid once, just count accessible rolls ---
           OPEN INPUT INPUT-FILE
           PERFORM READ-AND-BUILD-GRID
           CLOSE INPUT-FILE

           MOVE 'N' TO DO-REMOVE-FLAG
           PERFORM GET-REMOVABLE-ROLLS
           MOVE REMOVABLE-COUNT TO PART1-RESULT

      * --- Part 2: re-read the grid and iteratively remove rolls ---
           OPEN INPUT INPUT-FILE
           PERFORM READ-AND-BUILD-GRID
           CLOSE INPUT-FILE

           MOVE 0  TO PART2-RESULT
           MOVE 'Y' TO DO-REMOVE-FLAG

           PERFORM UNTIL REMOVABLE-COUNT = 0
               PERFORM GET-REMOVABLE-ROLLS
               IF REMOVABLE-COUNT > 0
                  ADD REMOVABLE-COUNT TO PART2-RESULT
               END-IF
           END-PERFORM

      * --- Output results (simple display to SYSOUT) ---
           DISPLAY "PART 1: " PART1-RESULT
           DISPLAY "PART 2: " PART2-RESULT

           GOBACK.
      * ============================================================
      *  End of MAIN-PROCEDURE
      * ============================================================

      * ------------------------------------------------------------
      *  Initialize neighbor offset table for the 8 directions
      * ------------------------------------------------------------
       INIT-OFFSETS.
           MOVE -1 TO OFFSET-DR (1)
           MOVE -1 TO OFFSET-DC (1)

           MOVE -1 TO OFFSET-DR (2)
           MOVE  0 TO OFFSET-DC (2)

           MOVE -1 TO OFFSET-DR (3)
           MOVE  1 TO OFFSET-DC (3)

           MOVE  0 TO OFFSET-DR (4)
           MOVE -1 TO OFFSET-DC (4)

           MOVE  0 TO OFFSET-DR (5)
           MOVE  1 TO OFFSET-DC (5)

           MOVE  1 TO OFFSET-DR (6)
           MOVE -1 TO OFFSET-DC (6)

           MOVE  1 TO OFFSET-DR (7)
           MOVE  0 TO OFFSET-DC (7)

           MOVE  1 TO OFFSET-DR (8)
           MOVE  1 TO OFFSET-DC (8).
      * ------------------------------------------------------------

      * ------------------------------------------------------------
      *  READ-AND-BUILD-GRID
      *  - Reads all records from INPUT-FILE
      *  - Detects NUM-ROWS and NUM-COLS
      *  - Stores '@' / '.' characters into GRID
      * ------------------------------------------------------------
       READ-AND-BUILD-GRID.
           MOVE 0   TO NUM-ROWS
           MOVE 0   TO NUM-COLS
           MOVE 'N' TO EOF-FLAG

           PERFORM UNTIL EOF-FLAG = 'Y'
               READ INPUT-FILE
                   AT END
                       MOVE 'Y' TO EOF-FLAG
                   NOT AT END
                       IF INPUT-LINE = SPACES
                           CONTINUE
                       ELSE
                           ADD 1 TO NUM-ROWS
                           IF NUM-ROWS = 1
                               PERFORM DETERMINE-NUM-COLS
                           END-IF
                           PERFORM STORE-CURRENT-ROW
                       END-IF
               END-READ
           END-PERFORM.
      * ------------------------------------------------------------

      * ------------------------------------------------------------
      *  DETERMINE-NUM-COLS
      *  - Uses the first non-empty line to determine visible width:
      *    counts continuous '@' / '.' chars from column 1 onwards.
      * ------------------------------------------------------------
       DETERMINE-NUM-COLS.
           MOVE 0 TO NUM-COLS

           PERFORM VARYING WS-COL FROM 1 BY 1
                   UNTIL WS-COL > LENGTH OF INPUT-LINE
               MOVE INPUT-LINE (WS-COL:1) TO CURRENT-CHAR
               IF CURRENT-CHAR = '@' OR CURRENT-CHAR = '.'
                   MOVE WS-COL TO NUM-COLS
               ELSE
                   IF NUM-COLS > 0
                       EXIT PERFORM
                   END-IF
               END-IF
           END-PERFORM.
      * ------------------------------------------------------------

      * ------------------------------------------------------------
      *  STORE-CURRENT-ROW
      *  - Copies the relevant part of INPUT-LINE into GRID(NUM-ROWS,*)
      * ------------------------------------------------------------
       STORE-CURRENT-ROW.
           PERFORM VARYING WS-COL FROM 1 BY 1
                   UNTIL WS-COL > NUM-COLS
               MOVE INPUT-LINE (WS-COL:1)
                 TO GRID-CELL (NUM-ROWS, WS-COL)
           END-PERFORM.
      * ------------------------------------------------------------

      * ------------------------------------------------------------
      *  GET-REMOVABLE-ROLLS
      *
      *  Calculates how many rolls are currently "accessible":
      *    - A roll '@' is accessible if it has fewer than 4
      *      neighboring live rolls '@' in the 8-direction neighborhood.
      *
      *  Behavior depends on DO-REMOVE-FLAG:
      *    - 'N' (Part 1): only count accessible rolls.
      *    - 'Y' (Part 2): count AND remove them simultaneously
      *      (after the full scan).
      *
      *  Result is stored in REMOVABLE-COUNT.
      * ------------------------------------------------------------
       GET-REMOVABLE-ROLLS.
           MOVE 0 TO REMOVABLE-COUNT

           IF DO-REMOVE-FLAG = 'Y'
               PERFORM CLEAR-REMOVE-MASK
           END-IF

           PERFORM VARYING WS-ROW FROM 1 BY 1
                   UNTIL WS-ROW > NUM-ROWS
               PERFORM VARYING WS-COL FROM 1 BY 1
                       UNTIL WS-COL > NUM-COLS
                   IF GRID-CELL (WS-ROW, WS-COL) = '@'
                       PERFORM COUNT-NEIGHBORS
                       IF NEIGHBOR-COUNT < 4
                           ADD 1 TO REMOVABLE-COUNT
                           IF DO-REMOVE-FLAG = 'Y'
                               MOVE 'Y' TO RM-FLAG (WS-ROW, WS-COL)
                           END-IF
                       END-IF
                   END-IF
               END-PERFORM
           END-PERFORM

           IF DO-REMOVE-FLAG = 'Y'
               PERFORM APPLY-REMOVALS
           END-IF.
      * ------------------------------------------------------------

      * ------------------------------------------------------------
      *  CLEAR-REMOVE-MASK
      *  - Sets all entries in REMOVE-MASK to 'N'
      * ------------------------------------------------------------
       CLEAR-REMOVE-MASK.
           PERFORM VARYING WS-ROW FROM 1 BY 1
                   UNTIL WS-ROW > NUM-ROWS
               PERFORM VARYING WS-COL FROM 1 BY 1
                       UNTIL WS-COL > NUM-COLS
                   MOVE 'N' TO RM-FLAG (WS-ROW, WS-COL)
               END-PERFORM
           END-PERFORM.
      * ------------------------------------------------------------

      * ------------------------------------------------------------
      *  APPLY-REMOVALS
      *  - For all cells where RM-FLAG = 'Y', turn '@' into '.'
      *    (i.e. remove the roll and leave empty floor)
      * ------------------------------------------------------------
       APPLY-REMOVALS.
           PERFORM VARYING WS-ROW FROM 1 BY 1
                   UNTIL WS-ROW > NUM-ROWS
               PERFORM VARYING WS-COL FROM 1 BY 1
                       UNTIL WS-COL > NUM-COLS
                   IF RM-FLAG (WS-ROW, WS-COL) = 'Y'
                       MOVE '.' TO GRID-CELL (WS-ROW, WS-COL)
                   END-IF
               END-PERFORM
           END-PERFORM.
      * ------------------------------------------------------------

      * ------------------------------------------------------------
      *  COUNT-NEIGHBORS
      *  - Computes NEIGHBOR-COUNT = number of '@' in the 8
      *    neighboring cells of GRID-CELL(WS-ROW, WS-COL).
      *  - Uses NEIGHBOR-OFFSETS table; respects grid boundaries.
      * ------------------------------------------------------------
       COUNT-NEIGHBORS.
           MOVE 0 TO NEIGHBOR-COUNT

           PERFORM VARYING OFFSET-IDX FROM 1 BY 1
                   UNTIL OFFSET-IDX > 8
               COMPUTE NB-ROW = WS-ROW + OFFSET-DR (OFFSET-IDX)
               COMPUTE NB-COL = WS-COL + OFFSET-DC (OFFSET-IDX)

               IF NB-ROW >= 1 AND NB-ROW <= NUM-ROWS
                  AND NB-COL >= 1 AND NB-COL <= NUM-COLS
                  AND GRID-CELL (NB-ROW, NB-COL) = '@'
                   ADD 1 TO NEIGHBOR-COUNT
               END-IF
           END-PERFORM.
      * ------------------------------------------------------------

       END PROGRAM AOC25D04.
