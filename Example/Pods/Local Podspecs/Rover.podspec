#
# Be sure to run `pod lib lint Rover.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Rover"
  s.version          = "0.20.4"
  s.license             = { :type => 'Commercial', :text => 'See http://www.roverlabs.co/terms/' }
  s.platform            = :ios, '7.0'
  s.summary             = 'Rover iOS SDK for developing apps using the Rover platform.'
  s.description         = 'The Rover iOS SDK enables beacon detection and communication with the Rover platform. Requires an account with www.roverlabs.co. To integrate after adding this pod, continue with "Connect your app to Rover" in the documentation: (http://docs.roverlabs.co/ios/).'
  s.homepage            = 'http://www.roverlabs.co'
  s.author              = 'Rover'
  s.source              = { :git => "https://github.com/<GITHUB_USERNAME>/Rover.git", :tag => s.version.to_s }
  s.requires_arc        = true
  s.frameworks          = 'CoreLocation', 'Accelerate'
#s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'Rover' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/Rover.h', 'Pod/Classes/Views/Card/RVCard.h', 'Pod/Classes/Models/RVModel.h', 'Pod/Classes/Models/RVVisit.h', 'Pod/Classes/Models/RVCustomer.h', 'Pod/Classes/Controllers/RVCardViewController.h', 'Pod/Classes/Controllers/RVModalViewController.h'

  # s.dependency 'AFNetworking', '~> 2.3'

  s.subspec 'Manager' do |ss|
    ss.dependency 'Rover/Networking'
    ss.dependency 'Rover/Location'
    ss.dependency 'Rover/Models'
    ss.dependency 'Rover/Utilities'
    ss.dependency 'Rover/Views'
    ss.dependency 'Rover/Controllers'
    ss.dependency 'Rover/Views'
    ss.dependency 'Rover/Notifications'

    ss.source_files = 'Pod/Classes'
  end

  s.subspec 'Networking' do |ss|
    ss.dependency 'Rover/Models'

    ss.source_files = 'Pod/Classes/Networking'
  end

  s.subspec 'Location' do |ss|
    ss.dependency 'Rover/Manager'

    ss.source_files = 'Pod/Classes/Location'
  end

  s.subspec 'Models' do |ss|
    ss.dependency 'Rover/Networking'
    ss.dependency 'Rover/Utilities'

    ss.source_files = 'Pod/Classes/Models'
  end

  s.subspec 'Utilities' do |ss|
    ss.source_files = 'Pod/Classes/Utilities'
  end

  s.subspec 'Controllers' do |ss|
    ss.dependency 'Rover/Manager'

    ss.source_files = 'Pod/Classes/Controllers'
  end

  s.subspec 'Notifications' do |ss|
    ss.source_files = 'Pod/Classes/Notifications'
  end

  s.subspec 'Views' do |ss|
    ss.subspec 'Card' do |sss|
      sss.source_files = 'Pod/Classes/Views/Card'
    end

    ss.subspec 'CardDeck' do |sss|
      sss.dependency 'Rover/Views/Card'

      sss.source_files = 'Pod/Classes/Views/Card Deck'
    end

    ss.subspec 'Modal' do |sss|
      sss.dependency 'Rover/Views/CardDeck'

      sss.source_files = 'Pod/Classes/Views/Modal'
    end
  end

end
