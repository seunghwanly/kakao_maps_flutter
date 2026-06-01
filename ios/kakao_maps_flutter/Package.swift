// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "kakao_maps_flutter",
  platforms: [
    .iOS("13.0")
  ],
  products: [
    .library(
      name: "kakao-maps-flutter",
      targets: ["kakao_maps_flutter"]
    )
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
    .package(
      url: "https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM.git",
      .upToNextMinor(from: "2.12.5")
    )
  ],
  targets: [
    .target(
      name: "kakao_maps_flutter",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        .product(name: "KakaoMapsSDK-SPM", package: "KakaoMapsSDK-SPM")
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ]
)
