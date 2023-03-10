// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQLiteCLib",
    platforms: [
        .macOS(.v13),  // .macOS(.v12),
        .iOS(.v12)     // .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SQLiteCLib",
            targets: ["SQLiteCLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. 
        // A target can define a module or a test suite.
        // Targets can depend on other targets in this package, 
        // and on products in packages this package depends on.
        
        // linux> sudo apt policy libsqlite3-dev
        // linux> sudo apt install libsqlite3-dev
        // linux> sudo apt install sqlite3-doc
        // macos> brew info sqlite3
        // macos> brew install sqlite3
        .systemLibrary(name: "SQLiteCLib", providers: [
            .apt(["libsqlite3-dev"]),
            .brew(["sqlite3"])
        ]),
        // .target(
        //     name: "SQLiteCLib",
        //     dependencies: []),
        .testTarget(
            name: "SQLiteCLibTests",
            dependencies: ["SQLiteCLib"]),
    ]
)
