@ECHO off

set PATH_RUNE=.\..\..\Rune
set PATH_RUNESYS=%PATH_RUNE%\System
IF NOT EXIST %PATH_RUNESYS% (
	ECHO [ERROR] No Rune\System directory located
	GOTO END
)

SET /P PKG="Package to decompile: " %=%

IF NOT EXIST %PATH_RUNESYS%\%PKG%.u (
	ECHO [ERROR] Package not found
	GOTO END
)

REM Export the full package
set PATH_EXPORT=%PATH_RUNE%\Source
%PATH_RUNESYS%\UCC.exe batchexport %PKG% class uc %PATH_EXPORT%\%PKG%\%classes%

:END
	pause