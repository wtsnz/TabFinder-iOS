//
//  UpgradePromptViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 29/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"

@interface UpgradePromptViewController : ModalViewController

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
- (IBAction)didPressBuyButton:(id)sender;
- (IBAction)didPressCancelButton:(id)sender;
@end
