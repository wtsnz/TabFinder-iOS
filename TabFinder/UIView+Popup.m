//
//  UIView+Popup.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 10/08/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "UIView+Popup.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Popup)

-(void)addShadows {
    self.layer.cornerRadius = 5;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 2;
    self.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.3].CGColor;
    self.layer.borderWidth = 1;
}

@end
