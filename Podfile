use_frameworks!

platform :ios, '12.0'

target 'SoloAISDK_Example' do
  pod 'SoloAISDK'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end