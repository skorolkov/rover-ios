//
//  RXRecallButton.m
//  Pods
//
//  Created by Ata Namvari on 2015-06-02.
//
//

#import "RXRecallButton.h"
#import "RXCardsIcon.h"

@interface RXRecallButton ()

@property (nonatomic, assign) RXRecallButtonPosition initialPosition;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) CGPoint buttonPosition;

@end

#pragma mark - Private UIWindow

@interface _RXWindow : UIWindow
@end
@implementation _RXWindow
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *test = [super hitTest:point withEvent:event];
    if (test == self) {
        return nil;
    }
    return test;
}
- (void)orientationChanged:(NSNotification *)note {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self setTransform:[self transformForOrientation:orientation]];
    self.frame = [UIApplication sharedApplication].keyWindow.frame;
}
#define DegreesToRadians(degrees) (degrees * M_PI / 180)

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
    
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-DegreesToRadians(90));
            
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(DegreesToRadians(90));
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(DegreesToRadians(180));
            
        case UIInterfaceOrientationPortrait:
        default:
            return CGAffineTransformMakeRotation(DegreesToRadians(0));
    }
}
@end

#pragma mark - Private Window Manager

@interface _RXRecallManager : NSObject
@property (nonatomic, strong) _RXWindow *window;
@property (nonatomic, strong) RXRecallButton *button;
@end

@implementation _RXRecallManager

+ (instancetype)sharedManager {
    static _RXRecallManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _window = [[_RXWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.windowLevel = UIWindowLevelAlert;
        _window.opaque = NO;
    }
    return self;
}

- (void)showButton:(RXRecallButton *)button {
    if (_window.subviews.count > 0) {
        NSLog(@"ROVER/UI - ERROR: An RXRecallButton is already in display");
        return;
    }
    
    _window.hidden = NO;
    
    _button = button;
    
    button.center = button.buttonPosition.x == 0 ? [self tuckedPositionForButton:button corner:button.initialPosition] : button.buttonPosition;
    [_window addSubview:button];
    
    CGPoint point = [button snapPointToClosestEdgeFromPoint:button.center offset:UIOffsetZero];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = .5;
    animation.fromValue = [NSValue valueWithCGPoint:button.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:.7 :4/22.f :7/22.f :1];
    
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            button.isVisible = YES;
        }];
        [button.layer addAnimation:animation forKey:@"up"];
        button.layer.position = point;
    } [CATransaction commit];
}

- (CGPoint)tuckedPositionForButton:(RXRecallButton *)button corner:(RXRecallButtonPosition)corner {
    switch (corner) {
        case RXRecallButtonPositionBottomRight:
            return CGPointMake(_window.frame.size.width - _button.frame.size.width, _window.frame.size.height + (_button.frame.size.height / 2) + 5);
        case RXRecallButtonPositionBottomLeft:
            return CGPointMake(_button.frame.size.width, _window.frame.size.height + (_button.frame.size.height / 2) + 5);
        case RXRecallButtonPositionTopLeft:
            return CGPointMake(_button.frame.size.width, - (_button.frame.size.height / 2) - 5);
        case RXRecallButtonPositionTopRight:
            return CGPointMake(_window.frame.size.width - _button.frame.size.width, - (_button.frame.size.height / 2) - 5);
    }
}

- (CGPoint)offscreenPositionForButton:(RXRecallButton *)button {
    CGPoint center;
    
    switch ((int)button.anchoredEdge) {
        case RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeLeft:
        case RXDraggableSnappedEdgeTop | RXDraggableSnappedEdgeRight:
        case RXDraggableSnappedEdgeTop:
            center = CGPointMake(button.center.x, - (button.frame.size.height / 2) - button.layer.shadowRadius - 1);
            break;
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeLeft:
        case RXDraggableSnappedEdgeBottom | RXDraggableSnappedEdgeRight:
        case RXDraggableSnappedEdgeBottom:
            center = CGPointMake(button.center.x, button.superview.frame.size.height + (button.frame.size.height / 2) +  button.layer.shadowRadius + 1);
            break;
        case RXDraggableSnappedEdgeRight:
            center = CGPointMake(button.superview.frame.size.width + button.frame.size.width + button.layer.shadowRadius + 1, button.center.y);
            break;
        case RXDraggableSnappedEdgeLeft:
            center = CGPointMake(- (button.frame.size.width / 2) - button.layer.shadowRadius - 1, button.center.y);
            break;
    }
    
    return center;
}

- (void)hideButton:(RXRecallButton *)button completion:(void(^)())completion {
    CGPoint center = [self offscreenPositionForButton:button];
    button.buttonPosition = center;
    NSTimeInterval duration = .3;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         button.center = center;
                     }
                     completion:^(BOOL finished) {
                         button.isVisible = NO;
                         _window.hidden = YES;
                         [_button removeFromSuperview];
                         //_window = nil;
                         if (completion) {
                             completion();
                         }
                     }];
}

@end


#pragma mark - RXRecallButton

@implementation RXRecallButton

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithInitialPosition:RXRecallButtonPositionBottomRight];
}

- (instancetype)initWithInitialPosition:(RXRecallButtonPosition)position {
    UIView *view = [[RXCardsIcon alloc] initWithFrame:CGRectMake(12, 12, 38, 38)];
    return [self initWithCustomView:view initialPosition:position];
}

- (instancetype)initWithCustomView:(UIView *)view initialPosition:(RXRecallButtonPosition)position {
    return [self initWithFrame:CGRectMake(0, 0, 64, 64) customView:view initialPosition:position];
}

- (instancetype)initWithFrame:(CGRect)frame customView:(UIView *)view initialPosition:(RXRecallButtonPosition)position {
    self = [self initWithFrame:frame];
    if (self) {
        self.snapToCorners = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = .5;
        self.layer.shadowRadius = 4;
        
        UIView *viewContainer = [[UIView alloc] initWithFrame:self.bounds];
        viewContainer.backgroundColor = [UIColor clearColor];
        viewContainer.layer.cornerRadius = self.layer.cornerRadius;
        viewContainer.clipsToBounds = YES;
        [viewContainer addSubview:view];
        
        [self addSubview:viewContainer];
        _view = view;
        _initialPosition = position;
        _isVisible = NO;
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

#pragma mark - Instance Methods

- (void)hide:(BOOL)animated completion:(void (^)())completion {
    _RXRecallManager *manager = [_RXRecallManager sharedManager];
    [manager hideButton:self completion:completion];
}

- (void)show {
    _RXRecallManager *manager = [_RXRecallManager sharedManager];
    [manager showButton:self];
}

@end
