@echo off

set ver=v1.2
set cwmver=3.1.0.1
set title=Indulge All in One Root and ClockworkMod %ver% by DRockstar
set menu1=Install Root and ClockworkMod %cwmver%
set menu2=Remove Root and ClockworkMod
set menu3=Reboot Recovery
set menu4=Reboot Phone
set menu5=Quit
set tmpdir=/data/local/tmp/aio

if "%1%"=="-e" (
	call :startserver & call :pushaio & call :checkroot & call :cleanup & goto :eof
)
if "%1%"=="-k" (
	adb kill-server & goto :eof
)
if "%1%"=="-r" (
	call :startserver & call :REBOOT & goto :eof
)
if "%1%"=="-s" (
	call :startserver & goto :eof
)

cd "%~dp0"
IF NOT EXIST aio\rageagainstthecage-arm5.bin goto :missing

:menu
set l=0
set i=0
set a=""
adb kill-server
call :header "%title%" "Credits: DRockstar - Batch script and Indulge ClockworkMod port"
echo Original Indulge One Click Root by k0nane for ACS
echo Other credits: joeykrim, noobnl, skeeterslint, koush, firon, Angablade
echo.
echo.
echo Menu:
echo.
echo 1) %menu1%
echo 2) %menu2%
echo 3) %menu3%
echo 4) %menu4%
echo 5) %menu5%
echo.
echo ONLY ONE MENU ITEM IS RUN AT A TIME
echo.
set menu=""
set /p menu=Type a number [1-5] and press enter: 
echo.
echo.
if "%menu%"=="1" goto :root
if "%menu%"=="2" goto :remove
if "%menu%"=="3" (
	call :header "Reboot Recovery" & call :REBOOT recovery & goto :end
)
if "%menu%"=="4" (
	call :header "Reboot Phone" & call :REBOOT & goto :end
)
if "%menu%"=="5" goto :eof
goto :menu

:root
call :header "%menu1%" "DRockstar: Bash Script and Indulge ClockworkMod Port"
echo Indulge Root by k0nane
echo.
echo IF YOU HAVE PROBLEMS WITH ROOT INSTALL
echo REBOOT PHONE OR TRY DIFFERENT USB PORT
echo.
echo CONNECT USB CABLE NOW AND ENABLE USB DEBUGGING
echo IN PHONE MENU - SETTINGS - APPLICATIONS - DEVELOPMENT

call :main

echo Pushing Root and Clockworkmod Files to Phone...
adb push %sdir%\system /system
echo Running Root and ClockworkMod Setup Script...
adb shell %tmpdir%/rootsetup

call :cleanup
call :REBOOT
goto :end

:remove
call :header "%menu2%" "Uninstaller by DRockstar"
echo REMOVES ALL ONE CLICK ROOTS AND CLOCKWORKMOD
echo.
echo CONNECT USB CABLE NOW AND ENABLE USB DEBUGGING
echo IN PHONE MENU - SETTINGS - APPLICATIONS - DEVELOPMENT

call :main

echo Restoring Stock recovery Binary...
adb push %sdir%\recovery /system/bin/recovery
adb shell chmod 755 /system/bin/recovery

call :cleanup
call :REBOOT
goto :end


:missing
call :header "%title%"
echo rageagainstthecage-arm5.bin is missing. 
echo Make sure you extracted the zip archive correctly.
echo.
pause
goto :eof

:header
cls
echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo %~1
echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo %~2
echo.
goto :eof

:main
call :chooser
if "%a%"=="m" goto :menu
call :startserver
call :checkmodel
call :pushaio
call :checkroot
call :rootclean
goto :eof

:chooser
echo.
set a=""
set /p a=Press enter to continue m+enter for main menu :
echo.
goto :eof

:startserver
adb kill-server
adb start-server
set i=0
set l=0
call :connect
goto :eof

:connect
IF %l%==0 echo Looking for device
@ping 127.0.0.1 -n 2 -w 1000 > nul
set /A l=l+1
set /A i=i+1
FOR /F "tokens=*" %%i in ('"%~dp0adb" get-state') do SET STATE=%%i
IF %i%==30 call :failed
IF "%STATE%" NEQ "device" goto :connect
echo Device found in %l% seconds.
set l=0
goto :eof

:failed
echo Connection to phone not found.
echo Unplug and replug USB cable, press enter when done.
pause
@ping 127.0.0.1 -n 5 -w 1000 > nul
set /A l=l+5
FOR /F "tokens=*" %%i in ('"%~dp0adb" get-state') do SET STATE=%%i
IF "%STATE%"=="device" GOTO :eof
echo.
echo ABORTING SCRIPT. PHONE IS STILL NOT CONNECTED.
echo MANUALLY REBOOT THE PHONE AND RUN AGAIN.
echo PLEASE CHECK YOUR WINDOWS DRIVERS.
echo VISIT FORUM FOR ADDITIONAL GUIDANCE.
echo.
adb kill-server
pause
exit

:checkmodel
echo Checking Current Phone Build...
FOR /F "tokens=*" %%i in ('adb shell getprop ro.product.device') do SET model=%%i
echo.
echo Phone Model is Detected as %model%
echo.
IF "%model%"=="SCH-R910" (
	set sdir=R910
	goto :eof
)
IF "%model%"=="SCH-R915" (
	set sdir=R915
	goto :eof
)
echo.
echo THIS SCRIPT IS FOR SAMSUNG GALAXY INDULGE
echo MODELS SCH-R910 AND SCH-R915 ONLY
echo SCRIPT WILL NOW ABORT
adb kill-server
pause
exit

:pushaio
echo.
echo Killing Microsoft AntiMalware Service...
taskkill /f /im MsMpEng.exe 2>nul
echo.
echo Pushing AIO files to phone...
adb push aio %tmpdir%
adb shell chmod 777 %tmpdir%/*
echo.
echo Restarting Microsoft Antimalware Service...
net start "Microsoft Antimalware Service" 2>nul
goto :eof

:checkroot
echo Checking current root status and run exploit if necessary
FOR /F "tokens=*" %%i in ('adb shell id ^| find "uid=0"') do SET ROOT=%%i
IF "%ROOT%."=="." (
call :exploit
)
FOR /F "tokens=*" %%i in ('adb shell id ^| find "uid=0"') do SET ROOT=%%i
IF "%ROOT%." NEQ "." GOTO :eof
echo.
echo Root was not obtained after 60 seconds. 
echo Make sure the phone is connected and that adb is working. 
echo If adb shell isn't root, reboot the phone and try the script again.
echo.
pause
adb reboot
adb kill-server
exit

:exploit
echo.
echo Copy and run the exploit... (may take up to two minutes)
echo Ignore messages about re-logging in.
echo If more than five minutes pass, reboot the phone and try again.
echo.

adb shell %tmpdir%/root.sh
echo Wait 20 seconds for phone to reconnect...
@ping 127.0.0.1 -n 21 -w 1000 > nul
set i=0
call :connect
echo.
goto :eof

:rootclean
echo Removing all prior Root and ClockworkMod files...
adb shell %tmpdir%/rclean
goto :eof

:cleanup
adb shell %tmpdir%/busybox mount -o remount,ro /system
echo Cleaning up Temporary AIO files...
adb shell rm -r %tmpdir%
goto :eof

:REBOOT
IF "%~1"=="recovery" (
	echo Rebooting into Recovery...
) ELSE (
	echo Rebooting Phone...
)
adb reboot %~1
goto :eof

:end
adb kill-server
echo.
echo All Done!
echo.
pause
goto :eof
