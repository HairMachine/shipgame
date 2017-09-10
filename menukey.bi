TYPE MenuOption
  ch AS STRING * 1
  label AS STRING * 60
END TYPE
DECLARE SUB MenuAddOption (Menu() AS MenuOption, index%, ch$, label$)
DECLARE SUB MenuDisplay (Menu() AS MenuOption)
DECLARE FUNCTION MenuHandle$ (Menu() AS MenuOption)

