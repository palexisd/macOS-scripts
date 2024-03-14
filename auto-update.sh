#!/bin/bash
#set -x 

# PATH declaration
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Logging file created /var/tmp
d=$(date '+%Y-%m-%d %I:%M:%S')
log="${d} : APPUPDATE :"

# Create the log file
touch /var/tmp/APPUPDATE.log

# Open permissions to account for all error catching
chmod 777 /var/tmp/APPUPDATE.log

# Begin Logging
echo "${log} [LOG-BEGIN]" 2>&1 | tee -a /var/tmp/APPUPDATE.log

# Check if Installomator is installed and up to date. If not, install latest version
echo "${log} Checking if Installomator is installed or up to date" 2>&1 | tee -a /var/tmp/APPUPDATE.log
curl -s https://raw.githubusercontent.com/Installomator/Installomator/main/MDM/install%20Installomator%20direct.sh | sh 2>&1 | tee -a /var/tmp/APPUPDATE.log

# No sleeping
/usr/bin/caffeinate -d -i -m -u &
caffeinatepid=$!
caffexit () {

    kill "$caffeinatepid"
    exit $1

}

# List of applications installed for all users
applicationsUpdate="anydesk
googlechromepkg
chromeremotedesktop
adobecreativeclouddesktop
adobereaderdc
microsoftteams
vlc
zoom"

# List of additional applications, not installed for all users
additionalApplications=("/Applications/Firefox.app,firefoxpkg"
"/Applications/blender.app,blender"
"/Applications/Connect Fonts.app,connectfonts"
"/Applications/Webex.app,webex"
"/Applications/Arc.app,arcbrowser"
"/Applications/Cryptomator.app,cryptomator"
"/Applications/Docker.app,docker"
"/Applications/LibreOffice.app,libreoffice"
"/Applications/KeePassXC.app,keepassxc"
"/Applications/Obsidian.app,obsidian"
"/Applications/$(mdls /Applications/Python* -name kMDItemFSName | awk '{print $3,$4}' | sort -V | tail -n 1 | sed 's/"//g'),python"
"/Applications/Sketch.app,sketch"
"/Applications/Visual Studio Code.app,microsoftvisualstudiocode"
"/Applications/Wireshark.app,wireshark")


# Loop through each applications in $additionalApplications, if a matching app is found in /Applications, add label to $applicationsUpdate
echo "${log} Checking if additional applications are installed." 2>&1 | tee -a /var/tmp/APPUPDATE.log

for app in "${additionalApplications[@]}"; do

    checkPath="$(echo "$app" | cut -d ',' -f 1)"

    label="$(echo "$app" | cut -d ',' -f 2)"

    if [ -e "$checkPath" ]; then

	applicationsUpdate=$(printf "%s\n" "$applicationsUpdate" "$label")
        echo "${log} $checkPath is installed. Adding to update list." 2>&1 | tee -a /var/tmp/APPUPDATE.log

    else

        echo "${log} Skipping $checkPath"  2>&1 | tee -a /var/tmp/APPUPDATE.log
		
    fi

done

echo "${log} List of applications to update:" 2>&1 | tee -a /var/tmp/APPUPDATE.log
printf "%s\n" "$applicationsUpdate" 2>&1 | tee -a /var/tmp/APPUPDATE.log
echo "\n${log} [STARTING-UPDATES]" 2>&1 | tee -a /var/tmp/APPUPDATE.log

# Loop through each labels in the final version of $applicationsUpdate and run them through Installomator
for apps in $applicationsUpdate; do	
		
	/usr/local/Installomator/Installomator.sh $apps BLOCKING_PROCESS_ACTION=prompt_user PROMPT_TIMEOUT=150 NOTIFY=slient NOTIFY_DIALOG=1 LOGO="/Library/Application\ Support/Dialog/Dialog.png" 2>&1 | tee -a /var/tmp/APPUPDATE.log 
	
done

echo "${log} [LOG-END]\n" 2>&1 | tee -a /var/tmp/APPUPDATE.log

caffexit
