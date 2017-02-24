import PackageDescription

let package = Package(
    name: "BoardInfoPublish",
    dependencies: [
        .Package(url: "https://github.com/andriyadi/MakestroCloudClient-Swift.git", majorVersion: 0),
        .Package(url: "https://github.com/uraimo/SwiftyGPIO.git", majorVersion: 0)
    ]
)
