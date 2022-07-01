# Library Notes

# Contents <a id="contents"></a>
[Library Status](#library-status-) •
[Resources](#resources-)

# Library Status <a id="library-status-"></a><sup>[▴](#contents)</sup>

**ActiveLabel**

* <https://cocoapods.org/pods/ActiveLabel>
* <https://github.com/optonaut/ActiveLabel.swift>
* Language: Swift 5.0
* Swift Package Manager: 4.2
* Version: `1.1.0` (2019.05)
* Warnings: Using 'class' keyword to define a class-constrained protocol is deprecated; use 'AnyObject' instead

The `ActiveLabel` library, as used in the DailyDozen, can be replaced by the [Swift Foundation Library `AttributedString`](https://developer.apple.com/documentation/foundation/attributedstring).  The `AttributedString` structure is available starting wiht iOS 15.

_The `ActiveLabel` library project has not been kept current with the progression of the Swift platform._

**Charts**

* <https://cocoapods.org/pods/Charts>
* <https://github.com/danielgindi/Charts>
* Language: Swift 5 (84%), ObjC (15%)
* Swift Package Manager: 5.1
* Version: `4.0.3` (2022.05.25)

**FSCalendar**

* <https://cocoapods.org/pods/FSCalendar>
* <https://github.com/WenchaoD/FSCalendar>
* Language: ObjC (88%), Swift (12%) 
* Swift Package Manager: 5.3
* Version: `2.8.4` (2022.04.07)

**RealmSwift**

* <https://cocoapods.org/pods/RealmSwift>
* <https://github.com/realm/realm-cocoa>
* <https://docs.mongodb.com/realm-legacy/docs/swift/4.4.1/index.html>
* Language: Swift 5, C++ cxx14
* Swift Package Manager: 5.0
* Version:
    * `4.4.1` in use. _**"deprecated legacy project"**_
        * Warnings: uses deprecated `kSecAttrAccessibleAlways`
    * `10.28.2` breaking changes relative to current DailyDozen implementation.

**SimpleAnimation**

* <https://cocoapods.org/pods/SimpleAnimation>
* <https://github.com/keithito/SimpleAnimation>
* Language: Swift
    * `SWIFT_VERSION`: 3.0, 4.0
* Swift Package Manager: _unspecified thus 4.0_
* In Use: `*PagerViewController.swift` (`fadeOut`, `fadeIn`, `slideOut`, `popIn`)
* Version: `0.4.2` (2019.02.16)

_The `SimpleAnimation` library project has not been kept current with the progression of the Swift platform._

# Resources <a id="resources-"></a><sup>[▴](#contents)</sup>

* [CocoaPods ⇗](https://cocoapods.org/)
* CocoaPod Syntax
    * [platform ⇗](https://guides.cocoapods.org/syntax/podfile.html#platform)