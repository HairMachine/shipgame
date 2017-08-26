DECLARE SUB WorldTick ()
DECLARE SUB PlanetMake (Nm$)
DECLARE SUB MoveShip (i%)
DECLARE SUB MoveShips ()
DECLARE SUB PlanetView ()
DECLARE SUB ChangePlanet ()
DECLARE SUB Build ()
DECLARE SUB PlanetShow (Ex%)
DECLARE SUB ShipMake (Nm$, cl$, SPos%, Fct%)
DECLARE SUB ShipShow (own%)

'$DYNAMIC
DIM SHARED ScrWidth AS INTEGER
DIM SHARED ScrHeight AS INTEGER

CLS
ScrWidth = 639
ScrHeight = 199
SCREEN 8

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
  Atk AS INTEGER
  Hp AS INTEGER
  MaxHp AS INTEGER
  SPos AS INTEGER
  Ex AS INTEGER
  Fct AS INTEGER
END TYPE

DIM SHARED Ships(255) AS Ship
DIM SHARED LastShip AS INTEGER
DIM SHARED Planets(15) AS Planet
DIM SHARED LastPlanet AS INTEGER
DIM SHARED PlayerPos AS INTEGER
PlayerPos = 0
DIM SHARED Credits AS INTEGER
Credits = 5000
DIM SHARED Turn AS INTEGER
Turn = 0

'Test

ShipMake "HMS Pinafore", "Dreadnought", PlayerPos, 0
ShipMake "Sytherian Destroyer", "Destroyer", 2, 1

PlanetMake "Earth"
PlanetMake "Mars"
PlanetMake "Venus"
DO
  IF Turn = 0 THEN PlanetView ELSE WorldTick
LOOP

REM $STATIC
SUB Build

IF Planets(PlayerPos).Ex >= 2 THEN
  PRINT
  PRINT "This planet can do no more this turn."
  SLEEP
  EXIT SUB
END IF

CLS
PRINT "Build:"
PRINT "(S)tarbase (1000c)"
IF Planets(PlayerPos).SB > 0 THEN PRINT "(D)readnought (2000c)"
INPUT a$
IF a$ = "s" AND Credits >= 1000 THEN
  PRINT "Built starbase"
  Planets(PlayerPos).SB = Planets(PlayerPos).SB + 1
  Credits = Credits - 1000
  Planets(PlayerPos).Ex = Planets(PlayerPos).Ex + 1
END IF
IF a$ = "d" AND Credits >= 2000 THEN
  PRINT "Name ship:"
  INPUT n$
  ShipMake n$, "Dreadnought", PlayerPos, 0
  Credits = Credits - 2000
  Planets(PlayerPos).Ex = Planets(PlayerPos).Ex + 1
END IF

END SUB

SUB ChangePlanet

CLS
PlanetShow (0)
INPUT a%
PlayerPos = a% - 1
PlanetView
END SUB

SUB MoveShip (i%)

PRINT "Where should " + Ships(i%).Nm + " go?"
PlanetShow (1)
INPUT a%
IF a% > UBOUND(Planets) + 1 THEN
  PRINT Ships(i%).Nm + " heads off on a mission of exploration..."
  Ships(i%).SPos = -1
ELSE
  Ships(i%).SPos = a% - 1
  PRINT Ships(i%).Nm; "jumps to " + Planets(a% - 1).Nm
  Ships(i%).Ex = 1
END IF

END SUB

SUB MoveShips

Start:
CLS
PRINT "Select which ship to move:"
ShipShow 1
DIM selected AS INTEGER
selected = 0
INPUT a%
FOR i% = 0 TO LastShip - 1
  IF Ships(i%).SPos = PlayerPos AND Ships(i%).Fct = 0 THEN selected = selected + 1
  IF selected = a% AND Ships(i%).Ex = 0 THEN
    MoveShip (i%)
    SLEEP
    EXIT SUB
  ELSEIF selected = a% AND Ships(i%).Ex = 1 THEN
    PRINT "This ship has already moved this turn."
    SLEEP
    GOTO Start
  END IF
NEXT

END SUB

SUB PlanetMake (Nm$)

Planets(LastPlanet).Nm = Nm$
Planets(LastPlanet).Pop = 10
Planets(LastPlanet).Df = 10
Planets(LastPlanet).SB = 0
LastPlanet = LastPlanet + 1

END SUB

SUB PlanetShow (Ex%)

FOR i% = 0 TO LastPlanet - 1
  PRINT i% + 1; "- "; Planets(i%).Nm
NEXT i%

IF Ex% THEN PRINT i% + 1; "EXPLORE"

END SUB

SUB PlanetView

CLS
PRINT Planets(PlayerPos).Nm
PRINT "Starbases:"; Planets(PlayerPos).SB
PRINT "Credits: "; Credits
PRINT
ShipShow 0
PRINT
PRINT "(V)iew planet"
PRINT "(M)ove ships"
PRINT "(B)uild"
PRINT "(E)nd Turn"
PRINT "(Q)uit game"
INPUT a$
IF a$ = "v" THEN ChangePlanet
IF a$ = "m" THEN MoveShips
IF a$ = "b" THEN Build
IF a$ = "e" THEN Turn = Turn + 1
IF a$ = "q" THEN END

END SUB

SUB ShipMake (Nm$, cl$, SPos%, Fct%)

Ships(LastShip).Nm = Nm$
Ships(LastShip).Class = cl$
Ships(LastShip).Atk = 5
Ships(LastShip).Hp = 5
Ships(LastShip).MaxHp = 5
Ships(LastShip).SPos = SPos%
Ships(LastShip).Fct = Fct%
LastShip = LastShip + 1

END SUB

SUB ShipShow (own%)

it% = 0
FOR i% = 0 TO LastShip - 1
  IF Ships(i%).SPos = PlayerPos AND own% = 0 THEN
    it% = it% + 1
    COLOR 15 - Ships(i%).Fct
    PRINT it%; "- "; Ships(i%).Nm
    COLOR 15
  ELSEIF Ships(i%).SPos = PlayerPos THEN
    IF Ships(i%).Fct = 0 THEN
      it% = it% + 1
      PRINT it%; "- "; Ships(i%).Nm
    END IF
  END IF
NEXT

END SUB

SUB WorldTick

CLS
PRINT "Cool things happen here..."

'Reset all ships
FOR i% = 0 TO UBOUND(Ships)
  Ships(i%).Ex = 0
NEXT

'Reset all planets
FOR i% = 0 TO UBOUND(Planets)
  Planets(i%).Ex = 0
NEXT

SLEEP
Turn = 0

END SUB

