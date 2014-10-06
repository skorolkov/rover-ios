Pod::Spec.new do |s|
  s.name             = "Rover"
  s.version          = "0.21.0"
  s.summary          = "Rover iOS SDK for developing apps using the Rover platform."
  s.description      = <<-DESC
                       The Rover iOS SDK enables beacon detection and communication with the Rover platform. 
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

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.resource_bundles = {
    'Rover' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'Accelerate', 'CoreLocation'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  # s.subspec 'Networking' do |ss|
  #   ss.dependency 'Rover/Models'
  #   ss.source_files = 'Pod/Classes/Networking'
  # end
  #
  # s.subspec 'Location' do |ss|
  #   ss.source_files = 'Pod/Classes/Location'
  # end
  #
  # s.subspec 'Models' do |ss|
  #   ss.dependency 'Rover/Networking'
  #   ss.dependency 'Rover/Utilities'
  #   ss.source_files = 'Pod/Classes/Models'
  # end
  #
  # s.subspec 'Utilities' do |ss|
  #   ss.source_files = 'Pod/Classes/Utilities'
  # end
  #
  # s.subspec 'Controllers' do |ss|
  #   ss.source_files = 'Pod/Classes/Controllers'
  # end
  #
  # s.subspec 'Notifications' do |ss|
  #   ss.source_files = 'Pod/Classes/Notifications'
  # end
  #
  # s.subspec 'Views' do |ss|
  #   ss.subspec 'Card' do |sss|
  #     sss.source_files = 'Pod/Classes/Views/Card'
  #   end
  #
  #   ss.subspec 'CardDeck' do |sss|
  #     sss.dependency 'Rover/Views/Card'
  #     sss.source_files = 'Pod/Classes/Views/Card Deck'
  #   end
  #
  #   ss.subspec 'Modal' do |sss|
  #     sss.dependency 'Rover/Views/CardDeck'
  #     sss.source_files = 'Pod/Classes/Views/Modal'
  #   end
  # end
  
end
