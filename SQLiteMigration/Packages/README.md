# README: Packages

## Contents <a id="contents"></a>
[Section](#section-) •
[Resources](#resources-)

_Steps to resolve "Missing package product 'PACKAGE_NAME'"_

* Xcode running on Rosetta?
* Clean project
* Delete derived data (`…/Xcode/DerivedData/…`)
* File > Packages > Reset Package Caches
* File > Packages > Resolve Package Versions (maybe needed multiple times?)
* Perhaps, delete any Package.resolved, .swiftpm or .build files in LOCAL packages
* Restart Xcode
* Restart Mac

``` swift
platforms: [
    .macOS(.v13),  // .macOS(.v12),
    .iOS(.v12)     // .iOS(.v13)
],
```

## Section <a id="section-"></a><sup>[▴](#contents)</sup>

## Resources <a id="resources-"></a><sup>[▴](#contents)</sup>

* [Related: Common HTML Entities ⇗](https://www.w3.org/wiki/Common_HTML_entities_used_for_typography)
