@echo off
chcp 65001 >nul
title Video Stabilizer by Samuel Extehines Heydemans
cd /d "%~dp0"

REM ==========================================================
REM  Video Stabilizer (FFmpeg vidstab, 2-pass)
REM  Author : Samuel Extehines Heydemans (GitHub: @samwhine)
REM  Usage  : Put this file in the same folder as your videos,
REM           then double-click. Originals are never touched.
REM           Output goes to the "Stabilized Video" folder.
REM ==========================================================

set "OUT=Stabilized Video"
set "PRESET=slow"

where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo [ERROR] ffmpeg was not found in PATH.
    pause
    exit /b 1
)

echo ======================================
echo  VIDEO STABILIZER
echo  Author: Samuel Extehines Heydemans [@samwhine]
echo  Folder: %CD%
echo ======================================
echo.
echo  Stabilization mode:
echo.
echo   1. Most Stable    - smoothest, gimbal-like, most cropping
echo   2. Recommended    - balanced smoothness and cropping
echo   3. Minimum Cut    - least cropping, lighter stabilization
echo.
choice /c 123 /n /m "Choose 1, 2 or 3: "

if errorlevel 3 goto mode3
if errorlevel 2 goto mode2
goto mode1

:mode1
set "TAG=most-stable"
set "SMOOTH=45"
set "SHAKINESS=10"
set "OPTZOOM=1"
set "ZOOMSPEED=0.25"
goto quality

:mode2
set "TAG=recommended"
set "SMOOTH=30"
set "SHAKINESS=8"
set "OPTZOOM=1"
set "ZOOMSPEED=0.25"
goto quality

:mode3
set "TAG=min-cut"
set "SMOOTH=10"
set "SHAKINESS=6"
set "OPTZOOM=2"
set "ZOOMSPEED=0.1"
goto quality

:quality
echo.
echo  Output quality:
echo.
echo   1. Maximum   - closest to the original, best for color grading, biggest files
echo   2. High      - very high quality, smaller files
echo   3. Balanced  - good quality, smallest files
echo.
choice /c 123 /n /m "Choose 1, 2 or 3: "

if errorlevel 3 goto q3
if errorlevel 2 goto q2
goto q1

:q1
set "QTAG=max"
set "CRF=8"
goto start

:q2
set "QTAG=high"
set "CRF=12"
goto start

:q3
set "QTAG=balanced"
set "CRF=15"
goto start

:start
echo.
echo Mode: %TAG% [smoothing=%SMOOTH%]  Quality: %QTAG% [CRF %CRF%]
if not exist "%OUT%" mkdir "%OUT%"
set COUNT=0

for %%F in (*.mp4 *.mov *.mkv *.m4v *.mts *.avi) do call :process "%%~fF"

echo.
if %COUNT%==0 (
    echo [WARN] No videos found. Put Stabilize.bat in the same folder as your videos.
    rmdir "%OUT%" 2>nul
) else (
    echo Done. %COUNT% video[s] processed. Results are in the "%OUT%" folder.
)
pause
exit /b 0

:process
set "IN=%~1"
for %%I in ("%IN%") do set "NAME=%%~nI"
set /a COUNT+=1
if exist "%OUT%\%NAME%_%TAG%_%QTAG%.mp4" (
    echo [SKIP] %NAME% already has a %TAG% / %QTAG% result
    goto :eof
)
echo.
echo [PASS 1/2] Analyzing motion: %NAME%
ffmpeg -hide_banner -loglevel error -stats -y -i "%IN%" -vf vidstabdetect=shakiness=%SHAKINESS%:accuracy=15:stepsize=4:result=_temp.trf -f null -
echo [PASS 2/2] Stabilizing and rendering: %NAME%
ffmpeg -hide_banner -loglevel error -stats -y -i "%IN%" -vf vidstabtransform=input=_temp.trf:smoothing=%SMOOTH%:optzoom=%OPTZOOM%:zoomspeed=%ZOOMSPEED%:interpol=bicubic -c:v libx264 -crf %CRF% -preset %PRESET% -pix_fmt yuv420p -c:a copy -map_metadata 0 -movflags +faststart "%OUT%\%NAME%_%TAG%_%QTAG%.mp4"
if exist _temp.trf del _temp.trf
goto :eof
