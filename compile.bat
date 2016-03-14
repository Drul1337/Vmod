@ECHO off
REM Get package name
for %%A in ("%~f0\..") do set "PACKAGE_NAME=%%~nxA"
TITLE %PACKAGE_NAME%

REM Verify a parallel Rune directory
SET PATH_RUNE=.\..\Rune
IF NOT EXIST %PATH_RUNE% (
	ECHO.
	ECHO [ERROR] No parallel directory named Rune found
	GOTO END
)

REM Verify a System directory within that Rune directory
SET PATH_RUNESYS=%PATH_RUNE%\System
IF NOT EXIST %PATH_RUNESYS% (
	ECHO.
	ECHO [ERROR] No System directory with Rune directory
	GOTO END
)

REM Verify the config directory
SET PATH_CONFIG=.\config
IF NOT EXIST %PATH_CONFIG% (
	ECHO.
	ECHO [ERROR] Template directories malformed {Missing config directory}
	GOTO END
)

REM Verify the package source directory
SET PATH_PKG=.\package
IF NOT EXIST %PATH_PKG% (
	ECHO.
	ECHO [ERROR] Template directories malformed {Missing config directory}
	GOTO END
)



SET FN_INI_COMP=compile.ini
SET FN_INI=%PACKAGE_NAME%.ini
SET FN_INT=%PACKAGE_NAME%.int
SET FN_PKG=%PACKAGE_NAME%.u

REM Clean the current package installation
IF EXIST %PATH_RUNESYS%\%FN_PKG% (
	ECHO.
	ECHO [INFO] Removing current package installation
	DEL %PATH_RUNESYS%\%FN_PKG%
)

REM Clean the package source from Rune directory
ECHO.
ECHO [INFO] Cleaning package source from Rune directory
RMDIR %PATH_RUNE%\%PACKAGE_NAME% /S /Q

REM Copy package source to Rune for compiling
ECHO.
ECHO [INFO] Copying package source to Rune directory for compiling
XCOPY "%PATH_PKG%" "%PATH_RUNE%\%PACKAGE_NAME%" /I /E /S /Y

REM Compile with UCC
REM Config files are specified in relation to UCC.exe, NOT the package directory
IF EXIST %PATH_CONFIG%\%FN_INI_COMP% (
	SET COMP_INI=%PATH_CONFIG%\%FN_INI_COMP%
	SET COMP_INI=.\..\..\%PACKAGE_NAME%\%PATH_CONFIG%\%FN_INI_COMP%
)
IF NOT DEFINED COMP_INI (
	ECHO.
	ECHO [WARNING] No compile configuration file found, using default
	SET COMP_INI=Rune.ini
)
ECHO.
ECHO [INFO] Compiling with UCC
%PATH_RUNESYS%\UCC.exe make INI=%COMP_INI%

REM Copy in int file if one exists within config
IF EXIST %PATH_CONFIG%\%FN_INT% (
	ECHO.
	ECHO [INFO] Package int file located, copying to Rune/System
	XCOPY "%PATH_CONFIG%\%FN_INT%" "%PATH_RUNESYS%\%FN_INT%*" /Y
)

REM Populate the build directory with generated files
ECHO.
ECHO [INFO] Copying generated package files to build directory
set PATH_BUILD=.\build
IF EXIST %PATH_RUNESYS%\%FN_PKG% (
	XCOPY "%PATH_RUNESYS%\%FN_PKG%" "%PATH_BUILD%\%FN_PKG%*" /Y
)
IF EXIST %PATH_RUNESYS%\%FN_INI% (
	XCOPY "%PATH_RUNESYS%\%FN_INI%" "%PATH_BUILD%\%FN_INI%*" /Y
)
IF EXIST %PATH_RUNESYS%\%FN_INT% (
	XCOPY "%PATH_RUNESYS%\%FN_INT%" "%PATH_BUILD%\%FN_INT%*" /Y
)
set PATH_DOCS=.\docs
set FN_README=README.MD
IF EXIST %PATH_DOCS%\%FN_README% (
	XCOPY "%PATH_DOCS%\%FN_README%" "%PATH_BUILD%\%FN_README%*" /Y
)

REM Ask the user if they want to launch rune
ECHO.
SET /P LAUNCH="Launch Rune? (Y / N): " %=%
IF "%LAUNCH%"=="Y" (
	%PATH_RUNESYS%\Rune.exe
)

:END
	pause