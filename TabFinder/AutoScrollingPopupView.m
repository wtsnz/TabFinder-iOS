//
//  AutoScrollingPopupView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 20/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "AutoScrollingPopupView.h"
#import "UIView+Popup.h"

@implementation AutoScrollingPopupView

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self addShadows];
    return self;
}

@end
