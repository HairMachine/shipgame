DECLARE FUNCTION PlanetRandomName$ ()
DECLARE SUB UCFIRST (in$)
DECLARE FUNCTION PlanetMenu! ()
DECLARE FUNCTION ShipMenu! ()
'$INCLUDE: 'shipgame/menukey.bi'

DECLARE SUB PlanetChange ()
DECLARE SUB Battle (bShips() AS INTEGER)
DECLARE FUNCTION IsFlag! (flag%, numflags%)
DECLARE SUB WorldTick ()
DECLARE SUB PlanetMake (Nm$)
DECLARE SUB ShipMove (i%)
DECLARE SUB ShipsMove ()
DECLARE SUB PlanetView ()
DECLARE SUB ChangePlanet ()
DECLARE SUB Build ()
DECLARE SUB PlanetShow (Ex%)
DECLARE SUB ShipMake (Nm$, cl$, SPos%, Fct%)
DECLARE SUB ShipShow (own%)

'$DYNAMIC
RANDOMIZE TIMER

CONST MAXPLANETS = 15
CONST SHIPNULL = -1
CONST SHIPEXPLORE = -2

CONST NumFactions = 2
CONST FctPlayer = 1
CONST FctSytherian = 2

TYPE Planet
  Nm AS STRING * 40
  Pop AS INTEGER
  Df AS INTEGER
  SB AS INTEGER
  Ex AS INTEGER
END TYPE

TYPE Ship
  Nm AS STRING * 40
  Class AS STRING * 10
  atk AS INTEGER
  Hp AS INTEGER
  MaxHp AS INTEGER
  SPos AS INTEGER
  Ex AS INTEGER
  Fct AS INTEGER
END TYPE

DIM SHARED Ships(255) AS Ship
DIM SHARED LastShip AS INTEGER
DIM SHARED Planets(MAXPLANETS) AS Planet
DIM SHARED LastPlanet AS INTEGER
DIM SHARED PlayerPos AS INTEGER
PlayerPos = 0
DIM SHARED Credits AS INTEGER
Credits = 5000
DIM SHARED Turn AS INTEGER
Turn = 0

'Test

ShipMake "HMS Pinafore", "Dreadnought", PlayerPos, FctPlayer
ShipMake "HMS Hood", "Dreadnought", PlayerPos, FctPlayer
ShipMake "Sytherian Destroyer", "Destroyer", PlayerPos, FctSytherian

PlanetMake "Earth"
PlanetMake "Mars"
PlanetMake "Venus"

CLS
COLOR 15
DO
  IF Turn = 0 THEN PlanetView ELSE WorldTick
LOOP

REM $STATIC
SUB Battle (bShips() AS INTEGER)

'Attacks (simultaneous)
shipn% = UBOUND(bShips) - 1
FOR i% = 0 TO shipn%
  target% = RND * shipn%
  WHILE Ships(bShips(target%)).Fct = Ships(bShips(i%)).Fct
    target% = RND * shipn%
  WEND
  PRINT
  PRINT RTRIM$(Ships(bShips(i%)).Nm); " fired on "; RTRIM$(Ships(bShips(target%)).Nm) + "!"
  atk% = RND * Ships(bShips(i%)).atk
  Ships(bShips(target%)).Hp = Ships(bShips(target%)).Hp - atk%
  PRINT atk%; "damage was done."
NEXT

'Calculate losses
FOR i% = 0 TO shipn%
  IF Ships(bShips(i%)).Hp <= 0 THEN
    PRINT
    PRINT RTRIM$(Ships(bShips(i%)).Nm); " was destroyed!"
    Ships(bShips(i%)).SPos = SHIPNULL
  END IF
NEXT

SLEEP
END SUB

SUB Build

  IF Planets(PlayerPos).Ex >= 2 THEN
    PRINT
    PRINT "This planet can do no more this turn."
    SLEEP
    EXIT SUB
  END IF

  numitems% = 1
  IF Planets(PlayerPos).SB > 0 THEN numitems% = numitems% + 1
 
  DIM Menu(numitems%) AS MenuOption

  CLS
  PRINT "BUILD STRUCTURES AND SHIPS"
  PRINT "**************************"
  PRINT
  MenuAddOption Menu(), 0, "s", "(S)tarbase (1000c)"
  IF Planets(PlayerPos).SB > 0 THEN :
    MenuAddOption Menu(), 1, "d", "(D)readnought (2000c)"
  MenuAddOption Menu(), numitems%, "b", "(B)ack"
  MenuDisplay Menu()
  a$ = MenuHandle(Menu())

  IF a$ = "s" AND Credits >= 1000 THEN
    Planets(PlayerPos).SB = Planets(PlayerPos).SB + 1
    Credits = Credits - 1000
    Planets(PlayerPos).Ex = Planets(PlayerPos).Ex + 1
  ELSEIF a$ = "d" AND Credits >= 2000 THEN
    PRINT "Name ship:"
    INPUT n$
    ShipMake n$, "Dreadnought", PlayerPos, FctPlayer
    Credits = Credits - 2000
    Planets(PlayerPos).Ex = Planets(PlayerPos).Ex + 1
  END IF

END SUB

FUNCTION IsFlag (flag%, numflags%)

FOR i% = 0 TO numflags% - 1
  IF flag% - (2 ^ i%) = 0 THEN
    IsFlag = 1
    EXIT FUNCTION
  END IF
NEXT

IsFlag = 0

END FUNCTION

SUB PlanetChange

CLS
PRINT "VIEW NEW PLANET"
PRINT "***************"
PRINT
a% = PlanetMenu
IF a% <= LastPlanet THEN PlayerPos = a% - 1
PlanetView
END SUB

SUB PlanetMake (Nm$)

Planets(LastPlanet).Nm = Nm$
Planets(LastPlanet).Pop = 10
Planets(LastPlanet).Df = 10
Planets(LastPlanet).SB = 0
LastPlanet = LastPlanet + 1

END SUB

FUNCTION PlanetMenu

  DIM Menu(LastPlanet + 1) AS MenuOption
  FOR i% = 0 TO LastPlanet - 1
    MenuAddOption Menu(), i%, STR$(i% + 1), STR$(i% + 1) + ") " + RTRIM$(Planets(i%).Nm)
  NEXT
  MenuAddOption Menu(), LastPlanet, "e", "(E)xplore"
  MenuAddOption Menu(), LastPlanet + 1, "b", "(B)ack"
  MenuDisplay Menu()
  a$ = MenuHandle(Menu())
  IF a$ = "e" THEN
    PlanetMenu = LastPlanet + 1
  ELSEIF a$ = "b" THEN
    PlanetMenu = LastPlanet + 2
  ELSE
    PlanetMenu = VAL(a$)
  END IF

END FUNCTION

FUNCTION PlanetRandomName$
  DIM syls(10) AS STRING
  syls(0) = "do"
  syls(1) = "ka"
  syls(2) = "non"
  syls(3) = "ea"
  syls(4) = "aa"
  syls(5) = "cha"
  syls(6) = "ti"
  syls(7) = "is"
  syls(8) = "zi"
  syls(9) = "xo"
  name$ = ""
  ns% = RND * 4 + 1
  FOR i% = 0 TO ns%
    r% = RND * UBOUND(syls)
    name$ = name$ + syls(r%)
  NEXT
  UCFIRST name$
  PlanetRandomName$ = name$
END FUNCTION

SUB PlanetShow (Ex%)

FOR i% = 0 TO LastPlanet - 1
  PRINT i% + 1; "- "; Planets(i%).Nm
NEXT i%

IF Ex% THEN PRINT i% + 1; "EXPLORE"

END SUB

SUB PlanetView

CLS
PRINT "VIEWING PLANET DETAILS"
PRINT "**********************"
PRINT
PRINT Planets(PlayerPos).Nm
PRINT "Starbases:"; Planets(PlayerPos).SB
PRINT "Credits: "; Credits
PRINT
ShipShow 0
PRINT
DIM Menu(4) AS MenuOption
MenuAddOption Menu(), 0, "v", "(V)iew planet"
MenuAddOption Menu(), 1, "m", "(M)ove ships"
MenuAddOption Menu(), 2, "b", "(B)uild"
MenuAddOption Menu(), 3, "e", "(E)nd turn"
MenuAddOption Menu(), 4, "q", "(Q)uit game"
MenuDisplay Menu()
'a$ = ""
a$ = MenuHandle$(Menu())
WHILE a$ = "": a$ = INPUT$(1): WEND
IF a$ = "v" THEN PlanetChange
IF a$ = "m" THEN ShipsMove
IF a$ = "b" THEN Build
IF a$ = "e" THEN Turn = Turn + 1
IF a$ = "q" THEN END

END SUB

SUB ShipMake (Nm$, cl$, SPos%, Fct%)

Ships(LastShip).Nm = Nm$
Ships(LastShip).Class = cl$
Ships(LastShip).atk = 5
Ships(LastShip).Hp = 5
Ships(LastShip).MaxHp = 5
Ships(LastShip).SPos = SPos%
Ships(LastShip).Fct = Fct%
LastShip = LastShip + 1

END SUB

FUNCTION ShipMenu

  DIM OptMap(LastShip - 1) AS INTEGER
  sel% = 0
  FOR i% = 0 TO LastShip - 1
    IF Ships(i%).SPos = PlayerPos AND Ships(i%).Fct = FctPlayer THEN
      OptMap(sel%) = i%
      sel% = sel% + 1
    END IF
  NEXT

  DIM Menu(sel%) AS MenuOption
  FOR i% = 0 TO sel% - 1
    MenuAddOption Menu(), i%, STR$(i% + 1), LTRIM$(STR$(i% + 1) + ") " + Ships(OptMap(i%)).Nm)
  NEXT
  MenuAddOption Menu(), sel%, "b", "(B)ack"
  MenuDisplay Menu()
  a$ = MenuHandle(Menu())
  IF a$ = "b" THEN
    ShipMenu = LastShip
  ELSE
    ShipMenu = OptMap(VAL(a$) - 1)
  END IF

END FUNCTION

SUB ShipMove (i%)

PRINT "Where should " + RTRIM$(Ships(i%).Nm) + " go?"

a% = PlanetMenu - 1
IF a% = LastPlanet THEN
  PRINT RTRIM$(Ships(i%).Nm) + " heads off on a mission of exploration..."
  Ships(i%).SPos = SHIPEXPLORE
  SLEEP
ELSEIF a% > LastPlanet THEN
  EXIT SUB
ELSE
  Ships(i%).SPos = a%
  PRINT RTRIM$(Ships(i%).Nm); "jumps to " + Planets(a%).Nm
  Ships(i%).Ex = 1
  SLEEP
END IF

END SUB

SUB ShipShow (own%)

it% = 0
FOR i% = 0 TO LastShip - 1
  IF Ships(i%).SPos = PlayerPos AND own% = 0 THEN
    it% = it% + 1
    COLOR 15 - Ships(i%).Fct
    PRINT it%; "- "; RTRIM$(Ships(i%).Nm); Ships(i%).Hp
    COLOR 15
  ELSEIF Ships(i%).SPos = PlayerPos THEN
    IF Ships(i%).Fct = FctPlayer THEN
      it% = it% + 1
      PRINT it%; "- "; Ships(i%).Nm
    END IF
  END IF
NEXT

END SUB

SUB ShipsMove

 WHILE sel% = 0
    CLS
    PRINT "MOVE SHIPS"
    PRINT "**********"
    PRINT
    sel% = ShipMenu
    IF sel% > LastShip - 1 THEN
      EXIT SUB
    ELSEIF Ships(sel%).Ex = 0 THEN
      ShipMove sel%
      sel% = 0
    ELSE
      PRINT "This ship cannot move any further this turn."
      sel% = 0
      SLEEP
    END IF
  WEND

END SUB

SUB UCFIRST (in$)
  ad% = SADD(in$)
  POKE ad%, (PEEK(ad%) - 32)
END SUB

SUB WorldTick

DIM EncPlanets(MAXPLANETS) AS INTEGER

CLS
PRINT "EXPLORER'S LOG"
PRINT "**************"
PRINT

'Check for encounters and reset ships
expl% = 0
FOR s% = 0 TO LastShip - 1
  SELECT CASE Ships(s%).SPos
    CASE SHIPEXPLORE:
      'Todo: Proper exploration subroutine
      expl% = 1
      r% = RND * 3 + 1
      IF r% < 3 THEN
        PRINT RTRIM$(Ships(s%).Nm); " reports no discoveries. Their mission continues."
      ELSE
        PRINT RTRIM$(Ships(s%).Nm); " reports discovery of a new world!"
        Ships(s%).SPos = LastPlanet
        PlanetMake PlanetRandomName$
        PRINT "The captain has christened this new world " + RTRIM$(Planets(LastPlanet - 1).Nm) + "."
      END IF
    CASE SHIPNULL:
      'skip
    CASE ELSE:
      EncPlanets(Ships(s%).SPos) = EncPlanets(Ships(s%).SPos) + 1
  END SELECT
  Ships(s%).Ex = 0
NEXT
IF expl% THEN SLEEP

'Reset planets
FOR p% = 0 TO UBOUND(Planets)
  Planets(p%).Ex = 0
NEXT

'Run ship-ship encounters
DIM bShips(0) AS INTEGER
FOR i% = 0 TO UBOUND(EncPlanets)
  IF EncPlanets(i%) > 1 THEN
    REDIM bShips(EncPlanets(i%)) AS INTEGER
    sel% = 0
    fcts% = 0
    FOR s% = 0 TO LastShip - 1
      IF Ships(s%).SPos = i% THEN
        bShips(sel%) = s%
        fcts% = fcts% OR Ships(s%).Fct
        sel% = sel% + 1
        END IF
    NEXT
    IF IsFlag(fcts%, NumFactions) <> 1 THEN
      CLS
      PRINT "BATTLE REPORT"
      PRINT "*************"
      PRINT
      PRINT "Battle broke out near " + RTRIM$(Planets(i%).Nm) + "!"
      Battle bShips()
    END IF
  END IF
NEXT

Turn = 0



END SUB

