DECLARE SUB PlanetMake (nm$)
DECLARE SUB MoveShip (i%)
DECLARE SUB MoveShips ()
DECLARE SUB PlanetView ()
DECLARE SUB ChangePlanet ()
DECLARE SUB Build ()
DECLARE SUB PlanetShow (ex%)
DECLARE SUB ShipMake (nm$, cl$)
DECLARE SUB ShipShow ()

'$DYNAMIC
DIM SHARED ScrWidth AS INTEGER
DIM SHARED ScrHeight AS INTEGER

CLS
ScrWidth = 639
ScrHeight = 199
SCREEN 8
COLOR 4, 7

TYPE Planet
  nm AS STRING * 40
  Pop AS INTEGER
  Df AS INTEGER
  SB AS INTEGER
END TYPE

TYPE Ship
  nm AS STRING * 40
  Class AS STRING * 10
  Atk AS INTEGER
  Hp AS INTEGER
  MaxHp AS INTEGER
  SPos AS INTEGER
END TYPE

DIM SHARED Ships(255) AS Ship
DIM SHARED LastShip AS INTEGER
DIM SHARED Planets(15) AS Planet
DIM SHARED LastPlanet AS INTEGER
DIM SHARED PlayerPos AS INTEGER
PlayerPos = 0
DIM SHARED Credits AS INTEGER
Credits = 5000

'Test

ShipMake "HMS Pinafore", "Dreadnought"

PlanetMake "Earth"
PlanetMake "Mars"

DO
  PlanetView
LOOP
                                                 


          


REM $STATIC
SUB Build

CLS
PRINT "Build:"
PRINT "(S)tarbase (1000c)"
IF Planets(PlayerPos).SB > 0 THEN PRINT "(D)readnought (2000c)"
INPUT a$
IF a$ = "s" AND Credits >= 1000 THEN
  PRINT "Built starbase"
  Planets(PlayerPos).SB = Planets(PlayerPos).SB + 1
  Credits = Credits - 1000
END IF
IF a$ = "d" AND Credits >= 2000 THEN
  PRINT "Name ship:"
  INPUT n$
  ShipMake n$, "Dreadnought"
  Credits = Credits - 2000
END IF
PlanetView

END SUB

SUB ChangePlanet

CLS
PlanetShow (0)
INPUT a%
PlayerPos = a% - 1
PlanetView
END SUB

SUB MoveShip (i%)

PRINT "Where should " + Ships(i%).nm + " go?"
PlanetShow (1)
INPUT a%
IF a% > UBOUND(Planets) + 1 THEN
  PRINT Ships(i%).nm + " heads off on a mission of exploration..."
  Ships(i%).SPos = -1
ELSE
  Ships(i%).SPos = a% - 1
  PRINT Ships(i%).nm; "jumps to " + Planets(a% - 1).nm
END IF

END SUB

SUB MoveShips

CLS
PRINT "Select which ship to move:"
ShipShow
DIM selected AS INTEGER
selected = 0
INPUT a%
FOR i% = 0 TO LastShip - 1
  IF Ships(i%).SPos = PlayerPos THEN selected = selected + 1
  IF selected = a% THEN
    MoveShip (i%)
    GOTO Finished
  END IF
NEXT

Finished:
SLEEP
PlanetView

END SUB

SUB PlanetMake (nm$)

Planets(LastPlanet).nm = nm$
Planets(LastPlanet).Pop = 10
Planets(LastPlanet).Df = 10
Planets(LastPlanet).SB = 0
LastPlanet = LastPlanet + 1

END SUB

SUB PlanetShow (ex%)

FOR i% = 0 TO LastPlanet - 1
  PRINT i% + 1; "- "; Planets(i%).nm
NEXT i%

IF ex% THEN PRINT i% + 1; "EXPLORE"

END SUB

SUB PlanetView

PlanetView:
CLS
PRINT Planets(PlayerPos).nm
PRINT "Starbases:"; Planets(PlayerPos).SB
PRINT "Credits: "; Credits
PRINT
ShipShow
PRINT
PRINT "(V)iew planet"
PRINT "(M)ove ships"
PRINT "(B)uild"
INPUT a$
IF a$ = "v" THEN ChangePlanet
IF a$ = "m" THEN MoveShips
IF a$ = "b" THEN Build
IF a$ = "q" THEN END

END SUB

SUB ShipMake (nm$, cl$)

Ships(LastShip).nm = nm$
Ships(LastShip).Class = cl$
Ships(LastShip).Atk = 5
Ships(LastShip).Hp = 5
Ships(LastShip).MaxHp = 5
Ships(LastShip).SPos = PlayerPos
LastShip = LastShip + 1

END SUB

SUB ShipShow

it% = 0
FOR i% = 0 TO LastShip - 1
  IF Ships(i%).SPos = PlayerPos THEN
    it% = it% + 1
    PRINT it%; "- "; Ships(i%).nm
  END IF
NEXT

END SUB

