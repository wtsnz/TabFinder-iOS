//
//  UIImage+Blur.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 4/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur;
- (UIImage *)blurryImageWithBlurLevel:(CGFloat)blur;
- (UIImage *)desatured:(CGFloat)saturation;

@end
