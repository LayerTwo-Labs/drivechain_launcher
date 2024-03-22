@echo off
REM Define the directory names
SET DRIVECHAIN_DIR=Drivechain
SET LAUNCHER_DIR=drivechain_launcher
SET LAUNCHER_SIDECHAINS_DIR=drivechain_launcher_sidechains
SET TESTCHAIN_DIR=Testchain

REM Delete the Drivechain directory
IF EXIST "%APPDATA%\%DRIVECHAIN_DIR%" (
    ECHO Deleting the Drivechain directory...
    RMDIR /S /Q "%APPDATA%\%DRIVECHAIN_DIR%"
    ECHO Deletion complete.
) ELSE (
    ECHO Drivechain directory not found.
)

REM Delete the drivechain_launcher directory
IF EXIST "%APPDATA%\%LAUNCHER_DIR%" (
    ECHO Deleting the drivechain_launcher directory...
    RMDIR /S /Q "%APPDATA%\%LAUNCHER_DIR%"
    ECHO Deletion complete.
) ELSE (
    ECHO drivechain_launcher directory not found.
)

REM Delete the drivechain_launcher_sidechains directory
IF EXIST "%APPDATA%\%LAUNCHER_SIDECHAINS_DIR%" (
    ECHO Deleting the drivechain_launcher_sidechains directory...
    RMDIR /S /Q "%APPDATA%\%LAUNCHER_SIDECHAINS_DIR%"
    ECHO Deletion complete.
) ELSE (
    ECHO drivechain_launcher_sidechains directory not found.
)

REM Delete the Testchain directory
IF EXIST "%APPDATA%\%TESTCHAIN_DIR%" (
    ECHO Deleting the Testchain directory...
    RMDIR /S /Q "%APPDATA%\%TESTCHAIN_DIR%"
    ECHO Deletion complete.
) ELSE (
    ECHO Testchain directory not found.
)

ECHO All specified directories have been processed.
