//
//  RVConfig.m
//  Pods
//
//  Created by Ata Namvari on 2015-04-15.
//
//

#import "RVConfig.h"
#import "RXModalViewController.h"

@implementation RVConfig

+ (RVConfig *)defaultConfig {
    RVConfig *config = [[RVConfig alloc] init];
    config.allowedUserNotificationTypes = (UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound);
    config.notificationSoundName = UILocalNotificationDefaultSoundName;
    config.autoPresentModal = YES;
    config.sandboxMode = NO;
    config.modalViewControllerClass = [RXModalViewController class];
    config.serverURL = @"http://api.roverlabs.co/mobile/v2/";
    config.modalBackdropBlurRadius = 3;
    config.modalBackdropTintColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Rover" ofType:@"plist"];
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    id serverURL = [plist objectForKey:@"serverURL"];
    if (serverURL) {
        if (![serverURL isKindOfClass:[NSString class]]) {
            NSLog(@"%@ warning serverURL property in Rover.plist is expected to be a string", self);
        } else if ([serverURL length]) {
            config.serverURL = serverURL;
        }
    }
    
    id applicationID = [plist objectForKey:@"applicationID"];
    if (applicationID) {
        if (![applicationID isKindOfClass:[NSString class]]) {
            NSLog(@"%@ warning applicationID property in Rover.plist is expected to be a string", self);
        } else if ([applicationID length]) {
            config.applicationID = applicationID;
        }
    }
    id beaconUUIDs = [plist objectForKey:@"beaconUUIDs"];
    if (beaconUUIDs) {
        if (![beaconUUIDs isKindOfClass:[NSArray class]]) {
            NSLog(@"%@ warning beaconUUIDs property in Rover.plist is expected to be an array", self);
        } else if ([beaconUUIDs count]) {
            [beaconUUIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj) {
                    if (![obj isKindOfClass:[NSString class]]) {
                        NSLog(@"%@ warning each item in beaconUUIDs is expected to be a string", self);
                    } else if ([obj length]) {
                        [config addBeaconUUID:obj];
                    }
                }
            }];
        }
    }
    
    return config;
}

- (void)addBeaconUUID:(NSString *)UUIDString {
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
    if (self.beaconUUIDs) {
        _beaconUUIDs = [self.beaconUUIDs arrayByAddingObject:UUID];
    } else {
        _beaconUUIDs = [NSArray arrayWithObject:UUID];
    }
}

- (void)registerModalViewControllerClass:(Class)modalViewControllerClass {
    if (![modalViewControllerClass isSubclassOfClass:[UIViewController class]]) {
        NSLog(@"%@ warning - you must register a valid UIViewController class", self);
        return;
    }
    _modalViewControllerClass = modalViewControllerClass;
}

@end