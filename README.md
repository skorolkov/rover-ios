# Rover

[![CI Status](http://img.shields.io/travis/Sean Rucker/Rover.svg?style=flat)](https://travis-ci.org/Sean Rucker/Rover)
[![Version](https://img.shields.io/cocoapods/v/Rover.svg?style=flat)](http://cocoadocs.org/docsets/Rover)
[![License](https://img.shields.io/cocoapods/l/Rover.svg?style=flat)](http://cocoadocs.org/docsets/Rover)
[![Platform](https://img.shields.io/cocoapods/p/Rover.svg?style=flat)](http://cocoadocs.org/docsets/Rover)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Rover is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "Rover"

## Create Rover.plist

Rover uses a Property List configuration file named `Rover.plist` to manage your application configuration settings.
The Rover.plist file uses the Application ID and Beacon UUID from the settings page of the admin console. If you haven't created an account yet, you will need to [sign up](http://app.roverlabs.co/#register) before continuing.

Next you need to add your Beacon UUID and Application ID to the Property List. You can find these values on the settings page of the [Admin Console](http://app.roverlabs.co/). You can open the file in Xcode and add your settings there. When you're done it should look like this:

![Rover.plist example](https://www.filepicker.io/api/file/WvLNfNeDRcW2Nzw33oWr)

## Connect your app to Rover

Open up your `AppDelegate.m` file and add the following import to the top of the file:
```objective-c
#import <Rover/Rover.h>
```
Paste the following inside the `application:didFinishLaunchingWithOptions:` function:
```objective-c
RVConfig *config = [RVConfig defaultConfig];
Rover *rover = [Rover setup:config];
[rover startMonitoring];
```
Your Beacon UUID and Application ID will be loaded from the Rover.plist file.

## Simulate a beacon

The Rover library provides a convenience method to simulate engaging with a beacon.

Open one of your View Controllers and again import the Rover framework:
```objective-c
#import <Rover/Rover.h>
```

Somewhere in your View Controller add the following method:
```objective-c
- (IBAction)simulateButtonClicked:(id)sender {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"Your Beacon UUID"];
    [[Rover shared] simulateBeaconWithUUID:UUID major:52643 minor:12345];
}
```
You will need to replace `Your Beacon UUID` before continuing.

## Author

Sean Rucker, srucker@gmail.com

## License

Rover is available under the MIT license. See the LICENSE file for more info.

