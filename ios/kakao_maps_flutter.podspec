#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint kakao_maps_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'kakao_maps_flutter'
  s.version          = '0.0.1'
  s.summary          = 'KakaoMaps SDK v2 for Flutter'
  s.description      = <<-DESC
KakaoMaps SDK v2 for Flutter
                       DESC
  s.homepage         = 'https://github.com/seunghwanly/kakao_maps_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'seunghwanly' => 'seunghwanly@gmail.com' }
  s.source           = { :path => '.' }
  # s.source_files = 'Classes/**/*'
  s.source_files = 'kakao_maps_flutter/Sources/kakao_maps_flutter/**/*.swift'
  s.resource_bundles = {
    'kakao_maps_flutter_privacy' => ['kakao_maps_flutter/Sources/kakao_maps_flutter/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'
  s.dependency 'KakaoMapsSDK', '~> 2.12.5'
  s.platform = :ios, '13.0'
  s.ios.deployment_target = '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
