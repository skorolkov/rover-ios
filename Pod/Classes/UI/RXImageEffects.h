@import UIKit;

@interface RXImageEffects : NSObject

+ (UIImage *)applyLightEffectToImage:(UIImage *)image;
+ (UIImage *)applyExtraLightEffectToImage:(UIImage *)image;
+ (UIImage *)applyDarkEffectToImage:(UIImage *)image;
+ (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor toImage:(UIImage *)image;

+ (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage toImage:(UIImage *)image;

@end
