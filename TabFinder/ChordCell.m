//
//  ChordCell.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 26/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "ChordCell.h"

@implementation ChordCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (NSLayoutConstraint *cellConstraint in self.constraints)
    {
        [self removeConstraint:cellConstraint];
        
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        
        NSLayoutConstraint* contentViewConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                                 attribute:cellConstraint.firstAttribute
                                                                                 relatedBy:cellConstraint.relation
                                                                                    toItem:seccondItem
                                                                                 attribute:cellConstraint.secondAttribute
                                                                                multiplier:cellConstraint.multiplier
                                                                                  constant:cellConstraint.constant];
        
        [self.contentView addConstraint:contentViewConstraint];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.95 alpha:1] cornerRadius:0]];
    return self;
}


@end
