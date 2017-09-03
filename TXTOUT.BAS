'$INCLUDE: 'TXTOUT.BI'
DECLARE SUB SetWindow (minx%, miny%, maxx%, maxy%)
DECLARE SUB TxtOut (txt$, brd%)
DECLARE SUB WindowBorder (ch$)
DIM SHARED CursorX AS INTEGER
DIM SHARED CursorY AS INTEGER
DIM SHARED WindowXMin AS INTEGER
DIM SHARED WindowYMin AS INTEGER
DIM SHARED WindowXMax AS INTEGER
DIM SHARED WindowYMax AS INTEGER
WindowXMin = 1
WindowYMin = 1
WindowXMax = 80
WindowYMax = 23

CLS
COLOR 4: TxtOut "Hello World", 0
SetWindow 10, 10, 40, 20
COLOR 5: WindowBorder "#"
COLOR 2: TxtOut "The Title Write!", 1
SetWindow 30, 10, 40, 13
COLOR 10: WindowBorder "*"
TxtOut "Balls", 1

SUB SetWindow (minx%, miny%, maxx%, maxy%)
  WindowXMin = minx%
  WindowYMin = miny%
  WindowXMax = maxx%
  WindowYMax = maxy%
  CursorX = minx%
  CursorY = miny%
END SUB

SUB TxtOut (txt$, brd%)
  LOCATE CursorY + brd%, CursorX + brd%: PRINT txt$
  CursorY = CursorY + 1
END SUB

SUB UCFirst (in$)
  ad% = SADD(in$)
  POKE ad%, (PEEK(ad%) - 32)
END SUB

SUB WindowBorder (ch$)

  FOR y% = WindowYMin TO WindowYMax
    FOR x% = WindowXMin TO WindowXMax
      IF y% = WindowYMin OR y% = WindowYMax OR x% = WindowXMin OR x% = WindowXMax THEN
        LOCATE y%, x%: PRINT ch$
      END IF
    NEXT
  NEXT

END SUB

