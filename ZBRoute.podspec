#
#  Be sure to run `pod spec lint ZBRoute.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  #名称
  s.name         = 'ZBRoute'
  #版本号-改变文件内容,需要升级版本号
  s.version      = '1.0.0'
  #简介
  s.summary      = 'ZBRoute'
  #详细介绍
  s.description  = <<-DESC
                    Handle the data.
                   DESC

  s.homepage     = 'http://www.jianshu.com/u/c2bf90d2bdf1'
  #开源协议
  s.license      = { :type => "MIT", :file => "LICENSE" }
  #支持的平台及版本
  s.platform     = :ios, '8.0'
  #支持ARC
  s.requires_arc = true 
  s.author             = { '肖志斌' => '373379320@qq.com' }
  #支持的pod最低版本
  s.ios.deployment_target = '8.0'
  s.source      = { :git => 'https://github.com/k373379320/ZBRoute.git',
:tag => s.version.to_s }
  #代码源文件地址，**/*表示Classes目录及其子目录下所有文件，如果有多个dependency目录下则用逗号分开，如果需要在项目中分组显示，这里也要做相应的设置
  s.source_files  = 'ZBRoute/Classes/**/*.{h,m}'
   # s.public_header_files = 'Pod/Classes/**/*.h'   #公开头文件地址
  s.exclude_files = 'Source/Exclude'
  #所需的framework
  s.frameworks = 'UIKit','CoreFoundation'
  #依赖关系，该项目所依赖的其他库，如果有多个需要填写多个s.dependency
  s.libraries = 'z'
end
