//
//  RVOrganization.m
//  Pods
//
//  Created by Ata Namvari on 2015-03-19.
//
//

#import "RVOrganization.h"

@implementation RVOrganization

#pragma mark - Overridden Properties

- (NSString *)modelName {
    return @"organization";
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.avatarURL forKey:@"avatarURL"];
}


- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [self init])) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.avatarURL = [decoder decodeObjectForKey:@"avatarURL"];
    }
    return self;
}

@end
