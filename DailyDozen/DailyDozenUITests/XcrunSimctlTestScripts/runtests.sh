#xcrun simctl help
#xcrun simctl list


export APP_BUNDLE_ID="com.nutritionfacts.dailydozen"
export APP_BUNDLE_PATH="_BuildUnderTest__LOCAL/DailyDozen.app"
export DEVICE_UUID="$UUID_iPhone_13_Pro_MAX_15"
export DEVICE_UUID_MID="$UUID_iPhone_8_Plus_15"
export DEVICE_UUID_MIN="$UUID_iPhone_SE_1st_12"
## <device> can also be `booted`



###################
### DEVICE BOOT ###
### xcrun simctl boot <device> [--disabledJob=<job>] [--enabledJob=<job>]
xcrun simctl boot $DEVICE_UUID
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/

###############
### INSTALL ###
### xcrun simctl install <device> <path>
xcrun simctl install $DEVICE_UUID $APP_BUNDLE_PATH

##################
### APP LAUNCH ###
###  xcrun simctl launch  [OPTIONS] <device> <app bundle identifier> [<argv 1> …]
###
### --wait-for-debugger
### --console             Block and print the application's stdout and stderr to the current terminal.
### --stdout=<filepath>   cannot use with --`console`
### --stderr=<filepath>   cannot use with --`console`
### --terminate-running-process  Terminate any running copy of the application.
###          Note: Log output is often directed to stderr, not stdout.
xcrun simctl launch $DEVICE_UUID $APP_BUNDLE_ID

#####################
### APP TERMINATE ###
### xcrun simctl terminate <device> <app bundle identifier>
xcrun simctl terminate $DEVICE_UUID $APP_BUNDLE_ID

#####################
### APP UNINSTALL ###
### xcrun simctl uninstall <device> <app bundle identifier>
xcrun simctl uninstall $DEVICE_UUID $APP_BUNDLE_ID

#######################
### DEVICE SHUTDOWN ###
#xcrun simctl shutdown $DEVICE_UUID
xcrun simctl shutdown $DEVICE_UUID

####################
### DEVICE ERASE ###
### simctl erase <device> [... <device n>]
xcrun simctl erase $DEVICE_UUID


### -------- LANGUAGE & REGION -------- ###

export DEVICES="Library/Developer/CoreSimulator/Devices/"
export PLIST_LOCAL_PATH="data/Library/Preferences/.GlobalPreferences.plist"
export PLIST_FULL_PATH="$HOME/$DEVICES/$DEVICE_UUID/$PLIST_LOCAL_PATH"

### PLIST PRINT ###
### Note: simulator device reset requires a boot for plist file to be created.
plutil -p "$PLIST_FULL_PATH"

plutil -replace AppleLocale -string "de_DE" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"de\" ]" "$PLIST_FULL_PATH"

plutil -replace AppleLocale -string "en_US" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"en\" ]" "$PLIST_FULL_PATH"

### -------- BEFORE TESTS -------- ###
xcrun simctl boot $DEVICE_UUID
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/
xcrun simctl install $DEVICE_UUID $APP_BUNDLE_PATH
xcrun simctl launch $DEVICE_UUID $APP_BUNDLE_ID

## reset all permissions
xcrun simctl privacy booted reset all $APP_BUNDLE_ID

#xcrun simctl ui booted appearance dark
#xcrun simctl status_bar $DEVICE_UUID 
#    --time 9:41 
#    --dataNetwork wifi --wifiMode active --wifiBars 3 
#    --cellularMode active --cellularBars 4 
#    --batteryState charged --batteryLevel 100 
#    --operatorName 'Notificare'

### -------- AFTER TESTS -------- ###
xcrun simctl terminate $DEVICE_UUID $APP_BUNDLE_ID
xcrun simctl uninstall $DEVICE_UUID $APP_BUNDLE_ID
xcrun simctl shutdown $DEVICE_UUID

###########################################################################
###########################################################################


