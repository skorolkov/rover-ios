//
//  RVModel.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModel.h"

extern inline NSObject* RVNullSafeValueFromObject(NSObject *object) {
    if (object) {
        return object;
    }
    return [NSNull null];
}

@implementation RVModel

#pragma mark - Paths

- (NSString *)modelName {
    // TODO: Throw an exception if this ever gets called. Should be overridden by each sub class.
    return @"";
}

- (BOOL)isPersisted {
    return self.ID != nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.ID forKey:@"ID"];
    [encoder encodeObject:self.meta forKey:@"meta"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [self init])) {
        //decode properties, other class vars
        self.ID = [decoder decodeObjectForKey:@"ID"];
        self.meta = [decoder decodeObjectForKey:@"meta"];
    }
    return self;
}

@end
