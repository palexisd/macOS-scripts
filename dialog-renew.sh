#!/bin/bash

#  FUNCTIONS START
function dialogInstall(){
  echo "Installing Dialog..."  
  # Get the URL of the latest PKG From the Dialog GitHub repo
  dialogURL=$(curl --silent --fail "https://api.github.com/repos/swiftDialog/swiftDialog/releases/latest" | awk -F '"' "/browser_download_url/ && /pkg\"/ { print \$4; exit }")
  # Expected Team ID of the downloaded PKG
  expectedDialogTeamID="PWA5E9TQ59"

    # Create temporary working directory
    workDirectory=$( /usr/bin/basename "$0" )
    tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )
    # Download the installer package
    /usr/bin/curl --location --silent "$dialogURL" -o "$tempDirectory/Dialog.pkg"
    # Verify the download
    teamID=$(/usr/sbin/spctl -a -vv -t install "$tempDirectory/Dialog.pkg" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()')
    # Install the package if Team ID validates
    if [ "$expectedDialogTeamID" = "$teamID" ] || [ "$expectedDialogTeamID" = "" ]; then
      /usr/sbin/installer -pkg "$tempDirectory/Dialog.pkg" -target /
    fi
    # Remove the temporary working directory when done
    /bin/rm -Rf "$tempDirectory"
    echo "Dialog installed!"
}

function renewCheck(){
    echo "Checking Renew..."
    latestVersion=$(curl --silent --fail "https://api.github.com/repos/SecondSonConsulting/Renew/releases/latest" | awk -F '"' '/tag_name/ {print $4}')
    renewURL=$(curl --silent --fail "https://api.github.com/repos/SecondSonConsulting/Renew/releases/latest" | egrep -v "NoAgent" | awk -F '"' "/browser_download_url/ && /pkg\"/ { print \$4; exit }")
    renewVersion=$(grep "scriptVersion=" /usr/local/Renew.sh 2>/dev/null | awk -F '"' '{print $2}' )
    # Expected Team ID of the downloaded PKG
    expectedRenewTeamID="7Q6XP5698G"
     # Check for Renew and install if not found
    if [ ! -e "/usr/local/Renew.sh" ] || [ "v$renewVersion" != "$latestVersion" ]; then
        # Install Renew
        echo "Renew.sh not found or out of date. Installing..."
        # Create temporary working directory
        workDirectory=$( /usr/bin/basename "$0" )
        tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )
        # Download the installer package
        /usr/bin/curl --location --silent "$renewURL" -o "$tempDirectory/Renew.pkg"
        # Verify the download
        teamID=$(/usr/sbin/spctl -a -vv -t install "$tempDirectory/Renew.pkg" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()')
        # Install the package if Team ID validates
        if [ "$expectedRenewTeamID" = "$teamID" ] || [ "$expectedRenewTeamID" = "" ]; then
            /usr/sbin/installer -pkg "$tempDirectory/Renew.pkg" -target /
        fi
        # Remove the temporary working directory when done
        /bin/rm -Rf "$tempDirectory"
        echo "Renew installed!"
    else     
        echo "Renew Found and up to date!"
    fi
}
#  FUNCTIONS END

#  VARIABLE START
dialogPath="/Library/Application Support/Dialog/Dialog.png"
md5Result=$(md5 "$dialogPath" 2>/dev/null | awk '{ print $5 }')
expectedMd5="da4bed07dbd06ecb58c61671db09654f"
pngUrl=""
#  VARIABLE END

# Check if the Dialog Folder exists
if [ ! -e "/Library/Application Support/Dialog" ]; then
    echo "Dialog folder does not exist. Creating folder..."
    mkdir "/Library/Application Support/Dialog"
fi
# Check if the Dialog.png file exists
if [ -f "$dialogPath" ]; then
    echo "Dialog.png already exists! Checking MD5sum..."
    # Check if MD5sum is the same as the expected file.
    if [ "$md5Result" != "$expectedMd5" ]; then
	    echo "MD5sum mismatch. Downloading new file..."
	    rm -rf "$dialogPath"
	    curl -o "$dialogPath" "$pngUrl"
    else
	    echo "MD5 sum is the same!"
    fi
else
  	echo "File $dialogPath not found. Downloading Dialog.png..."
	curl -o "$dialogPath" "$pngUrl"
    echo "File downloaded!"
fi

dialogInstall

renewCheck
