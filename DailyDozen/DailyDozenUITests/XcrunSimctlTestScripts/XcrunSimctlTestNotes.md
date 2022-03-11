# xcrun simctl Test Notes

## Contents <a id="contents"></a>
* [Step 1. Setup Environment Variables](#step-1-setup-environment-variables-)
* [Step 2. Reset Device State](#step-2-reset-device-state-)
* [Step 3. Set Device Language (Region)](#step-3-set-device-language-region-)
* [Step 4. Run Device Test](#step-4-run-device-test-)
* [Resources](#resources-)

## Step 1. Setup Environment Variables <a id="step-1-setup-environment-variables-"></a><sup>[▴](#contents)</sup>

Setup the machine specific environment variables in the appropriate resources file such as `~/.zshrc` or `$HOME/.bash_profile`. Edit simulator names in Xcode to replace spaces with underscore and append the major ios version to the name. For example, "iOS 15.2, iPhone 8" becomes `iPhone_8_15` and "iOS 14.5, iPad Pro (11-inch) (3rd generation)" becomes `iPad_Pro_11in_3rd_14`. Replace `Xʀ` with `Xr`

![](XcrunSimctlTestNotes_files/SimulatorList.png)

_list devices_

``` sh
# xcrun simctl delete unavailable
xcrun simctl list devices
```

_regex find & replace_

``` regex
   Find: ^[ ]*([^ ]*)[ (]*([^)]*).*
Replace: export UUID_$1="$2"
```

_`~/.zshrc`_

``` sh
###
### XCRUN SIMCTL: SIMULATOR DEVICE UUIDs
###
# ...
export UUID_iPhone_13_15="4A0A9B73-0A6E-4182-9613-7184022EC4F6"
export UUID_iPhone_13_mini_15="59B39458-A7F2-4E5D-AFE8-54788EF8E8AF"
export UUID_iPhone_13_Pro_15="63081D25-20AE-4A46-8097-991ECEB5FCAB"
export UUID_iPhone_13_Pro_Max_15="D61EF1F2-FEAE-4C29-9BF6-21F408C22CCE"
```

## Step 2. Reset Device State <a id="step-2-reset-device-state-"></a><sup>[▴](#contents)</sup>

``` sh
#xcrun simctl erase DEVICE_UUID
xcrun simctl erase $UUID_iPhone_13_Pro_Max_15
```

## Step 3. Set Device Language (Region) <a id="step-3-set-device-language-region-"></a><sup>[▴](#contents)</sup>

> Approach: Using `plutil` to modify the region settings for a specific simulator.

| Langauge (Region)     | AppleLanguages | AppleLocale |
|-----------------------|----------------|-------------|
| English (US)          | en-US          | en_US       |
| Catalan (Andorra)     | ca-AD          | ca_AD       |
| Catalan (Spain)       | ca-ES          | ca_ES       |
| German (Germany)      | de-DE          | de_DE       |
| Hebrew (Israel)       | he-IL          | he_IL       |
| Portuguese (Brazil)   | pt-BR          | pt_BR       |
| Portuguese (Portugal) | pt-PT          | pt_PT       |
| Russian (Russia)      | ru-RU          | ru_RU       |
| Spanish (Spain)       | es-ES          | es_ES       |

_$HOME/Library/Developer/CoreSimulator/Devices/UUID_DEVICE/data/Library/Preferences/.GlobalPreferences.plist_

``` xml
<key>AppleLanguages</key>
<array>
    <string>es-ES</string>
</array>
<key>AppleLocale</key>
<string>es_ES</string>
<array>
    <string>es_ES@sw=QWERTY-Spanish;hw=Automatic</string>
    <string>en_US@sw=QWERTY;hw=Automatic</string>
    <string>emoji@sw=Emoji</string>
    <string>de_DE@sw=QWERTZ-German;hw=Automatic</string>
    <string>he_IL@sw=Hebrew;hw=Automatic</string>
    <string>pt_BR@sw=QWERTY;hw=Automatic</string>
    <string>pt_PT@sw=QWERTY;hw=Automatic</string>
    <string>ru_RU@sw=Russian;hw=Automatic</string>
    <string>ru_RU@sw=Russian-Phonetic;hw=Automatic</string>
</array>
```

_`~/.zshrc` setup_

``` sh
###
### DEVICE PREFERENCES LIST (plist)
###
SIM_DEVICE_DIR="$HOME/Library/Developer/CoreSimulator/Devices"
SIM_DEVICE_PREFS="data/Library/Preferences/.GlobalPreferences.plist"

function devicePrefsPath() {
    echo "$SIM_DEVICE_DIR/$1/$SIM_DEVICE_PREFS"
}

## set region
## example: setDeviceRegion  $UUID_iPhone_12_15 "en"
function setDeviceRegion() {
    ## $1 - device uuid
    ## $2 - device region
    prefsPath="$SIM_DEVICE_DIR/$1/$SIM_DEVICE_PREFS"
    plutil -replace AppleLocale -string "$2" "$prefsPath"
}

## set language
## example: setDeviceLanguage $UUID_iPhone_12_15 "en" 
function setDeviceLanguage() {
    ## $1 - device uuid
    ## $2 - device language
    prefsPath="$SIM_DEVICE_DIR/$1/$SIM_DEVICE_PREFS"
    plutil -replace AppleLanguages -json "[ \"$2\" ]" "$prefsPath" 
}
```

_check: preferences path_

> Note: The simulator devices needs to have beenn launched once for the `.GlobalPreferences.plist` to be present.

``` sh
## Uses $() function command syntax
prefsPath=$(devicePrefsPath $UUID_iPhone_13_Pro_Max_15)  
echo $prefsPath
# -p  print the property list in a human-readable fashion.
plutil -p "$prefsPath"
```

_check: set Spanish then launch_

``` sh
devicePrefsPath $UUID_iPhone_13_Pro_Max_15
xcrun simctl shutdown $UUID_iPhone_13_Pro_Max_15

setDeviceLanguage $UUID_iPhone_13_Pro_Max_15 "es-ES"
setDeviceRegion   $UUID_iPhone_13_Pro_Max_15 "es_ES"

xcrun simctl boot $UUID_iPhone_13_Pro_Max_15
```

_check: set Hebrew then launch_

``` sh
devicePrefsPath $UUID_iPhone_13_Pro_Max_15
xcrun simctl shutdown $UUID_iPhone_13_Pro_Max_15

setDeviceLanguage $UUID_iPhone_13_Pro_Max_15 "he-IL"
setDeviceRegion   $UUID_iPhone_13_Pro_Max_15 "he_IL"

xcrun simctl boot $UUID_iPhone_13_Pro_Max_15
```

_check: set English then launch_

``` sh
devicePrefsPath $UUID_iPhone_13_Pro_Max_15
xcrun simctl shutdown $UUID_iPhone_13_Pro_Max_15

setDeviceLanguage $UUID_iPhone_13_Pro_Max_15 "en-US"
setDeviceRegion   $UUID_iPhone_13_Pro_Max_15 "en_US"

xcrun simctl boot $UUID_iPhone_13_Pro_Max_15
```

## Step 4. Run Device Test <a id="step-4-run-device-test-"></a><sup>[▴](#contents)</sup>

``` sh
xcodebuild clean

xcodebuild -showdestinations -workspace DailyDozen.xcworkspace -scheme DailyDozen

xcodebuild -list -workspace DailyDozen.xcworkspace

# Information about workspace "DailyDozen":
#     Schemes:
#         …
#         DailyDozen

xcodebuild -showTestPlans \
    -workspace DailyDozen.xcworkspace \
    -scheme DailyDozen \
    -destination "name=iPhone_11_Pro_Max_15"

#export DEST_iPhone_11_Pro_Max_15="OS=15.2,name=iPhone_11_Pro_Max_15"
#xcodebuild  -showTestPlans -scheme DailyDozen -destination "$DEST_iPhone_11_Pro_Max_15"
xcodebuild  -showTestPlans -scheme DailyDozen -destination "name=iPhone_11_Pro_Max_15"

# Test plans associated with the scheme "DailyDozen":
#         DailyDozen
#         LocalesQuickCheck

```

```
cd ../..

```

## Screenshot Specifications <a id="screenshot-specifications-"></a><sup>[▴](#contents)</sup>

* 6.5 inch (iPhone 13 Pro Max, iPhone 12 Pro Max, iPhone 11 Pro Max, iPhone 11, iPhone XS Max, iPhone XR)
    * 1284 x 2778 pixels (portrait)
        * iPhone 13 Pro Max/12 Pro Max
    * 2778 x 1284 pixels (landscape)
    * 1242 x 2688 pixels (portrait) … current screenshot size
        * iPhone 11 Pro Max/XS Max
    * 2688 x 1242 pixels (landscape)
* 5.5 inch (iPhone 8 Plus, iPhone 7 Plus, iPhone 6s Plus)
    * 1242 x 2208 pixels (portrait) … current screenshot size
    * 2208 x 1242 pixels (landscape)
* Smallest
    * 640 × 1136 (4"), 9:16, 326 ppi
        * iPod touch (gen 7), iOS 12 - 15 
        * iPhone SE (gen 1), iOS 9 - 15
        * iPhone 5s, iOS 7 - 12
    * 750 × 1334 (4.7")
        * iPhone SE (gen 3), SE (gen 2), 8, 7, 6s … up to iOS 15

## Resources <a id="resources-"></a><sup>[▴](#contents)</sup>

* iOS Ref
    * [Resolution by iOS device ⇗](https://iosref.com/res)
    * [iOS version by device ⇗](https://iosref.com/ios)
* [Using iOS Simulator with the Command Line ⇗](https://notificare.com/blog/2020/05/22/Using-iOS-Simulator-with-the-Command-Line/) has command line approach for setting the simulator language and region via `plutil`.
