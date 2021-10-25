;RegEx quick tutorial
vText	= Dieisson abc
;CONCEPTS: STRING STARTS/ENDS/CONTAINS
;CONCEPTS: CASE SENSITIVE/CASE INSENSITIVE
;CHARACTERS: ^ (STARTS WITH)
;CHARACTERS: $ (ENDS WITH)
;CHARACTERS: | (OR)
;CHARACTERS: ()
;STRINGS: i) (CASE INSENSITIVE) (AHK-SPECIFIC, NONSTANDARD REGEX)

MsgBox, % RegExMatch(vText, "abc") ;does string contain abc (case sensitive)
MsgBox, % RegExMatch(vText, "ABC") ;does string contain ABC (case sensitive)
MsgBox, % RegExMatch(vText, "i)abc") ;does string contain abc (case insensitive)

MsgBox, % RegExMatch(vText, "^abc") ;does string start with abc
MsgBox, % RegExMatch(vText, "abc$") ;does string end with abc
MsgBox, % RegExMatch(vText, "^abc$") ;does string equal abc

MsgBox, % RegExMatch(vText, "abc|def") ;does string contain abc or def (or both)
MsgBox, % RegExMatch(vText, "(abc|def)") ;does string contain abc or def (or both) (same as line above)
MsgBox, % RegExMatch(vText, "^(abc|def)") ;does string start with abc or def
MsgBox, % RegExMatch(vText, "(abc|def)$") ;does string end with abc or def
MsgBox, % RegExMatch(vText, "^(abc|def)$") ;does string equal abc or def

MsgBox, % RegExMatch(vText, "^(Sun|Mon|Tues|Wednes|Thurs|Fri|Satur)day$") ;the string is a weekday

;note: you can also use the ~= operator, to use RegExMatch with 2 parameters:
MsgBox, % ("ABCDEFGHI" ~= "i)def") ;does string contain def (case insensitive)
MsgBox, % RegExMatch("ABCDEFGHI", "i)def") ;does string contain def (case insensitive)

;CONCEPTS: CHARACTERS/STRINGS/NEEDLES MUST APPEAR N TIMES
;CONCEPTS: USE THE FOUND TEXT IN THE REPLACE TEXT
;CHARACTERS: ? (0 OR 1)
;CHARACTERS: * (0 OR MORE)
;CHARACTERS: + (1 OR MORE)
;CHARACTERS: . (ANY CHARACTER) (NOTE: IF DOTALL OFF, DOESN'T MATCH NEWLINES)
;CHARACTERS: {}
;STRINGS: \d (DIGIT)
;STRINGS: $0 (TO USE FOUND TEXT IN THE REPLACE TEXT)

MsgBox, % RegExMatch(vText, "colou?r") ;does string contain color/colour
MsgBox, % RegExMatch(vText, "color|colour") ;does string contain color/colour (same as line above)
MsgBox, % RegExMatch(vText, "^\d*$") ;does the string only contain digits (it can be blank)
MsgBox, % RegExMatch(vText, "^\d+$") ;does the string only contain digits (at least one digit)
MsgBox, % RegExMatch(vText, "^-?\d+$") ;does the string only contain digits (at least one digit) (it can have a leading minus sign)
MsgBox, % RegExReplace(vText, " +", " ") ;replace multiple spaces with single spaces
MsgBox, % RegExReplace(vText, ".", "$0,") ;add a comma after every character
MsgBox, % RegExReplace(vText, ".{3}", "$0,") ;add a comma after every 3 characters
MsgBox, % RegExMatch(vText, "^(...)*$") ;string must have 0/3/6/9/... characters (a multiple of 3)
MsgBox, % RegExMatch(vText, "^(...)+$") ;string must have 3/6/9/... characters (a multiple of 3)
MsgBox, % RegExMatch(vText, "^(abc)*$") ;string must contain abc zero or more times
MsgBox, % RegExMatch(vText, "^(abc)+$") ;string must contain abc one or more times

MsgBox, % RegExMatch(vText, "^\d{2}$") ;is it a 2-digit number
MsgBox, % RegExMatch(vText, "^\d{4}$") ;is it a 4-digit number
MsgBox, % RegExMatch(vText, "^\d{2,}$") ;is it a 2-digit number (or longer)
MsgBox, % RegExMatch(vText, "^\d{0,4}$") ;is it a 4-digit number (or shorter) (or blank)
MsgBox, % RegExMatch(vText, "^\d{2,4}$") ;is it a number between 2 and 4 digits long

MsgBox, % RegExReplace(A_Now, "(....)(..)(..)(..)(..)(..)", "$1-$2-$3 $4:$5:$6") ;format the date

;CONCEPTS: SOME SPECIAL REGEX CHARACTERS NEED ESCAPING TO BE USED LITERALLY
;CHARACTERS: \
;STRINGS: \Q \E (text between \Q and \E is treated literally)
;NOTE: 12 characters that need escaping in RegEx generally: \.*?+[{|()^$

MsgBox, % RegExReplace("a.b", ".") ;replaces all characters
MsgBox, % RegExReplace("a.b", "\.") ;replaces dots
MsgBox, % RegExReplace("a.b", "\Q.\E") ;replaces dots
MsgBox, % RegExReplace("a...b", "\.\.\.") ;replaces dots
MsgBox, % RegExReplace("a...b", "\Q...\E") ;replaces dots

;CONCEPTS: STORE OUTPUT IN AN OBJECT (NAMED SUBPATTERNS)
;STRINGS: O) (STORE OUTPUT IN AN OBJECT) (AHK V1 ONLY) (AHK-SPECIFIC, NONSTANDARD REGEX)
;STRINGS: (?P<name>needle) (STORE OUTPUT IN AN OBJECT)

;note: for AHK v2, remove the 'O)'
;note: it outputs a RegExMatchObject, not a standard AHK array
RegExMatch(A_Now, "O)^(?P<Year>\d{4})(?P<Month>\d{2})(?P<Day>\d{2})", oMatch)
MsgBox, % oMatch.Year " " oMatch.Month " " oMatch.Day

;CONCEPTS: CHARACTER CLASSES
;CHARACTERS: ^ (CHARACTER CLASS: DOESN'T CONTAIN)
;CHARACTERS: - (CHARACTER CLASS: RANGE OF CHARACTERS)
;CHARACTERS: []
;NOTE: 4 characters that need escaping in a RegEx character class: ^-]\

MsgBox, % RegExReplace("abcdefghij", "[a-e]") ;replace characters a to e
MsgBox, % RegExReplace("abcdefghij", "[f-j]") ;replace characters f to j
MsgBox, % RegExReplace("abcdefghij", "[aeiou]") ;replace vowels
MsgBox, % RegExReplace("abcdefghij", "[^aeiou]") ;replace anything that isn't a vowel
MsgBox, % RegExReplace("abcdefghij", "[ac-hj]") ;replace characters a, c to h, and j

MsgBox, % RegExReplace(vText, "^[ `t]+") ;replace leading whitespace
MsgBox, % RegExReplace(vText, "[ `t]+$") ;replace trailing whitespace

;CONCEPTS: LOOK-AHEAD AND LOOK-BEHIND ASSERTIONS
;STRINGS: (?<=) (?=) (POSITIVE LOOK BEHIND/AHEAD)
;STRINGS: (?<!) (?!) (NEGATIVE LOOK BEHIND/AHEAD)

MsgBox, % RegExMatch(vText, "(?<= )abc") ;replace abc if it's preceded by a space
MsgBox, % RegExMatch(vText, "(?<! )abc") ;replace abc if it's not preceded by a space
MsgBox, % RegExMatch(vText, "abc(?= )") ;replace abc if it's followed by a space
MsgBox, % RegExMatch(vText, "abc(?! )") ;replace abc if it's not followed by a space
MsgBox, % RegExMatch(vText, "(?<= )abc(?= )") ;replace abc if it's preceded and followed by a space
MsgBox, % RegExMatch(vText, "(?<! )abc(?! )") ;replace abc if it's not preceded and followed by a space