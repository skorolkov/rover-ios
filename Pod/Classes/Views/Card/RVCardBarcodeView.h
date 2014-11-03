//
//  RVCardBarcodeView.h
//  Rover
//
//  Created by Ata Namvari on 2014-10-14.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardBaseView.h"

@class RVCardView;

@interface RVCardBarcodeView : RVCardBaseView

@property (weak, nonatomic) RVCardView *cardView;

- (void)setBarcode:(NSString *)code withType:(NSString *)barcodeType;

@end
