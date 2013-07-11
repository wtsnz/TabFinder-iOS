//
//  CustomWebView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 10/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "CustomWebView.h"

@implementation CustomWebView

//removes all shadows
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    for (UIView *view in [[[self subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
    }
    return self;
}

@end
