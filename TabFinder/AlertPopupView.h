//
//  AlertPopupView.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 14/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertPopupView : UIView
@property (weak, nonatomic) IBOutlet UILabel *message;

+(AlertPopupView *)showInView:(UIView *)view withMessage:(NSString *)message autodismiss:(BOOL)autodismiss;
-(void)dismiss;

@end
