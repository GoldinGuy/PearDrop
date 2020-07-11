#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint peardrop.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'libpeardrop'
  s.version          = '0.0.1'
  s.summary          = 'Dart bindings for PearDrop protocol.'
  s.description      = <<-DESC
Dart bindings for PearDrop protocol.
                       DESC
  s.homepage         = 'https://peardrop.app'
  s.author           = { 'anirudhb' => 'anirudhb@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.public_header_files = 'Classes/**/*.h'
  s.source_files = 'Classes/**/*'
  s.vendored_libraries = '**/*.a'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
