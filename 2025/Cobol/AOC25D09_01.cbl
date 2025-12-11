       IDENTIFICATION DIVISION.
       PROGRAM-ID. AOC25D09.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AOCIN ASSIGN TO SYSIN.

       DATA DIVISION.
       FILE SECTION.
       FD  AOCIN.
       01  AOCIN-REC                PIC X(1000).

       WORKING-STORAGE SECTION.
       01  EOF-SWITCH               PIC X VALUE 'N'.
           88 EOF                   VALUE 'Y'.

       01  WS-POINT-COUNT           PIC 9(4) COMP VALUE 0.

       01  WS-POINTS.
           05 WS-POINT OCCURS 1000 TIMES.
              10 WS-X               PIC 9(7) COMP-5.
              10 WS-Y               PIC 9(7) COMP-5.

       01  WS-X-STR                 PIC X(10).
       01  WS-Y-STR                 PIC X(10).

       01  I                        PIC 9(4) COMP.
       01  J                        PIC 9(4) COMP.

       01  DX                       PIC S9(9) COMP-5.
       01  DY                       PIC S9(9) COMP-5.
       01  WS-AREA                  PIC 9(18) COMP-5.
       01  WS-MAX-AREA              PIC 9(18) COMP-5 VALUE 0.

       PROCEDURE DIVISION.
       MAIN-SECTION.
           OPEN INPUT AOCIN
           PERFORM READ-POINTS
           CLOSE AOCIN
           PERFORM CALCULATE-MAX-AREA
           DISPLAY WS-MAX-AREA
           GOBACK.

       READ-POINTS.
           PERFORM UNTIL EOF
               READ AOCIN
                   AT END
                       MOVE 'Y' TO EOF-SWITCH
                   NOT AT END
                       IF AOCIN-REC = SPACES
                           CONTINUE
                       ELSE
                           ADD 1 TO WS-POINT-COUNT
                           UNSTRING AOCIN-REC
                               DELIMITED BY ','
                               INTO WS-X-STR
                                    WS-Y-STR
                           END-UNSTRING
                           COMPUTE WS-X(WS-POINT-COUNT)
                               = FUNCTION NUMVAL(WS-X-STR)
                           COMPUTE WS-Y(WS-POINT-COUNT)
                               = FUNCTION NUMVAL(WS-Y-STR)
                       END-IF
               END-READ
           END-PERFORM.

       CALCULATE-MAX-AREA.
           IF WS-POINT-COUNT < 2
               MOVE 0 TO WS-MAX-AREA
               EXIT PARAGRAPH
           END-IF

           PERFORM VARYING I FROM 1 BY 1
                   UNTIL I > WS-POINT-COUNT
               ADD 1 TO I GIVING J
               PERFORM VARYING J FROM J BY 1
                       UNTIL J > WS-POINT-COUNT
                   COMPUTE DX = WS-X(I) - WS-X(J)
                   IF DX < 0
                       MULTIPLY -1 BY DX
                   END-IF

                   COMPUTE DY = WS-Y(I) - WS-Y(J)
                   IF DY < 0
                       MULTIPLY -1 BY DY
                   END-IF

                   COMPUTE WS-AREA = (DX + 1) * (DY + 1)

                   IF WS-AREA > WS-MAX-AREA
                       MOVE WS-AREA TO WS-MAX-AREA
                   END-IF
               END-PERFORM
           END-PERFORM.

       END PROGRAM AOC25D09.