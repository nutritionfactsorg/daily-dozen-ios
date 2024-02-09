# Library Notes

**ActiveLabel**

- <https://cocoapods.org/pods/ActiveLabel>
- <https://github.com/optonaut/ActiveLabel.swift>
- Language: Swift 5.0
- Swift Package Manager: 4.2
- Version: `1.1.5` (2020.11)
- Warnings: Using 'class' keyword to define a class-constrained protocol is deprecated; use 'AnyObject' instead

The `ActiveLabel` library, as used in the DailyDozen, can potentially be replaced by the [Swift Foundation Library `AttributedString`](https://developer.apple.com/documentation/foundation/attributedstring).  The Swift `AttributedString` structure is available starting with iOS 15.

_The `ActiveLabel` library project has not been kept current with the progression of the Swift platform._

**Charts**

- <https://cocoapods.org/pods/Charts>
- <https://github.com/danielgindi/Charts>
- Language: Swift 5 (84%), ObjC (16%)
- Swift Package Manager: 5.1
- Version: `4.1.0` (2022.09.12), `5.0.0` (2023.06.08)
    - deprecated: DanielGindi `Charts` 
    - renamed DanielGindi `Charts` to `DGCharts` due to namespace conflict with SwiftUI `Charts`
    - `DGCharts` (5.0.0, 2023.06.08) has breaking changes when migrating from DanielGindi `Charts`

**FSCalendar**

- <https://cocoapods.org/pods/FSCalendar>
- <https://github.com/WenchaoD/FSCalendar>
- Language: ObjC (88%), Swift (12%) 
- Swift Package Manager: 5.3
- Version: `2.8.3` (2021.12.13, github release), `2.8.4` (2022.04.07, pod release)
    - minimal code updates since 2018.11.07
    - 36 disallowed syntax issues "double-quoted include "*.h" in framework header, expected angle-bracketed instead"
    - settings "Quoted Include In Framework Header" CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER to No did not clear the errors.

**RealmSwift**

- <https://cocoapods.org/pods/RealmSwift>
- <https://github.com/realm/realm-cocoa>
- [docs.mongodb.com/realm-legacy/docs/swift/4.4.1](https://web.archive.org/web/20210413131317/https://docs.mongodb.com/realm-legacy/docs/swift/4.4.1/index.html) (archive.org)
- Language: Swift 5, C++ cxx14
- Swift Package Manager: 5.0, 5.7
- Version:
    - `4.4.1` used in DailyDozen v2, v3.0 to 3.4.x . _**"deprecated legacy project"**_
        - Warnings: uses deprecated `kSecAttrAccessibleAlways`
    - `10.30.0` breaking changes relative to current DailyDozen implementation.
    - `10.46.0`

_DailyDoze iOS v3.5 will switch the database from the 3rd Party RealmDB to the SQLite which is inherently provided across Apple's operating systems._

**SimpleAnimation**

- <https://cocoapods.org/pods/SimpleAnimation>
- <https://github.com/keithito/SimpleAnimation>
- Language: Swift
    - `SWIFT_VERSION`: 3.0, 4.0
- Swift Package Manager: _unspecified thus 4.0_
- In Use: `*PagerViewController.swift` (`fadeOut`, `fadeIn`, `slideOut`, `popIn`)
- Version: `0.4.2` (2019.02.16)

_The `SimpleAnimation` library project has not been kept current with the progression of the Swift platform._

Last updated: 2024.02.04