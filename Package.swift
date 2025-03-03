// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Reps",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Reps",
            targets: ["Reps"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.19.0"),
    ],
    targets: [
        .target(
            name: "Reps",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "RepsTests",
            dependencies: ["Reps"]),
    ]
) 