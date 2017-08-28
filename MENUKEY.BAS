DECLARE SUB MenuDisplay (Menu() AS ANY)
DECLARE FUNCTION MenuHandle$ (Menu() AS ANY)
DECLARE SUB MenuExample ()
TYPE MenuOption
  ch AS STRING * 1
  label AS STRING * 30
END TYPE

MenuExample




SUB MenuDisplay (Menu() AS MenuOption)

FOR i% = 0 TO UBOUND(Menu)
  PRINT Menu(i%).label
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

