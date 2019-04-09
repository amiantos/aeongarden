def shared_pods
  pod 'SwiftLint'
  pod 'SwiftFormat/CLI'
  pod 'SnapKit', '~> 4.0'
end

target 'Aeon Garden iOS' do
  platform :ios, '11.0'
  use_frameworks!
  shared_pods
end

target 'Aeon Garden macOS' do
  platform :macos, '10.14'
  use_frameworks!
  shared_pods
end
