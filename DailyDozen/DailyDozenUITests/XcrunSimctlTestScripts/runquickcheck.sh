#cd ../..

### ALL SETS
export APP_BUNDLE_ID="com.nutritionfacts.dailydozen"
#export APP_BUNDLE_PATH="_BuildUnderTest__LOCAL/DailyDozen.app"
export APP_BUNDLE_PATH="DailyDozenUITests/XcrunSimctlTestScripts/_BuildUnderTest__LOCAL"
export DEVICE_UUID_MAX="$UUID_iPhone_11_Pro_Max_15"
export DEVICE_UUID_MID="$UUID_iPhone_8_Plus_15"
export DEVICE_UUID_MIN="$UUID_iPhone_SE_1st_12"
export DEVICE_UUID_MIN="$UUID_iPhone_SE_1st_15"

export DEVICES="Library/Developer/CoreSimulator/Devices/"
export PLIST_LOCAL_PATH="data/Library/Preferences/.GlobalPreferences.plist"
export PLIST_MAX_FULL_PATH="$HOME/$DEVICES/$DEVICE_UUID_MAX/$PLIST_LOCAL_PATH"
export PLIST_MID_FULL_PATH="$HOME/$DEVICES/$DEVICE_UUID_MAX/$PLIST_LOCAL_PATH"
export PLIST_MIN_FULL_PATH="$HOME/$DEVICES/$DEVICE_UUID_MAX/$PLIST_LOCAL_PATH"

## 1st set
export DEVICE_UUID="$DEVICE_UUID_MIN"
export PLIST_FULL_PATH="$PLIST_MIN_FULL_PATH"

## 2nd set
export DEVICE_UUID="$DEVICE_UUID_MAX"
export PLIST_FULL_PATH="$PLIST_MAX_FULL_PATH"

# 3rd set
export DEVICE_UUID="$DEVICE_UUID_MID"
export PLIST_FULL_PATH="$PLIST_MID_FULL_PATH"

plutil -p "$PLIST_FULL_PATH"


#####################################################################################

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testLanguage "pt" \
  -testRegion "BR" \
  -testPlan LocalesQuickCheck


#################################
### pt_BR Portuguese (Brazil) ###
xcrun simctl shutdown $DEVICE_UUID
plutil -replace AppleLocale -string "pt_BR" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"pt\" ]" "$PLIST_FULL_PATH"

xcrun simctl boot $DEVICE_UUID
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testPlan LocalesQuickCheck

###################################
### pt_PT Portuguese (Portugal) ###
plutil -replace AppleLocale -string "pt_PT" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"pt-PT\" ]" "$PLIST_FULL_PATH"

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testPlan LocalesQuickCheck

###########################
### en_US English (USA) ###
plutil -replace AppleLocale -string "en_US" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"en\" ]" "$PLIST_FULL_PATH"

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testPlan LocalesQuickCheck
  
##############################
### de_DE German (Germany) ###
xcrun simctl shutdown $DEVICE_UUID
plutil -replace AppleLocale -string "de_DE" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"de\" ]" "$PLIST_FULL_PATH"

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testPlan LocalesQuickCheck

#############################
### ca_ES Catalan (Spain) ###
plutil -replace AppleLocale -string "ca_ES" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"ca\" ]" "$PLIST_FULL_PATH"

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testPlan LocalesQuickCheck

#############################
### he_IL Hebrew (Israel) ###
plutil -replace AppleLocale -string "he_IL" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"he\" ]" "$PLIST_FULL_PATH"

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testPlan LocalesQuickCheck

##############################
### ru_RU Russian (Russia) ###
plutil -replace AppleLocale -string "ru_RU" "$PLIST_FULL_PATH"
plutil -replace AppleLanguages -json "[ \"ru\" ]" "$PLIST_FULL_PATH"

xcodebuild test \
  -workspace DailyDozen.xcworkspace \
  -scheme DailyDozen \
  -destination "id=$DEVICE_UUID" \
  -testPlan LocalesQuickCheck

