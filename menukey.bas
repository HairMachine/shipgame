DECLARE FUNCTION MenuHandle$ (Menu() AS ANY)
TYPE MenuOption
  ch AS STRING * 1
  label AS STRING * 30
END TYPE

DECLARE SUB MenuAddOption (Menu() AS MenuOption, index%, ch$, label$)
DECLARE SUB MenuDisplay (Menu() AS MenuOption)
'DECLARE FUNCTION MenuHandle$ (Menu() AS MenuOption)
DECLARE SUB MenuExample ()

SUB MenuAddOption (Menu() AS MenuOption, index%, ch$, label$)

  Menu(index%).ch = LTRIM$(ch$)
  Menu(index%).label = LTRIM$(label$)

END SUB

SUB MenuDisplay (Menu() AS MenuOption)

FOR i% = 0 TO UBOUND(Menu)
  IF Menu(i%).ch <> "" THEN PRINT Menu(i%).label
NEXT
PRINT ">_"

END SUB

SUB MenuExample

DIM Menu(1) AS MenuOption
Menu(0).ch = "a"
Menu(0).label = "Option A"
Menu(1).ch = "b"
Menu(1).label = "Option B"

CLS

'Output
MenuDisplay Menu()

'Handling
op$ = MenuHandle$(Menu())

'Function mapping
SELECT CASE op$
  CASE "a": PRINT "Option a selected"
  CASE "b": PRINT "Option b selected"
END SELECT

END SUB

FUNCTION MenuHandle$ (Menu() AS MenuOption)

DEF SEG = &H40: POKE &H1C, PEEK(&H1A): DEF SEG
op$ = ""
WHILE op$ = ""
  a$ = INPUT$(1)
  FOR i% = 0 TO UBOUND(Menu)
    IF Menu(i%).ch = a$ THEN
      op$ = a$
      EXIT FOR
    END IF
  NEXT
WEND

MenuHandle = op$

END FUNCTION
