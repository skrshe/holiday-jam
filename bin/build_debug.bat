@echo off

:: This creates a build that is similar to a release build, but it's debuggable.
:: There is no hot reloading and no separate game library.

set OUT_DIR=out\debug

if not exist %OUT_DIR% mkdir %OUT_DIR%

odin build main_release -out:%OUT_DIR%\game_debug.exe -debug
IF %ERRORLEVEL% NEQ 0 exit /b 1

xcopy /y /e /i res %OUT_DIR%\res > nul
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo Debug build created in %OUT_DIR%
