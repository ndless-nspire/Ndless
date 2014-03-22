@echo off
if "%COMMONPROGRAMFILES(X86)%"=="" (set "common=%COMMONPROGRAMFILES%") else (set "common=%COMMONPROGRAMFILES(X86)%")
set PATH=%PATH%;%common%\TI Shared\CommLib\1\NavNet
ndless_navnet_tests.exe
pause