#
# Be sure to run `pod lib lint MediaWatermark.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MediaWatermark'
  s.version          = '0.1.2'
  s.summary          = 'Image and video processing'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MediaWatermark is a framework which helps to render watermarks over image or video content.               
        DESC

  s.homepage         = 'https://github.com/rubygarage/media-watermark'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sergey Afanasiev' => 'sergey.afanasiev@rubygarage.org' }
  s.source           = { :git => 'https://github.com/rubygarage/media-watermark.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'MediaWatermark/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MediaWatermark' => ['MediaWatermark/Assets/*.png']
  # }

  s.frameworks = 'UIKit'
  s.dependency 'Player', '~> 0.5'
  s.dependency 'MBProgressHUD', '~> 1.0'
end
