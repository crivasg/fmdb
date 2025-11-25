// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let applePlatforms: [PackageDescription.Platform] = [.iOS, .macOS, .watchOS, .tvOS, .visionOS]

let sqlcipherTraitTargetCondition: TargetDependencyCondition? = .when(platforms: applePlatforms, traits: ["SQLCipher"])

let sqlcipherTraitBuildSettingCondition: BuildSettingCondition? = .when(platforms: applePlatforms, traits: ["SQLCipher"])

let package = Package(
    name: "FMDB",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "FMDB", targets: ["FMDB"]),
    ],
    traits: [
        .trait(name: "SQLCipher", description: "Enables SQLCipher encryption when a passphrase is supplied to FMDatabase")
    ],
    dependencies: [
        .package(url:"https://github.com/sqlcipher/SQLCipher.swift", from: "4.11.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FMDB",
            dependencies: [
                .product(name: "SQLCipher", package: "SQLCipher.swift", condition: sqlcipherTraitTargetCondition),
            ],
            path: "src/fmdb",
            resources: [.process("../../privacy/PrivacyInfo.xcprivacy")],
            publicHeadersPath: ".",
            cSettings: [
                .define("SQLITE_HAS_CODEC", to: nil, sqlcipherTraitBuildSettingCondition),
                .define("SQLCIPHER_CRYPTO", to: nil, sqlcipherTraitBuildSettingCondition)
            ]
        )
    ]
)
