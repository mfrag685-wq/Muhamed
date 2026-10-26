@echo off
REM Al-Bishi website: compress images and videos (Windows version of optimize-media.sh)
REM Run from the website folder (the one containing images\ and videos\):
REM     scripts\optimize-media.bat
REM Requires ffmpeg in PATH (https://www.gyan.dev/ffmpeg/builds/ - "full" build).
REM Original files are NOT modified or deleted.
setlocal enabledelayedexpansion
where ffmpeg >nul 2>nul || (echo ffmpeg not found in PATH & exit /b 1)
set FF=ffmpeg -hide_banner -loglevel error -y

if not exist images\web\thumb mkdir images\web\thumb
if not exist images\web\large mkdir images\web\large
if not exist videos\web mkdir videos\web

echo == Gallery images ==
REM Windows file matching is case-insensitive, so *.jpg also matches .JPG
for %%F in (images\DSC*.jpg) do (
  %FF% -i "%%F" -vf "scale=800:-2" -c:v libwebp -quality 72 "images\web\thumb\%%~nF.webp"
  %FF% -i "%%F" -vf "scale='min(1920,iw)':-2" -c:v libwebp -quality 78 "images\web\large\%%~nF.webp"
  echo   %%~nF
)

echo == Logo and icons ==
set LOGO=images\BSHLOGO.png
if not exist %LOGO% set LOGO=images\BSHLOGO.PNG
%FF% -i %LOGO% -vf "scale=256:256:force_original_aspect_ratio=decrease" images\web\logo-256.png
%FF% -i %LOGO% -vf "scale=32:32:force_original_aspect_ratio=decrease" images\web\favicon-32.png
%FF% -i %LOGO% -vf "scale=180:180:force_original_aspect_ratio=decrease,pad=180:180:(ow-iw)/2:(oh-ih)/2:color=white" images\web\apple-touch-icon.png

echo == Share image (Open Graph) ==
if exist images\DSC06343.JPG %FF% -i images\DSC06343.JPG -vf "scale=1200:630:force_original_aspect_ratio=increase,crop=1200:630" -q:v 4 images\web\og-cover.jpg

echo == Expo video (463MB to about 5MB) ==
if exist videos\star055.mp4 (
  %FF% -ss 2 -i videos\star055.mp4 -frames:v 1 -vf "scale=1600:-2" -q:v 4 images\web\hero-poster.jpg
  %FF% -i videos\star055.mp4 -t 20 -vf "scale=1280:-2,fps=25" -c:v libx264 -preset slow -crf 28 -profile:v high -pix_fmt yuv420p -c:a aac -b:a 96k -movflags +faststart videos\web\hero.mp4
)

echo == Equipment video (1.8GB to about 20MB) ==
if exist videos\equipment_video.mp4 (
  %FF% -ss 5 -i videos\equipment_video.mp4 -frames:v 1 -vf "scale=1280:-2" -q:v 4 images\web\equipment-poster.jpg
  %FF% -i videos\equipment_video.mp4 -vf "scale='min(1920,iw)':-2,fps=30" -c:v libx264 -preset slow -crf 24 -profile:v high -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart videos\web\equipment.mp4
)

echo.
echo Done. Check images\web and videos\web
endlocal
