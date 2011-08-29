#!/bin/bash

ver="v0.93 Beta"
cwmver="3.1.0.1"
title="Indulge All in One Root and ClockworkMod $ver by DRockstar"
menu1="Install Root & ClockworkMod $cwmver"
menu2="Remove Root & ClockworkMod"
menu3="Reboot Recovery"
menu4="Reboot Phone"
menu5="Quit"
tmpdir="/data/local/tmp/aio"


# Unix OS Sniffer and $adb setup by Firon
platform=`uname`;
adb="adb";
if [ $(uname -p) == 'powerpc' ]; then
	echo "Sorry, this won't work on PowerPC machines."
exit 1
fi
cd "$(dirname "$0")"
if [ -z $(which adb) ]; then
	adb="./adb";
	if [ "$platform" == 'Darwin' ]; then
		mv adb.osx $adb > /dev/null 2>&1
	fi
fi
chmod +x $adb
# End section, thanks Firon!

if [ ! -f aio/rageagainstthecage-arm5.bin ]; then
clear;echo rageagainstthecage-arm5.bin is missing.; echo Make sure your AV software did not block it.
exit 1
fi

function menu {
MENU_CHOICE=""
header "$title" "Credits: DRockstar - Bash script and Indulge ClockworkMod Port"
echo Original Indulge One Click Root by k0nane for ACS
echo Other credits: joeykrim, noobnl, skeeterslint, koush, firon
echo
echo "MENU:";
echo 
echo " 1) $menu1";
echo " 2) $menu2";
echo " 3) $menu3";
echo " 4) $menu4";
echo " 5) $menu5";

echo
echo ONLY ONE MENU ITEM IS RUN AT A TIME
echo
read -n1 -s -p "Please Type a Number [1-5]: " MENU_CHOICE
echo
echo
case $MENU_CHOICE in
"1") root;;
"2") remove;;
"3") header "Rebooting into Recovery...";REBOOT recovery;end;;
"4") header "Rebooting Phone";REBOOT;end;;
"5") exit;;
*) menu;;
esac
}

function root {
header "$menu1" "DRockstar: Bash Script and Indulge ClockworkMod Port"
echo Indulge Root by k0nane
echo
echo IF YOU HAVE PROBLEMS WITH ROOT INSTALL
echo REBOOT PHONE OR TRY DIFFERENT USB PORT
echo
echo CONNECT USB CABLE NOW AND ENABLE USB DEBUGGING
echo IN PHONE MENU - SETTINGS - APPLICATIONS - DEVELOPMENT

main

echo Pushing Root and Clockworkmod Files to Phone...
$adb push $sdir/system /system
echo Running Root and ClockworkMod Setup Script...
$adb shell $tmpdir/rootsetup

cleanup

REBOOT

end
}

function remove {
header "$menu2" "Uninstaller by DRockstar"
echo REMOVES ALL ONE CLICK ROOTS AND CLOCKWORKMOD
echo
echo CONNECT USB CABLE NOW AND ENABLE USB DEBUGGING
echo IN PHONE MENU - SETTINGS - APPLICATIONS - DEVELOPMENT

main

echo Restoring Stock recovery Binary...
$adb push $sdir/recovery /system/bin/recovery
$adb shell chmod 755 /system/bin/recovery

cleanup

REBOOT

end
}


function header {
clear
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo $1
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo $2
echo
}

function chooser {
echo
read -n1 -s -p "Press any key to continue, or M for Main Menu :" CHOOSE
case $CHOOSE in
[mM]) echo; menu;;
esac
echo
}

function startserver {
killserver
if [ -z $(which sudo 2>/dev/null) ]; then
	$adb start-server
else
	sudo $adb start-server
fi
connect
}

function killserver {
if [ -z $(which sudo 2>/dev/null) ]; then
	$adb kill-server
else
	sudo $adb kill-server
fi
}

function connect {
# Based on timer script contribution from Firon
echo Looking for device
state="unknown"
state=$($adb get-state | tr -d '\r\n[:blank:]')
i=0
while [[ "$state" != device && $i -lt 30 ]]; do
	state=$($adb get-state | tr -d '\r\n[:blank:]')
	let i=i+1
	sleep 1
done
if [ "$state" != "device" ]; then
	echo
	echo The device cannot be found.
	read -n1 -s -p "Plug or replug the USB cable. Press any key to continue.  "
	echo
	sleep 5
	let i=i+5
fi
state=$($adb get-state | tr -d '\r\n[:blank:]')
if [ "$state" != "device" ]; then
	echo
	echo ABORTING SCRIPT. PHONE IS STILL NOT CONNECTED.
	echo MANUALLY REBOOT THE PHONE.
	echo IF ADB OR SCRIPT ERRORS ARE OCCURING,
	echo VISIT FORUM FOR ADDITIONAL GUIDANCE.
	end
fi
echo Device found in $i seconds
echo
}

function checkmodel {
echo Checking current phone model...
model=$($adb shell getprop ro.product.device | tr -d '\r\n[:blank:]')
echo;echo Phone Model is Detected as $model;echo
if [ "$model" == "SCH-R910" ]; then
	sdir="R910"
elif [ "$model" == "SCH-R915" ]; then
	sdir="R915"
else
	echo
	echo THIS SCRIPT IS FOR SAMSUNG GALAXY INDULGE
	echo MODELS SCH-R910 AND SCH-R915 ONLY
	echo SCRIPT WILL NOW ABORT
	echo
	exit
fi
}

function pushaio {
echo Pushing AIO files to phone...
$adb push aio $tmpdir
$adb shell chmod 777 $tmpdir/*
}

function checkroot {
echo Checking current root status and run exploit if necessary
root=$($adb shell id | grep uid=0)
if [ -z "$root" ]; then
	echo "Copy and run the exploit (may take up to two minutes)"
	echo Ignore messages about re-logging in.
	echo If more than five minutes pass, reboot the phone and try again.
	echo
	$adb shell $tmpdir/root.sh
	echo
	echo Wait 20 seconds for phone to reconnect...
	sleep 20
fi
connect
root=$($adb shell id | grep uid=0)
	if [ -z "$root" ]; then
		echo "Root exploit did not work. Please re-run the script."
		end;
	fi
}

function rootclean {
echo Removing all prior Root and ClockworkMod files...
$adb shell $tmpdir/rclean
}

function main {
chooser
startserver
checkmodel
pushaio
checkroot
rootclean
}

function cleanup {
$adb shell $tmpdir/busybox mount -o remount,ro /system
echo "Cleaning up Temporary AIO files..."
$adb shell rm -r $tmpdir
}

function REBOOT {
if [ "$1" == "recovery" ]; then
	echo Rebooting into Recovery...
else
	echo Rebooting Phone...
fi
$adb start-server
$adb reboot $1
}

function end {
killserver
echo
echo All Done!
echo
read -n1 -s -p "Press any key to exit, or M for Main Menu :" CHOOSE
case $CHOOSE in
[mM]) echo; menu;;
esac
echo; echo
exit
}

case $1 in
"-e") startserver;pushaio;checkroot;exit;;
"-k") killserver;exit;;
"-r") startserver;REBOOT;exit;;
"-s") startserver;exit;;
esac

menu
