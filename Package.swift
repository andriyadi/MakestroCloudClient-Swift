import PackageDescription

let package = Package(
    name: "MakestroClient",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Aphid.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 1),
        .Package(url: "https://github.com/uraimo/SwiftyGPIO.git", majorVersion: 0)
    ]
)
