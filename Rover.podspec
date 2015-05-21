Pod::Spec.new do |s|
  s.name             = "Rover"
  s.version          = "0.30.10"
  s.summary          = "Rover iOS SDK for developing apps using the Rover platform."
  s.description      = <<-DESC
                       The Rover iOS SDK enables beacon (iBeacon) detection and communication with the Rover platform. 
                       Requires an account with [www.roverlabs.co](http://www.roverlabs.co/). 
                       To integrate after adding this pod, continue with "Connect your app to Rover" in the [documentation](http://docs.roverlabs.co/v1.0/docs/getting-started).
                       DESC
  s.homepage         = "http://www.roverlabs.co/"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Sean Rucker" => "sean@roverlabs.co" }
  s.source           = { :git => "https://github.com/Rover-Labs/rover-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/roverlabsinc'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = ['Pod/Classes/*.{h,m}']
  s.resource_bundles = {
    'Rover' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'Accelerate', 'CoreLocation'
  s.dependency 'RSBarcodes', '~> 0.1'
  s.dependency 'UIActivityIndicator-for-SDWebImage', '~> 1.2'

  s.subspec 'UI' do |ss|
    ss.source_files = 'Pod/Classes/UI/**/*.{h,m}'
    ss.dependency 'Rover/Model'
  end

  s.subspec 'Model' do |ss|
   ss.source_files = 'Pod/Classes/Model/**/*.{h,m}'
  end

  s.subspec 'Core' do |ss|
   ss.source_files = ['Pod/Classes/Core/**/*.{h,m}']
   ss.dependency 'Rover/Model'
  end

	s.subspec 'Networking' do |ss|
	 ss.source_files = ['Pod/Classes/Networking/**/*.{h,m}']
	 ss.dependency 'Rover/Model'
  end

end
