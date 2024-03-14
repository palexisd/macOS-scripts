#!/bin/bash
#set -x

d=$(date '+%Y-%m-%d_%I.%M.%S')

loggedInUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }')

gdrivePid=($(ps aux | grep "Google Drive" | awk '{print $2}'))

gdriveFiles=(
    "/Applications/Google\ Drive.app"
    "/Users/$loggedInUser/Library/Application Scripts/com.google.drivefs.finderhelper"
    "/Users/$loggedInUser/Library/Application Scripts/com.google.drivefs.finderhelper.findersync"
    "/Users/$loggedInUser/Library/Application Scripts/com.google.drivefs.fpext"
    "/Users/$loggedInUser/Library/Containers/com.google.drivefs.finderhelper"
    "/Users/$loggedInUser/Library/Containers/com.google.drivefs.finderhelper.findersync"
    "/Users/$loggedInUser/Library/Containers/com.google.drivefs.fpext"
    "/Users/$loggedInUser/Library/Group Containers/EQHXZ8M8AV.group.com.google.drivefs/"
    "/Users/$loggedInUser/Library/Preferences/com.google.drivefs.helper.renderer.plist"
    "/Users/$loggedInUser/Library/Preferences/com.google.drivefs.plist"
    "/Users/$loggedInUser/Library/Preferences/com.google.drivefs.settings.plist"
    "/var/db/receipts/com.google.drivefs.arm64.bom"
    "/var/db/receipts/com.google.drivefs.arm64.plist"
    "/var/db/receipts/com.google.drivefs.filesystems.dfsfuse.arm64.bom"
    "/var/db/receipts/com.google.drivefs.filesystems.dfsfuse.arm64.plist"
    "/var/db/receipts/com.google.drivefs.shortcuts.bom"
    "/var/db/receipts/com.google.drivefs.shortcuts.plist"
)

#kill google drive processes
for pid in "${gdrivePid[@]}"; do 

    kill -9 $pid

done

#delete google drive related files
for file in "${gdriveFiles[@]}"; do

    rm -rf $file

done

#rename CloudStorage and DriveFS
mv /Users/$loggedInUser/Library/Application\ Support/Google/DriveFS /Users/$loggedInUser/Library/Application\ Support/Google/DriveFS$d
mv /Users/$loggedInUser/Library/CloudStorage /Users/$loggedInUser/Library/CloudStorage$d

#reinstall Google Drive
/usr/local/Installomator/Installomator.sh googledrive NOTIFY=slient
open -a "Google Drive"