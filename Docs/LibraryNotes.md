# Library Notes

### ActiveLabel

- <https://cocoapods.org/pods/ActiveLabel>
- <https://github.com/optonaut/ActiveLabel.swift>
- Language:
    - Swift 5.0
    - **BLOCKING: Error blocks Swift 6.0 compile.**
- Swift Package Manager: 4.2
- Version: `1.1.5` (2020.11)
- Warnings: Using 'class' keyword to define a class-constrained protocol is deprecated; use 'AnyObject' instead

The `ActiveLabel` library, as used in the DailyDozen, can potentially be replaced by the [Swift Foundation Library `AttributedString`](https://developer.apple.com/documentation/foundation/attributedstring).  The Swift `AttributedString` structure is available starting with iOS 15.

_The `ActiveLabel` library project has not been kept current with the progression of the Swift platform._

### DGCharts

- DGCarts <https://cocoapods.org/pods/DGCharts>
- **25 issues. deprecations since iOS 13.0**
- <https://github.com/danielgindi/Charts>
    - <https://github.com/ChartsOrg/Charts>
    - <https://github.com/ChartsOrg/Charts/releases/tag/5.1.0>
- Language: Swift 5 (84%), ObjC (16%)
- Swift Package Manager: 5.1
- Version: `5.1.0` (2024.02.15)
    - deprecated: DanielGindi `Charts` 
    - renamed DanielGindi `Charts` to `DGCharts` due to namespace conflict with SwiftUI `Charts`
    - `DGCharts` (5.1.0, 2024.02.15) has breaking changes when migrating from DanielGindi `Charts`

### Swift Charts

- [Swift Charts](https://developer.apple.com/documentation/charts)

### FSCalendar

- <https://cocoapods.org/pods/FSCalendar>
- <https://github.com/WenchaoD/FSCalendar>
- Language: ObjC (88%), Swift (12%) 
- Swift Package Manager: 5.3
- Version: `2.8.3` (2021.12.13, github release), `2.8.4` (2022.04.07, pod release)
    - minimal code updates since 2018.11.07
    - 36 disallowed syntax issues "double-quoted include "*.h" in framework header, expected angle-bracketed instead"
    - settings "Quoted Include In Framework Header" CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER to No did not clear the errors.

### RealmSwift

- <https://cocoapods.org/pods/RealmSwift>
- <https://github.com/realm/realm-cocoa> (don't use)
- <https://github.com/realm/realm-swift> **"⚠️ Warning: We announced the deprecation of Atlas Device Sync + Realm SDKs in September 2024."**
- [docs.mongodb.com/realm-legacy/docs/swift/4.4.1](https://web.archive.org/web/20210413131317/https://docs.mongodb.com/realm-legacy/docs/swift/4.4.1/index.html) (archive.org)
- Language: Swift 5, C++ cxx14
- Swift Package Manager: 5.0, 5.7
- Version:
    - `4.4.1` used in DailyDozen v2, v3.0 to 3.4.x . _**"deprecated legacy project"**_
        - Warnings: uses deprecated `kSecAttrAccessibleAlways`
    - `10.30.0` breaking changes relative to current DailyDozen implementation.
    - `10.42.4` Used by DailyDozen 3.5.3 via CocoaPods. (Note: 42 compile time warnings internal to library.)
    - `10.46.0`
    - `10.54.6` Used by DailyDozen 4.x for migration to SQLite via Swift Package Manager.

_DailyDozen iOS v4.x switches the database from the 3rd Party RealmDB to the SQLite which is inherently provided and support by Apple across all Apple's operating systems. RealmDB was aquired by aquired competitor MongoDB. MongoDB is transitioning RealmDB to be a feature-limited community-support project._

### SimpleAnimation

- <https://cocoapods.org/pods/SimpleAnimation>
- <https://github.com/keithito/SimpleAnimation>
- Language: Swift
    - `SWIFT_VERSION`: 3.0, 4.0
- Swift Package Manager: _unspecified thus 4.0_
- In Use: `PagerViewController.swift` (`fadeOut`, `fadeIn`, `slideOut`, `popIn`)
- Version: `0.4.2` (2019.02.16)

_The `SimpleAnimation` library project has not been kept current with the progression of the Swift platform._

### CocoaPods

- [2024.08.13 CocoaPods Blog "CocoaPods Support & Maintenance Plans"](https://blog.cocoapods.org/CocoaPods-Support-Plans/) … "TLDR: We're still keeping it ticking, but we're being more up-front that CocoaPods is in maintenance mode."

- [2024.11.30 CocoaPods Blog "CocoaPods Trunk Read-only Plan"](https://blog.cocoapods.org/CocoaPods-Specs-Repo/) … "TLDR: In two years [approximately November 2026] we plan to turn CocoaPods trunk to be read-only. At that point, no new versions or pods will be added to trunk."

- [GitHub CocoaPods Repo: "CocoaPods is in maintenance mode"](https://github.com/CocoaPods/CocoaPods) … pre-archival (headed-to-be-read-only) stage. **"⚠️ Cocoapods is not receiving active development."**

Last updated: 2026.01.08