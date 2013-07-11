//
//  UISearchBar+FlatUI.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 9/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "UISearchBar+FlatUI.h"
#import <QuartzCore/QuartzCore.h>

@implementation UISearchBar (FlatUI)

-(void)makeItFlat {
    for( UIView *subview in self.subviews )
    {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            textField.borderStyle = UITextBorderStyleNone;
            textField.layer.borderWidth = 0;
            textField.layer.cornerRadius = 5.0f;
            textField.background = nil;
            textField.backgroundColor = [UIColor whiteColor];
        } else if ([subview isKindOfClass:NSClassFromString( @"UISearchBarBackground" )] )
            {
                UIImageView *aView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.9 alpha:1] cornerRadius:0]];
                aView.frame = subview.bounds;
//                aView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
                [subview addSubview:aView];
            }
    }
}

@end
