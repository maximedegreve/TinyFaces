import PackageDescription

let package = Package(
    name: "MarvelFaces",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/twostraws/SwiftGD.git", majorVersion: 1, minor: 1)
    ],
    exclude: [
        "Database",
        "Localization",
        "Tests",
    ]
)
