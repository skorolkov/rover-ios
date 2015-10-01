//
//  RVDeck.h
//  Pods
//
//  Created by Ata Namvari on 2015-09-29.
//
//

#import "RVModel.h"

@interface RVDeck : RVModel

@property (nonatomic, strong) NSString *notification;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, assign) BOOL delivered;
@property (nonatomic, strong) NSString *title;

@end
