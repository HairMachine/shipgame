DECLARE SUB MenuAddOption (Menu() AS ANY, index%, ch$, label$)
DECLARE SUB MenuDisplay (Menu() AS ANY)
DECLARE FUNCTION MenuHandle$ (Menu() AS ANY)
TYPE MenuOption
  ch AS STRING * 1
  label AS STRING * 30
END TYPE

