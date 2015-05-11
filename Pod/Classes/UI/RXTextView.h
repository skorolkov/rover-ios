//
//  RXTextView.h
//  Pods
//
//  Created by Ata Namvari on 2015-03-11.
//
//

#import <UIKit/UIKit.h>

/** This is simple view that prints attributed text. The advantage of this class over UILabel and UITextView is its size is
 exactly the same as suggested by NSAttributedString's boundingRectWithSize:options:context: method.
 */
@interface RXTextView : UIView

@property (nonatomic, strong) NSAttributedString *attributedText;

@end
