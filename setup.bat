@echo off
title Pipe network Bot by @MeoMunDep
color 0A

cd ..
if exist node_modules (
    echo Found node_modules in parent directory
    cd %~dp0
) else (
    cd %~dp0
    echo node_modules not found in parent directory
)

:MENU
cls
echo =================================================================
echo    Pipe network BOT SETUP AND RUN SCRIPT by @MeoMunDep
echo =================================================================
echo.
echo Current directory: %CD%
echo Parent node_modules: %~dp0..\node_modules
echo.
echo 1. Install/Update Node.js Dependencies
echo 2. Run the Bot
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto RUN
if "%choice%"=="3" goto EXIT

:INSTALL
cls
echo Checking node_modules location...
if exist "..\node_modules" (
    cd ..
    echo Installing/Updating dependencies in parent directory...
    npm install --no-audit --no-fund --prefer-offline --force user-agents axios meo-forkcy-colors meo-forkcy-utils https-proxy-agent socks-proxy-agent ws
    cd %~dp0
) else (
    echo Installing dependencies in current directory...
    npm install --no-audit --no-fund --prefer-offline --force user-agents axios meo-forkcy-colors meo-forkcy-utils https-proxy-agent socks-proxy-agent ws
)
echo.
echo Dependencies installation completed!
pause
goto MENU

:CONFIG
cls

echo.
echo Configuration files have been created/checked.
echo Please edit the files with your data before running the bot.
echo.
pause
goto MENU

:RUN
cls
echo Starting the bot...
if exist "..\node_modules" (
    echo Using node_modules from parent directory
) else (
    echo Using node_modules from current directory
)
node MeoMunDep
pause
goto MENU

:EXIT
exit
