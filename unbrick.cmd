@echo off
setlocal EnableDelayedExpansion
title Router Recovery Utility

:: Change to the script's own directory
cd /d "%~dp0"

echo ======================================================================
echo                      ROUTER RECOVERY UTILITY
echo ======================================================================
echo.

:: --- Auto-detect preloader (BL2) ---
set "preloader="
for %%F in (*ddr3*bl2.bin *ddr4*bl2.bin) do (
    if not defined preloader set "preloader=%%F"
)
if not defined preloader (
    echo [Error] No preloader ^(BL2^) file found.
    echo         Expected mask: *-bl2.bin
    pause & exit /b 1
)

:: --- Auto-detect FIP ---
set "fip="
for %%F in (openwrt*bl31-uboot.fip *.fip) do (
    if not defined fip set "fip=%%F"
)
if not defined fip (
    echo [Error] No FIP file found.
    echo         Expected mask: *-bl31-uboot.fip
    pause & exit /b 1
)

:: --- Optional TFTP server launch ---
:TftpLoop
set "tftpchoice="
set /p tftpchoice="Launch tftpd64 before recovery? (y/n): "
if /i "%tftpchoice%"=="y" (
    echo Starting tftpd64...
    start "" tftpd64.exe
    echo.
) else if /i "%tftpchoice%"=="n" (
    echo Skipping tftpd64.
    echo.
) else (
    echo [Error] Please enter y or n.
    goto TftpLoop
)
echo.
echo Scanning for available COM-ports...
ss -list
echo.

:InputLoop
set "number="
set /p number="Enter COM port number (e.g., 3): "

:: Input validation: check if the user left it blank
if not defined number (
    echo [Error] No input detected. Please enter a number.
    goto InputLoop
)

echo.
echo ----------------------------------------------------------------------
echo Selected port: COM%number%
echo Preloader    : %preloader%
echo FIP          :
echo %fip%
echo ----------------------------------------------------------------------
echo.
echo [ACTION REQUIRED]
echo Power on the router NOW to initiate the recovery boot sequence...
echo.
mtk_uartboot -sCOM%number% -a -p %preloader% -f %fip% && ss c:%number%
pause