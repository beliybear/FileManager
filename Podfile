# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'FileManager' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'FMPhotoPicker', '~> 1.3.0'
  pod 'KeychainAccess'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end

end
