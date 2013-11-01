//
//  AlertPopupView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 14/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "AlertPopupView.h"

@implementation AlertPopupView

+(void)showInView:(UIView *)view withMessage:(NSString *)message {
    AlertPopupView *alertView = (AlertPopupView *)[[[NSBundle mainBundle] loadNibNamed:@"AlertPopupView" owner:nil options:nil] lastObject];
    alertView.message.text = message;
    alertView.message.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:alertView.message.font.pointSize];
    alertView.layer.cornerRadius = 5;
    alertView.center = view.center;
    [view addSubview:alertView];
    [UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationOptionTransitionNone animations:^{
        alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
    }];
}

@end
