# Feature: Google (Firebase) Analytics

## Contents <a id="contents"></a>
[Implementation](#implementation-) •
[Resources](#resources-)

## Implementation <a id="implementation-"></a><sup>[▴](#contents)</sup>

**User Defaults**

_SettingsKeys.swift_ declares the persistent `UserDefaults` key name.

``` swift
// Analytics is enabled when when true|"1"|"on"
static let analyticsIsEnabledPref = "analyticsIsEnabledPref"
```

**Localization**

_Localizable.strings_ contains the translatable strings.

``` swift
"setting_analytics_body" = "Enable anonymous usage information to be collected…";

"setting_analytics_enable" = "Enable Analytics";
"setting_analytics_opt_in" = "Opt In";
"setting_analytics_opt_out" = "Opt Out";

"setting_analytics_title" = "Analytics";
```

**Initialization**

_AppDelegate.swift_ initializes and enables analytics during application launch, if the user has opted-in.

``` swift
if UserDefaults.standard.bool(forKey: SettingsKeys.analyticsIsEnabledPref) == true { … }
```

**Prompted Opt-In Request**

_DozeEntryPagerViewController.swift_ and _TweakEntryPagerViewController.swift_

``` swift
func viewDidAppear(…) { … }
```

**User Action**

_SettingsViewController.swift_

``` swift
func viewWillAppear(…) { analyticsEnableToggle.isOn = … }

@IBAction func doAnalyticsSwitched(…) { … }
```

**Test (Advanced Utilities) Action**

_UtilityTableViewController_

``` swift
func doUtilitySettingsClear() { … }
func doUtilitySettingsShow() { … }
```

## Resources <a id="resources-"></a><sup>[▴](#contents)</sup>

* Apple
    * [App Privacy Details ⇗](https://developer.apple.com/app-store/app-privacy-details/)
    * [App Tracking Transparency Framework ⇗](https://developer.apple.com/documentation/apptrackingtransparency) … cross tracking to 3rd party applications
    * [User Privacy and Data Use ⇗](https://developer.apple.com/app-store/user-privacy-and-data-use/)
* Google
    * [Add Firebase to your Apple project ⇗](https://firebase.google.com/docs/ios) setup. available libraries.
    * [Configure Analytics data collection and usage ⇗](https://firebase.google.com/docs/analytics/configure-data-collection?platform=ios)
    * [Supporting iOS 14 ⇗](https://firebase.google.com/docs/ios/supporting-ios-14)
