//
//  ProximaNovaLabel.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 16/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "ProximaNovaLabel.h"

@implementation ProximaNovaLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.font = [UIFont proximaNovaSize:self.font.pointSize];
    return self;
}

@end
