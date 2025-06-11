// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "kakao_maps_flutter",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "kakao_maps_flutter",
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
        .product(name: "KakaoMapsSDK", package: "KakaoMapsSDK-SPM")
      ],
      path: "Classes",
      sources: ["**/*.swift"],
      publicHeadersPath: "."
    )
  ]
)
