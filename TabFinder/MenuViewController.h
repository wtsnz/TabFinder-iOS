//
//  MenuViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Engine.h"

@interface MenuCell : UITableViewCell

@end

@interface MenuViewController : UITableViewController

+(MenuViewController *)instance;
- (IBAction)iCloudSwitchChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *icloudSwitch;

@end
