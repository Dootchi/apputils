#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint apputils.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'apputils'
  s.version          = '0.1.0'
  s.summary          = 'Reusable native capabilities for Dootchi Flutter apps.'
  s.description      = <<-DESC
Shared Flutter utilities with independently extensible native capabilities.
                       DESC
  s.homepage         = 'https://github.com/Dootchi/apputils'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dootchi' => 'Dootchi' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.vendored_frameworks = 'Frameworks/DpSDK.xcframework'
  # Enable this only after the DpSDK provider supplies audited collection and
  # Required Reason API declarations. Shipping an empty manifest would be
  # misleading for a device-risk SDK.
  # s.resource_bundles = {
  #   'apputils_privacy' => ['Resources/PrivacyInfo.xcprivacy']
  # }
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.frameworks = 'AVFoundation', 'CFNetwork', 'CoreMotion', 'Foundation', 'UIKit'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
end
