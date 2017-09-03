'
' MIDILib Library Include File.
'
' Contains definitions of SUB's, FUNCTION's, ad constants.
'

' Use integers by default, as they're faster.
DEFINT A-Z
' $DYNAMIC

' Declare the SUB's and FUNCTION's.
DECLARE SUB DetectSettings ()
DECLARE SUB DetectDrivers ()
DECLARE SUB InterruptX (IntNum AS INTEGER, InRegs AS ANY, OutRegs AS ANY)
DECLARE SUB LoopMIDI ()
DECLARE SUB LoadMIDI (Filename$)
DECLARE SUB PauseMIDI ()
DECLARE SUB PlayMIDI ()
DECLARE SUB ResumeMIDI ()
DECLARE SUB ReverseStereo (Switch%)
DECLARE SUB SetVolume (Which%, Vol%, Mode%)
DECLARE SUB StopMIDI ()
DECLARE SUB UnloadMIDI ()
DECLARE FUNCTION CurrentMIDI$ (Switch%)
DECLARE FUNCTION GetVolume% (Which%, Mode%)
DECLARE FUNCTION MIDIError$ ()
DECLARE FUNCTION MIDIErrorOccured% ()
DECLARE FUNCTION MIDITime! ()
DECLARE FUNCTION MusicDone ()
DECLARE FUNCTION SoundCard$ ()
DECLARE FUNCTION SoundCardType% ()
DECLARE FUNCTION Version$ ()

' Define the constants.
CONST TRUE = -1, FALSE = NOT TRUE

CONST MasterL = 0, MasterR = 1
CONST VoiceL = 2, VoiceR = 3
CONST MIDIL = 4, MIDIR = 5

CONST TrueValue = 0
CONST ZeroTo31 = 1
CONST ZeroTo15 = 2

