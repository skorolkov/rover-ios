//
//  RXCardViewCell.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-12.
//
//

#import "RXCardViewCell.h"


// Shadow constants
#define kCardShadowColor [[UIColor blackColor] CGColor]
#define kCardShadowOffset CGSizeMake(0, 10)
#define kCardShadowOpacity 0.7
#define kCardShadowRadius 0


@interface RXCardViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *cardImageView;

@end

@implementation RXCardViewCell

- (void)awakeFromNib {
    [self initialize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self addSubviews];
    [self configureLayout];
}

- (void)addSubviews
{
    _containerView = [UIView new];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.layer.shadowColor = kCardShadowColor;
    _containerView.layer.shadowOffset = kCardShadowOffset;
    _containerView.layer.shadowOpacity = kCardShadowOpacity;
    _containerView.layer.shadowRadius = kCardShadowRadius;
    [self.contentView addSubview:_containerView];
    
    _cardImageView = [UIImageView new];
    _cardImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:_cardImageView];
    
}

- (void)configureLayout
{
    NSDictionary *views = @{@"containerView": _containerView,
                            @"cardImageView": _cardImageView};
    
    //----------------------------------------
    //  containerView
    //----------------------------------------
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[containerView]-15-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[containerView]-15-|" options:0 metrics:nil views:views]];
    
    //----------------------------------------
    //  cardImageView
    //----------------------------------------
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cardImageView]|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cardImageView]" options:0 metrics:nil views:views]];
}

@end
