platform :ios, '12.0'

target 'XiandaoDemo' do
  use_frameworks!

  pod 'SnapKit'
  pod 'Alamofire'
  pod 'Mantis', :git => 'https://github.com/guoyingtao/Mantis.git', :tag => 'v2.31.1'

end

# 禁用CocoaPods并行代码签名，解决沙盒权限问题
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 设置禁用并行代码签名
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      # 设置部署目标为12.0
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end

  # 修改Pod项目设置
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
  end
end
