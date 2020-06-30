#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint libpeardrop.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'libpeardrop'
  s.version          = '0.0.1'
  s.summary          = 'Dart bindings for PearDrop protocol.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://peardrop.app'
  s.author           = { 'anirudhb' => 'anirudhb@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.vendored_libraries = '**/*.dylib'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
