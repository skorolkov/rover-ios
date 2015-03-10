//
//  RVView.h
//  Pods
//
//  Created by Ata Namvari on 2015-03-05.
//
//

#import "RVModel.h"
#import "RVBackgroundImage.h"

typedef NS_ENUM(NSUInteger, RVViewDefinitionType) {
    RVViewDefinitionTypeListView = 0,
    RVViewDefinitionTypeDetailView = 1
};

@interface RVViewDefinition : RVModel <RVBackgroundImage>

@property (nonatomic, assign) RVViewDefinitionType type;
@property (nonatomic, strong) NSArray *blocks;
@property (nonatomic) UIEdgeInsets margins;
@property (nonatomic) CGFloat cornerRadius;


- (CGFloat)heightForWidth:(CGFloat)width;

@end
