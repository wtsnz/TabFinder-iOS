//
//  SongTableView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/08/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "SongTableView.h"

@implementation SongTableView

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 8)];
        [self setSectionIndexTrackingBackgroundColor:[UIColor lightGrayColor]];
        [self setSectionIndexBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

@end
