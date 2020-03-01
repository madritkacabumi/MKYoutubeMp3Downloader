#
# Be sure to run `pod lib lint MKYoutubeMp3Downloader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MKYoutubeMp3Downloader'
  s.version          = '1.0.0'
  s.summary          = 'Download youtube videos into mp3 file'

  s.description      = <<-DESC
The library will use a node js server in-mobile built in (local server).
It will use a node js script will download a youtube video.
Then using a ffmpeg external swift library will convert the video in mp3.
                       DESC

  s.homepage         = 'https://github.com/devMadrit/MKYoutubeMp3Downloader'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Madrit Kacabumi' => 'madrit.kacabumi@gmail.com' }
  s.source           = { :git => 'https://github.com/devMadrit/MKYoutubeMp3Downloader.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.2'
  s.swift_version = '5.0'
  s.source_files = 'MKYoutubeMp3Downloader/**/*'
  
  s.resource_bundles = {
    'MKYoutubeToMp3DownloaderZip' => ['MKYoutubeMp3Downloader/Enviroment/NodejsServer/*.zip']
  }
  s.ios.vendored_frameworks = 'libs/NodeMobile.framework'
  s.dependency 'Zip'
  s.dependency 'mobile-ffmpeg-full'
  s.static_framework = true
end
