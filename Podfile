# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

workspace 'NRBook.xcworkspace'

# local pods
def local_pods
  pod 'DTCoreText', :path => './LocalPods/DTCoreText', :modular_headers => true
  pod 'DTFoundation', :path => './LocalPods/DTFoundation', :modular_headers => true
end

# shared pods
def shared_pods
  pod 'AEXML', '~> 4.5.0'
  pod 'SSZipArchive', '~> 2.2.2'
  pod 'FMDB', '~> 2.7.5', :modular_headers => true
  pod 'SnapKit', '~> 5.0.1'
  pod 'CMPopTipView', '~> 2.3.2', :modular_headers => true
  pod 'PKHUD', '~> 5.3.0'
  pod 'ReachabilitySwift', '~> 5.0.0'
end

target 'NRBook' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  # use_frameworks!

  # Pods for NRBook
  local_pods
  shared_pods

  target 'NRBookTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NRBookUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# https://github.com/CocoaPods/CocoaPods/issues/8069
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            end
        end
    end
end
