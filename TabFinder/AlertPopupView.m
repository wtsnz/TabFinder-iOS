//
//  AlertPopupView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 14/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "AlertPopupView.h"

@implementation AlertPopupView

+(AlertPopupView *)showInView:(UIView *)view withMessage:(NSString *)message autodismiss:(BOOL)autodismiss {
    AlertPopupView *alertView = (AlertPopupView *)[[[NSBundle mainBundle] loadNibNamed:autodismiss ? @"AlertPopupView" : @"LoadingPopupView" owner:nil options:nil] lastObject];
    alertView.message.text = message;
    alertView.message.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:alertView.message.font.pointSize];
    alertView.layer.cornerRadius = 5;
    alertView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    alertView.center = CGPointMake(alertView.center.x, alertView.center.y - 60);
    [view addSubview:alertView];
    if (autodismiss) {
        [UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationOptionTransitionNone animations:^{
            alertView.alpha = 0;
        } completion:^(BOOL finished) {
            [alertView removeFromSuperview];
        }];
    }
    return alertView;
}

-(void)dismiss {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
