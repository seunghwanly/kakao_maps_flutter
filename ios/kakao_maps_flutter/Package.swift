// swift-tools-version:5.5
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
    .package(
      url: "https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM.git",
      from: "2.12.0"
    )
  ],
  targets: [
    .target(
      name: "kakao_maps_flutter",
      dependencies: [
        .product(name: "KakaoMapsSDK-SPM", package: "KakaoMapsSDK-SPM")
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ]
)
