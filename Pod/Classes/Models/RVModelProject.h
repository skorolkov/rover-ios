//
//  RVModelProject.h
//  Rover
//
//  Created by Sean Rucker on 2014-08-08.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModel.h"

@interface RVModel ()

@property (strong, nonatomic) NSString *ID;

#pragma mark - Class Methods

- (NSString *)createPath;
- (NSString *)updatePath;
- (BOOL)isPersisted;
- (NSString *)modelName;
- (NSDateFormatter *)dateFormatter;

#pragma mark - Serialization

- (id)initWithJSON:(NSDictionary *)JSON;
- (void)updateWithJSON:(NSDictionary *)JSON;
- (NSDictionary *)toJSON;

@end
