'$DYNAMIC
'$INCLUDE: 'midilib.bi'

DECLARE SUB WindowMain (title$)
'$INCLUDE: 'txtout.bi'
DECLARE SUB BuildShip (Nm$, Cr%, Posi%)
DECLARE SUB BuildingActions ()
DECLARE SUB ActionMine ()
DECLARE SUB GameOverCheck ()
DECLARE SUB EnemyShipSpawn ()
DECLARE SUB ShipActions (EncPlanets() AS INTEGER)
DECLARE SUB Encounters (EncPlanets() AS INTEGER)
DECLARE SUB ShipExplore (s%)
DECLARE SUB BuildingMake (Nm$, BPos%, Fct%)
DECLARE FUNCTION PlanetHasBuilding! (Nm$, BPos%, Fct%)
DECLARE SUB BuildingsShow ()
DECLARE FUNCTION PlanetRandomName$ ()
DECLARE SUB UCFirst (in$)
DECLARE FUNCTION PlanetMenu! ()
DECLARE FUNCTION ShipMenu! ()
'$INCLUDE: 'menukey.bi'
                    
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

RANDOMIZE TIMER

CONST MAXPLANETS = 15
CONST SHIPNULL = -1
CONST SHIPEXPLORING = -2
CONST MAXPLANETSHIPS = 4

CONST NumFactions = 2
CONST FctPlayer = 1
CONST FctSytherian = 2

TYPE Planet
  Nm AS STRING * 40
  Pop AS INTEGER
  Ex AS INTEGER
  Dv AS INTEGER
END TYPE

TYPE Ship
  Nm AS STRING * 40
  Class AS STRING * 10
  atk AS INTEGER
  hp AS INTEGER
  MaxHp AS INTEGER
  SPos AS INTEGER
  Ex AS INTEGER
  Fct AS INTEGER
END TYPE

TYPE Building
  Nm AS STRING * 40
  hp AS INTEGER
  MaxHp AS INTEGER
  BPos AS INTEGER
  Fct AS INTEGER
END TYPE

DIM SHARED Ships(255) AS Ship
DIM SHARED LastShip AS INTEGER
DIM SHARED Planets(MAXPLANETS) AS Planet
DIM SHARED LastPlanet AS INTEGER
DIM SHARED Buildings(255) AS Building
DIM SHARED LastBuilding AS INTEGER
DIM SHARED PlayerPos AS INTEGER
PlayerPos = 0
DIM SHARED Credits AS LONG
Credits = 5000
DIM SHARED Turn AS INTEGER
DIM SHARED SytheriaLocation AS INTEGER
DIM SHARED TurnCount AS INTEGER

PlanetMake "Earth"
Planets(LastPlanet - 1).Pop = 5

CLS
COLOR 15

' Detect the SBMIDI, SBSIM drivers and the sound card settings.
DetectDrivers
IF MIDIErrorOccured THEN PRINT MIDIError$: END
DetectSettings
IF MIDIErrorOccured THEN PRINT MIDIError$: END

LoadMidi "meia.mid"
PlayMidi
CLS
LOCATE 12, 35: PRINT "SPACE WARP"
SLEEP
StopMidi
UnloadMidi

DO
  IF Turn = 0 THEN PlanetView ELSE WorldTick
LOOP

REM $STATIC
DEFSNG A-Z
SUB Battle (bShips() AS INTEGER)

'Attacks (simultaneous)
shipn% = UBOUND(bShips) - 1
FOR i% = 0 TO shipn%
  target% = RND * shipn%
  WHILE Ships(bShips(target%)).Fct = Ships(bShips(i%)).Fct
    target% = RND * shipn%
  WEND
  TxtOut RTRIM$(Ships(bShips(i%)).Nm) + " fired on " + RTRIM$(Ships(bShips(target%)).Nm) + "!", 2
  atk% = RND * Ships(bShips(i%)).atk
  Ships(bShips(target%)).hp = Ships(bShips(target%)).hp - atk%
  TxtOut STR$(atk%) + " damage was done.", 2
NEXT

'Calculate losses
FOR i% = 0 TO shipn%
  IF Ships(bShips(i%)).hp <= 0 THEN
    TxtOut RTRIM$(Ships(bShips(i%)).Nm) + " was destroyed!", 2
    Ships(bShips(i%)).SPos = SHIPNULL
  END IF
NEXT

SLEEP
END SUB

SUB Build

  IF Planets(PlayerPos).Ex = 1 THEN
    TxtOut "", 2
    TxtOut "This planet can do no more this turn.", 2
    SLEEP
    EXIT SUB
  END IF

  DIM Menu(15) AS MenuOption

  WindowMain "BUILD STRUCTURES AND SHIPS"
 
  MenuAddOption Menu(), 0, "s", "(S)tarbase (1000c)"
  MenuAddOption Menu(), 1, "m", "(M)ine (3000c)"

  'conditional buildings
  extra% = 2
  IF PlanetHasBuilding("Starbase", PlayerPos, FctPlayer) >= 1 THEN
    MenuAddOption Menu(), 2, "f", "(F)rigate (1000c)"
    MenuAddOption Menu(), 3, "d", "(D)estroyer (2000c)"
    MenuAddOption Menu(), 4, "c", "(C)ruiser (4000c)"
    MenuAddOption Menu(), 5, "b", "(B)attleship (8000c)"
    extra% = 6
  END IF
 
  MenuAddOption Menu(), extra%, "n", "(N)othing"
  MenuDisplay Menu()
  a$ = MenuHandle(Menu())

  IF a$ = "s" AND Credits >= 1000 AND Planets(PlayerPos).Dv < Planets(PlayerPos).Pop THEN
    Credits = Credits - 1000
    BuildingMake "Starbase", PlayerPos, FctPlayer
    Planets(PlayerPos).Dv = Planets(PlayerPos).Dv + 1
    Planets(PlayerPos).Ex = 1
  ELSEIF a$ = "m" AND Credits >= 3000 AND Planets(PlayerPos).Dv < Planets(PlayerPos).Pop THEN
    Credits = Credits - 3000
    BuildingMake "Mine", PlayerPos, FctPlayer
    Planets(PlayerPos).Dv = Planets(PlayerPos).Dv + 1
    Planets(PlayerPos).Ex = 1
  ELSEIF a$ = "f" AND Credits >= 1000 THEN
    BuildShip "Frigate", 1000, PlayerPos
  ELSEIF a$ = "d" AND Credits >= 2000 THEN
    BuildShip "Destroyer", 2000, PlayerPos
  ELSEIF a$ = "c" AND Credits >= 4000 THEN
    BuildShip "Cruiser", 4000, PlayerPos
  ELSEIF a$ = "b" AND Credits >= 8000 THEN
    BuildShip "Battleship", 8000, PlayerPos
  END IF

END SUB

SUB BuildingActions

  FOR i% = 0 TO LastBuilding
    IF RTRIM$(Buildings(i%).Nm) = "Mine" AND Buildings(i%).BPos >= 0 THEN
      Credits = Credits + (RND * 250) + 250
    END IF
  NEXT

END SUB

SUB BuildingMake (Nm$, BPos%, Fct%)

  Buildings(LastBuilding).Nm = Nm$
  Buildings(LastBuilding).hp = 10
  Buildings(LastBuilding).MaxHp = 10
  Buildings(LastBuilding).BPos = BPos%
  Buildings(LastBuilding).Fct = Fct%
  LastBuilding = LastBuilding + 1

END SUB

SUB BuildingsShow

  FOR i% = 0 TO LastBuilding - 1
    IF Buildings(i%).BPos = PlayerPos THEN
      COLOR 15 - Buildings(i%).Fct
      TxtOut RTRIM$(Buildings(i%).Nm), 2
      COLOR 15
    END IF
  NEXT

END SUB

SUB BuildShip (Nm$, Cr%, Posi%)
  FOR i% = 0 TO LastShip
    IF Ships(i%).SPos = Posi% AND Ships(i%).Fct = FctPlayer THEN total% = total% + 1
  NEXT
  IF total% > MAXPLANETSHIPS THEN
    TxtOut "", 2
    TxtOut "This system cannot support any more ships right now.", 2
    SLEEP
    EXIT SUB
  END IF

  TxtOut "Name ship:", 2
  INPUT n$
  ShipMake n$, Nm$, PlayerPos, FctPlayer
  Credits = Credits - Cr%
  Planets(Posi%).Ex = 1
END SUB

SUB Encounters (EncPlanets() AS INTEGER)

  'Ships fighting stuff
  DIM bShips(0) AS INTEGER
  DIM bBuildings(0) AS INTEGER
  FOR i% = 0 TO UBOUND(EncPlanets)
    IF EncPlanets(i%) > 0 THEN
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
        'More than one faction here; ship-to-ship encounter
        WindowMain "BATTLE REPORT"
        TxtOut "Fighting broke out near " + RTRIM$(Planets(i%).Nm) + "!", 2
        Battle bShips()
      ELSE
        'Only one faction here; attack buildings
        sel% = -1
        IF LastBuilding > 0 THEN
          REDIM bBuildings(LastBuilding - 1) AS INTEGER
          FOR b% = 0 TO LastBuilding - 1
            IF Buildings(b%).BPos = i% AND Buildings(b%).Fct <> fcts% THEN
              sel% = sel% + 1
              bBuildings(sel%) = b%
              END IF
          NEXT
        END IF
        IF sel% > -1 THEN
          WindowMain "BATTLE REPORT"
          TxtOut RTRIM$(Planets(i%).Nm) + " is under attack!", 2
          FOR c% = 0 TO UBOUND(bShips) - 1
            r% = RND * sel%
            TxtOut RTRIM$(Ships(bShips(c%)).Nm) + " bombards " + RTRIM$(Buildings(bBuildings(r%)).Nm) + "!", 2
            dam% = RND * Ships(bShips(c%)).atk
            Buildings(bBuildings(r%)).hp = Buildings(bBuildings(r%)).hp - dam%
            IF Buildings(bBuildings(r%)).hp <= 0 THEN
              TxtOut RTRIM$(Buildings(bBuildings(r%)).Nm) + " is destroyed!", 2
              Buildings(bBuildings(r%)).BPos = -1
            END IF
          NEXT
          SLEEP
        ELSEIF Planets(i%).Pop > 0 AND fcts% <> FctPlayer AND (i% <> SytheriaLocation OR i% = 0) THEN
          WindowMain "BATTLE REPORT"
          FOR c% = 0 TO UBOUND(bShips) - 1
            TxtOut RTRIM$(Ships(bShips(c%)).Nm) + " bombards " + RTRIM$(Planets(i%).Nm) + "!", 2
            dam% = RND * Ships(bShips(c%)).atk
            Planets(i%).Pop = Planets(i%).Pop - dam%
          NEXT
          SLEEP
        END IF
      END IF
    END IF
  NEXT

END SUB

SUB EnemyShipSpawn

  IF TurnCount < 5 THEN EXIT SUB

  FOR i% = 0 TO LastPlanet - 1
    r% = RND * 3 + 1
    IF r% = 3 THEN
      WindowMain "CONTACT"
      FOR s% = 0 TO LastShip
        IF Ships(s%).SPos = i% AND Ships(s%).Fct = FctSytherian THEN total% = total% + 1
      NEXT
      'n% = 0
      'FOR j% = 0 TO n%
        IF total% <= MAXPLANETSHIPS THEN
          ShipMake "Sytherian Destroyer", "Destroyer", i%, FctSytherian
          TxtOut "A Sytherian Destroyer has appeared near " + RTRIM$(Planets(i%).Nm) + ".", 2
          total% = total% + 1
          SLEEP 'not good
        END IF
      'NEXT
    END IF
  NEXT i%

END SUB

SUB GameOverCheck

  IF Planets(0).Pop <= 0 THEN
    CLS
    PRINT "Earth has been devastated! You have lost."
    SLEEP
    END
  END IF

  win% = 1
  IF SytheriaLocation <> 0 THEN
    FOR s% = 0 TO LastShip
      IF Ships(s%).SPos = SytheriaLocation AND Ships(s%).Fct = FctSytherian THEN
        win% = 0
        EXIT FOR
      END IF
    NEXT
    IF win% = 1 THEN
      CLS
      PRINT "You have destroyed the Sytherian home fleet! Victory is yours!"
      SLEEP
      END
    END IF
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

WindowMain "VIEW NEW PLANET"
a% = PlanetMenu
IF a% <= LastPlanet THEN PlayerPos = a% - 1
PlanetView
END SUB

FUNCTION PlanetHasBuilding (Nm$, BPos%, Fct%)

  count% = 0
  FOR i% = 0 TO LastBuilding
    IF RTRIM$(Buildings(i%).Nm) = Nm$ AND Buildings(i%).BPos = BPos% AND Buildings(i%).Fct = Fct% THEN
      count% = count% + 1
    END IF
  NEXT
  PlanetHasBuilding = count%

END FUNCTION

SUB PlanetMake (Nm$)

Planets(LastPlanet).Nm = Nm$
Planets(LastPlanet).Pop = RND * 5 + 1
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
  DIM syls(16) AS STRING
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
  syls(10) = "di"
  syls(11) = "id"
  syls(12) = "nel"
  syls(13) = "art"
  syls(14) = "le"
  syls(15) = "ban"
  name$ = ""
  ns% = RND * 4 + 1
  FOR i% = 0 TO ns%
    r% = RND * UBOUND(syls)
    name$ = name$ + syls(r%)
  NEXT
  UCFirst name$
  PlanetRandomName$ = name$
END FUNCTION

SUB PlanetShow (Ex%)

FOR i% = 0 TO LastPlanet - 1
  PRINT Planets(i%).Nm
NEXT i%

IF Ex% THEN PRINT i% + 1; "EXPLORE"

END SUB

SUB PlanetView

  WindowMain "VIEW PLANET"

  SetWindow 50, 1, 80, 23
  COLOR 3: WindowBorder "#"
  ShipShow 0
  TxtOut "", 2
  BuildingsShow
 
  SetWindow 1, 3, 80, 23
  COLOR 12: TxtOut RTRIM$(Planets(PlayerPos).Nm), 2
  COLOR 7: TxtOut "Pop" + STR$(Planets(PlayerPos).Pop) + " Dev" + STR$(Planets(PlayerPos).Dv), 2
  TxtOut "Credits: " + STR$(Credits), 2
  TxtOut "", 2
  COLOR 15
  DIM Menu(4) AS MenuOption
  MenuAddOption Menu(), 0, "v", "(V)iew planet"
  MenuAddOption Menu(), 1, "m", "(M)ove ships"
  MenuAddOption Menu(), 2, "b", "(B)uild"
  MenuAddOption Menu(), 3, "e", "(E)nd turn"
  MenuAddOption Menu(), 4, "q", "(Q)uit game"
  MenuDisplay Menu()
  a$ = MenuHandle$(Menu())
  WHILE a$ = "": a$ = INPUT$(1): WEND
  IF a$ = "v" THEN PlanetChange
  IF a$ = "m" THEN ShipsMove
  IF a$ = "b" THEN Build
  IF a$ = "e" THEN Turn = Turn + 1
  IF a$ = "q" THEN END

END SUB

SUB ShipActions (EncPlanets() AS INTEGER)

  'TODO: The exploring thing here is a little weird, as it does it
  'inline and it kind of messes with the abstraction level of the sub
  'The way the encounters works feels nicer
  WindowMain "EXPLORER'S LOG"
  expl% = 0
  FOR s% = 0 TO LastShip - 1
    SELECT CASE Ships(s%).SPos
      CASE SHIPEXPLORING:
        ShipExplore s%
        expl% = 1
      CASE SHIPNULL:
        'skip
      CASE ELSE:
        EncPlanets(Ships(s%).SPos) = EncPlanets(Ships(s%).SPos) + 1
    END SELECT
    Ships(s%).Ex = 0
  NEXT
  IF expl% THEN SLEEP

END SUB

SUB ShipExplore (s%)
 
  r% = RND * 8 + 1
  IF r% < 8 THEN
    TxtOut RTRIM$(Ships(s%).Nm) + " reports no discoveries. Their mission continues.", 2
  ELSE
    IF LastPlanet < 12 THEN
      TxtOut RTRIM$(Ships(s%).Nm) + " reports discovery of a new world!", 2
      Ships(s%).SPos = LastPlanet
      PlanetMake PlanetRandomName$
      TxtOut "The captain has christened this new world " + RTRIM$(Planets(LastPlanet - 1).Nm) + ".", 2
      creds% = (RND * 200) + 800
      Credits = Credits + creds%
      TxtOut "Minerals were discovered worth" + STR$(creds%) + " credits!", 2
    ELSEIF SytheriaLocation = 0 THEN
      TxtOut RTRIM$(Ships(s%).Nm) + " has discovered the Sytherian homeworld!", 2
      Ships(s%).SPos = LastPlanet
      FOR n% = 0 TO 4
        ShipMake "Sytherian Destroyer", "Dreadnought", LastPlanet, FctSytherian
      NEXT
      SytheriaLocation = LastPlanet
      PlanetMake "Sytheria"
    END IF
  END IF

END SUB

SUB ShipMake (Nm$, cl$, SPos%, Fct%)

SELECT CASE cl$
  CASE "Frigate": atk% = 1: hp% = 1
  CASE "Destroyer": atk% = 2: hp% = 2
  CASE "Cruiser": atk% = 3: hp% = 3
  CASE "Battleship": atk% = 5: hp% = 5
  CASE "Dome Ship": atk% = 10: hp% = 10
END SELECT

Ships(LastShip).Nm = Nm$
Ships(LastShip).Class = cl$
Ships(LastShip).atk = atk%
Ships(LastShip).hp = hp%
Ships(LastShip).MaxHp = hp%
Ships(LastShip).SPos = SPos%
Ships(LastShip).Fct = Fct%
LastShip = LastShip + 1

END SUB

FUNCTION ShipMenu

  IF LastShip = 0 THEN EXIT FUNCTION
 
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

TxtOut "Where should " + RTRIM$(Ships(i%).Nm) + " go?", 2

a% = PlanetMenu - 1
IF a% = LastPlanet THEN
  TxtOut RTRIM$(Ships(i%).Nm) + " heads off on a mission of exploration...", 2
  Ships(i%).SPos = SHIPEXPLORING
  SLEEP
ELSEIF a% > LastPlanet THEN
  EXIT SUB
ELSE
  Ships(i%).SPos = a%
  TxtOut RTRIM$(Ships(i%).Nm) + "jumps to " + Planets(a%).Nm, 2
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
    TxtOut RTRIM$(Ships(i%).Nm) + STR$(Ships(i%).hp), 2
    COLOR 15
  ELSEIF Ships(i%).SPos = PlayerPos THEN
    IF Ships(i%).Fct = FctPlayer THEN
      it% = it% + 1
      TxtOut RTRIM$(Ships(i%).Nm), 2
    END IF
  END IF
NEXT

END SUB

SUB ShipsMove

 WHILE sel% = 0
    WindowMain "MOVE SHIPS"
    sel% = ShipMenu
    IF sel% > LastShip - 1 THEN
      EXIT SUB
    ELSEIF Ships(sel%).Ex = 0 THEN
      ShipMove sel%
      sel% = 0
    ELSE
      TxtOut "This ship cannot move any further this turn.", 2
      sel% = 0
      SLEEP
    END IF
  WEND

END SUB

SUB WindowMain (title$)

  CLS
  SetWindow 1, 1, 80, 23
  COLOR 3: WindowBorder "#"
  COLOR 11: TxtOut "-" + title$ + "-", 1
  SetWindow 1, 1, LEN(title$) + 4, 3
  COLOR 3: WindowBorder "#"
  COLOR 15
  SetWindow 1, 3, 80, 23

END SUB

SUB WorldTick

DIM EncPlanets(MAXPLANETS) AS INTEGER

'Process ship actions
ShipActions EncPlanets()

'Process building actions
BuildingActions

'Process encounters
Encounters EncPlanets()

'End game checks
GameOverCheck

'jump in enemy ships to threaten the player
EnemyShipSpawn

'Reset planets
FOR P% = 0 TO UBOUND(Planets)
  Planets(P%).Ex = 0
NEXT

Turn = 0
TurnCount = TurnCount + 1

END SUB

