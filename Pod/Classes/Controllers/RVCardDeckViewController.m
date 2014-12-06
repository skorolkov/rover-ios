//
//  RVCardDeckViewController.m
//  Pods
//
//  Created by Ata Namvari on 2014-12-04.
//
//

#import "RVCardDeckViewController.h"
#import "RVModalView.h"
#import "RVCardDeckView.h"
#import "RVImageEffects.h"

@interface RVCardDeckViewController () <RVModalViewDelegate, RVCardDeckViewDelegate, RVCardDeckViewDataSourceDelegate>

@property (strong, nonatomic) RVModalView *view;

@end

@implementation RVCardDeckViewController

- (void)loadView {
    self.view = self.modalView = [[RVModalView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
    self.cardDeckView = self.view.cardDeck;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.delegate = self;
    self.view.cardDeck.delegate = self;
    self.view.cardDeck.dataSource = self;
    
    [self createBlur];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.cardDeckView animateIn:^{
        [self.view animateIn];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBlur {
    UIViewController* rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIView *view = rootViewController.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [RVImageEffects applyBlurWithRadius:self.backdropBlurRadius tintColor:self.backdropTintColor saturationDeltaFactor:1 maskImage:nil toImage:image];
    
    self.view.background.image = image;
}

#pragma mark - RVModalViewDelegate methods

- (void)modalViewBackgroundPressed:(RVModalView *)modalView {
    
}

- (void)modalViewCloseButtonPressed:(RVModalView *)modalView {
    if (self.view.cardDeck.isFullScreen) {
        [self.view.cardDeck exitFullScreen];
    }
    //else if (self.delegate) {
    //    [self.delegate modalViewControllerDidFinish:self];
    //}
}

#pragma mark - RVCardDeckViewDelegate

- (void)cardDeck:(RVCardDeckView *)cardDeck didSwipeCard:(RVCardBaseView *)cardView
{
    
}

- (void)cardDeck:(RVCardDeckView *)cardDeck didShowCard:(RVCardBaseView *)cardView
{
    
}

- (void)cardDeckDidPressBackground:(RVCardDeckView *)cardDeck {}
- (void)cardDeckWillEnterFullScreen:(RVCardDeckView *)cardDeck {}
- (void)cardDeckDidEnterFullScreen:(RVCardDeckView *)cardDeck {}
- (void)cardDeckWillExitFullScreen:(RVCardDeckView *)cardDeck {}
- (void)cardDeckDidExitFullScreen:(RVCardDeckView *)cardDeck {}
- (void)cardDeckDidEnterBarcodeView:(RVCardDeckView *)cardDeck {}

#pragma mark - RVCardDeckViewDataSource

- (NSUInteger)numberOfItemsInDeck:(RVCardDeckView *)cardDeck
{
    // To be implemented by subclass
    return 0;
}

- (RVCardBaseView *)cardDeck:(RVCardDeckView *)cardDeck cardViewForItemAtIndex:(NSUInteger)index
{
    // To be implemented by subclass
    return nil;
}

@end
