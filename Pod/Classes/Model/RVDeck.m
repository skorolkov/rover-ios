//
//  RVDeck.m
//  Pods
//
//  Created by Ata Namvari on 2015-09-29.
//
//

#import "RVDeck.h"
@import UIKit;

@implementation RVDeck

- (NSURL *)avatarURL {
    if (!_avatarURL) {
        return nil;
    }
    
    NSInteger size = [UIScreen mainScreen].scale * 64;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?w=%ld&h=%ld", _avatarURL.absoluteString, (long)size, (long)size]];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.notification forKey:@"notification"];
    [encoder encodeObject:[NSNumber numberWithBool:self.delivered] forKey:@"delivered"];
    [encoder encodeObject:self.cards forKey:@"cards"];
    [encoder encodeObject:_avatarURL forKey:@"avatarURL"];
    [encoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.notification = [decoder decodeObjectForKey:@"notification"];
        self.delivered = [[decoder decodeObjectForKey:@"delivered"] boolValue];
        self.cards = [decoder decodeObjectForKey:@"cards"];
        _avatarURL = [decoder decodeObjectForKey:@"avatarURL"];
        self.title = [decoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
